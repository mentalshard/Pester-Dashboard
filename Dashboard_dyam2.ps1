$path = '.\test.xml'
[xml]$xml = Get-Content -path $path
$Endpoints = @()

$path = '.\'
$Schedule = New-UDEndpointSchedule -Every 1 -Minute


#$Cache:Filenames = @()
$Cache:Filenames = @{}
$Cache:PageContent = @{}

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


$GetFiles = New-UDEndpoint -Schedule $Schedule -Endpoint {
    Foreach ($Directory in $Path)
    $XMLFiles = Get-ChildItem -Path $path -Filter '*.xml' -Recurse
    Foreach ($XMLFile in $XMLFiles){
        [xml]$xml = Get-Content -Path $XMLFile.FullName
        $ID = (New-Guid).Guid
        $Directory = [System.Web.HttpUtility]::UrlEncode($xmlfile.Directory.Name)
        $Filename = [System.Web.HttpUtility]::UrlEncode($($XMLFile.Name.Replace('.xml','')))
        $Url = "/$Directory/$filename"
        
        <#$Cache:Filenames += New-Object psobject -Property @{
            ID = $ID
            URL = $Url
            Successful = $($xml.'test-results'.total - $xml.'test-results'.failures)
            Failures = $xml.'test-results'.failures
            FixtureCount = $xml.'test-results'.total
            Link = New-UDLink -Text $Filename -Url $Url
        }#>
        $Cache:Filenames.Add($url,(New-Object psobject -Property @{
            ID = $ID
            URL = $Url
            Directory = $Directory
            Filename = $Filename
            Successful = $($xml.'test-results'.total - $xml.'test-results'.failures)
            Failures = $xml.'test-results'.failures
            FixtureCount = $xml.'test-results'.total
            Link = New-UDLink -Text $Filename -Url $Url
            }
        ))
        
        $Cache:PageContent.Add($ID,(New-UDTestObject -XML $xml))

    }
}

$Endpoints += $GetFiles


$pages = @()
$page = New-UDPage -Name 'Home' -Content {
    Foreach ($Dir in $Cache:Filenames.getEnumerator() | Group-Object Directory){}
    New-UDCard -Content {
        New-UDGrid -Title 'Select Pester' -Headers @('Name', 'Successful Tests','Failed Tests', 'Fixture Count') -Properties @('Link','Successful','Failures','FixtureCount') -Endpoint {
            $($Cache:Filenames.GetEnumerator()).value | ForEach-Object { $_ | Select-Object Successful, FixtureCount, Failures, Link
            } | Out-UDGridData 
        }
    }
}
$pages += $page

$DynamPage = New-UDPage -Url "/:Dir/:File" -Endpoint {
    Param ($Dir, $File)
    $url = "/$dir/$file"
   # Wait-Debugger
    $Cache:PageContent.item($($Cache:Filenames.item($URL).ID))
    
} 
$pages += $DynamPage 

$ei = New-UDEndpointInitialization -Function @('New-UDStaticTable','New-UDTestObject') 

$Dashboard = New-UDDashboard -Title "Pester Test $path" -Pages $pages -EndpointInitialization $ei 
Get-UDdashboard -Name PesterTest | Stop-UDDashboard  
Start-UDDashboard -Port 1001 -Dashboard $Dashboard -Name PesterTest -AutoReload -Endpoint $Endpoints