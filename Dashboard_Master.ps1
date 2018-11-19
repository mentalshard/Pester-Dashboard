$HomePage = . (Join-Path $PSScriptRoot "pages\home.ps1")
$FilePage = . (Join-Path $PSScriptRoot "pages\FilePage.ps1")
$DirectoryPage = . (Join-Path $PSScriptRoot "pages\DirectoryPage.ps1")

#$path = '.\test.xml'
#[xml]$xml = Get-Content -path $path
$Endpoints = @()


$Schedule = New-UDEndpointSchedule -Every 1 -Minute
$pages = @($HomePage, $DirectoryPage, $FilePage)

$Cache:PesterFolder = '.\pester test dir\'
$Cache:SiteURL = 'http://localhost:1001/'
$Cache:Filenames = @{}
$Cache:PageContent = @{}
$Cache:Directories = @{}
Function New-UDStaticTable {
    param(
    [Parameter()]
    [string]$Id = (New-Guid),
    [Parameter()]
    [string]$Title,
    [Parameter(Mandatory = $true)]
    [string[]]$Headers,
    [Parameter()]
    [UniversalDashboard.Models.DashboardColor]$BackgroundColor,
    [Parameter()]
    [UniversalDashboard.Models.DashboardColor]$FontColor,
    [Parameter()]
    [ValidateSet("bordered", "striped", "highlight", "centered", "responsive-table")]
    [string]$Style,        
    [Parameter(ParameterSetName = 'content')]
    [ScriptBlock]$Content,
    [Parameter()]
    [UniversalDashboard.Models.Link[]] $Links,
    [Parameter()]
    [Switch]$AutoRefresh,
    [Parameter()]
    [int]$RefreshInterval = 5
    )
    
    $Actions = $null
    if ($Links -ne $null) {
        $Actions = New-UDElement -Tag 'div' -Content {
            $Links
        } -Attributes @{
            className = 'card-action'
        }
    }
    
    New-UDElement -Tag "div" -Id $Id -Attributes @{
        className = 'card ud-table' 
        style = @{
            backgroundColor = $BackgroundColor.HtmlColor
            color = $FontColor.HtmlColor
        }
    } -Content {
        New-UDElement -Tag "div" -Attributes @{
            className = 'card-content'
        } -Content {
            New-UDElement -Tag 'span' -Content { $Title }
            New-UDElement -Tag 'table' -Content {
                New-UDElement -Tag 'thead' -Content {
                    New-UDElement -Tag 'tr' -Content {
                        foreach($header in $Headers) {
                            New-UDElement -Tag 'th' -Content { $header }
                        }
                    }
                }
                New-UDElement -Tag 'tbody' -Content {$Content.Invoke()}
            } -Attributes @{ className = $Style }
        }
        $Actions
    }
}

Function New-UDTestObject {
    Param (
    $xml
    )
    New-UDRow {
        # Fixture summary (pass/fail/inconclusive) (Doughnut)
        New-UDColumn {
            New-UDChart -Type Doughnut -Title 'Fixture Summary' -Endpoint {
                $xml.'test-results'.'test-suite'.results.'test-suite' | ForEach-Object {
                    If ($_.Result -eq 'Failure'){
                        New-Object psobject -Property @{
                            Type = 'Fail'
                            Value = 1   
                        }
                    }
                    ElseIf ($_.Result -eq 'Inconclusive'){
                        New-Object psobject -Property @{
                            Type = 'Inconclusive'
                            Value = 1   
                        }
                    }
                    ElseIf ($_.Result -eq 'Success'){
                        New-Object psobject -Property @{
                            Type = 'Pass'
                            Value = 1   
                        }
                    }
                } | Group-Object -property 'Type' | Sort-Object | Out-UDChartData -DataProperty "Count" -LabelProperty "Name" -BackgroundColor @('#D62728','#2Ca02C') -HoverBackgroundColor @('#ED4730','#adc896') 
                
                
            } -Options @{
                <#layout = @{
                    padding = @{
                        left = 0
                    }
                }#>
                #'animation.animateScale' = $true;
                legend = @{
                    display = $false
                    #position = 'right'
                }
                tooltips = @{
                    bodyFontColor = '#000'
                    backgroundColor = 'rgb(0,0,0,0.2)'
                    #displayColors = $false
                } 
            }
        }
        # Test Summary (Doughnut)
        New-UDColumn {
            New-UDChart -Type Doughnut -Title 'Test Summary' -Endpoint {
                $xml.'test-results'.'test-suite'.results.'test-suite'.results.'test-case' | ForEach-Object {
                    If ($_.Result -eq 'Failure'){
                        New-Object psobject -Property @{
                            Type = 'Fail'
                            Value = 1   
                        }
                    }
                    ElseIf ($_.Result -eq 'Inconclusive'){
                        New-Object psobject -Property @{
                            Type = 'Inconclusive'
                            Value = 1   
                        }
                    }
                    ElseIf ($_.Result -eq 'Success'){
                        New-Object psobject -Property @{
                            Type = 'Pass'
                            Value = 1   
                        }
                    }
                } | Group-Object -property 'Type' | Sort-Object | Out-UDChartData -DataProperty "Count" -LabelProperty "Name" -BackgroundColor @('#D62728','#2Ca02C') -HoverBackgroundColor @('#ED4730','#adc896') 
                
                
            } -Options @{
                legend = @{
                    display = $false
                    #position = 'right'
                }
                tooltips = @{
                    bodyFontColor = '#000'
                    backgroundColor = 'rgb(0,0,0,0.2)'
                    #displayColors = $false
                } 
            }
        }
    }
    $rowGUID = New-Guid
    New-UDRow -Id $rowGUID {
        #$cache:hash = @{}
        Foreach ($t in $xml.'test-results'.'test-suite'.results.'test-suite'){
            #$cache:hash.add($t.name,$t)
            New-UDCard -Content {
                New-UDCollapsible -Items {
                    $title = $t.name
                    New-UDCollapsibleItem -Title $title -Icon check -Content {
                        New-UDStaticTable -Headers @('Test Name','Status') -Title ' ' -Content {
                            $t.results.'test-case' | Select-Object description, result | Out-UDTableData -Property @('description','result')
                        }
                    }
                }
            }
        } 
    }
}



Function Get-XMLtoCache {
    Param (
        $Path, $DirID
    )
    $XMLFiles = Get-ChildItem -Path $path -Filter '*.xml'
    Foreach ($XMLFile in $XMLFiles){
        [xml]$xml = Get-Content -Path $XMLFile.FullName
        $ID = (New-Guid).Guid
        $Directory = [System.Web.HttpUtility]::UrlEncode($xmlfile.Directory.Name)
        $Filename = [System.Web.HttpUtility]::UrlEncode($($XMLFile.Name.Replace('.xml','')))
        $Url = $DirID

        $Cache:Filenames.Add($url,(New-Object psobject -Property @{
            FileID = $ID
            URL = $Url
            Directory = $Directory
            Filename = $Filename
            Successful = $($xml.'test-results'.total - $xml.'test-results'.failures)
            Failures = $xml.'test-results'.failures
            FixtureCount = $xml.'test-results'.total
            }
        ))
        
        $Cache:PageContent.Add($($url+$Filename),(New-UDTestObject -XML $xml))

    }
}
Function Get-Directories {
    Param ($Path, $ParentID)
    Foreach ($Directory in  (Get-ChildItem -path $Path -Directory)){
        $DirID = $($Directory | Resolve-Path -Relative).Substring(1).Replace(' ','').Replace('\','-')
        $Cache:Directories.Add($DirID,(
            New-Object psobject -Property @{
                Directory = $Directory.name;
                Parent = $Directory.Parent.Name;
                DirID = $dirID;
                ParentID = $ParentID;
                Children = If (Get-ChildItem -Path $Directory.FullName -Directory){$true};
                Tests = If (Get-ChildItem -Path $Directory.FullName -Filter "*.xml"){$true};
            }
        ))
        Get-XMLtoCache -Path $Directory.FullName -DirID $DirID
        If (Get-ChildItem -path $Directory.FullName -Directory){
            Get-Directories -Path $Directory.FullName -ParentID $DirID.Replace('Directory/','')
        }
    }
}

$GetFiles = New-UDEndpoint -Schedule $Schedule -Endpoint {
    Get-Directories -Path $Cache:PesterFolder -ParentID $Cache:PesterFolder
}

$Endpoints += $GetFiles
$ei = New-UDEndpointInitialization -Function @('New-UDStaticTable','New-UDTestObject') 

$Dashboard = New-UDDashboard -Title "Pester Test $path" -Pages $pages -EndpointInitialization $ei 
Get-UDdashboard -Name MasterDash | Stop-UDDashboard  
Start-UDDashboard -Port 1001 -Dashboard $Dashboard -Name MasterDash -AutoReload -Endpoint $Endpoints