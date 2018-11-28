$Endpoints = @()
$Schedule = New-UDEndpointSchedule -Every 1 -Minute

# Set Configuration and initialize Cache Variables
$Cache:PesterFolder = '.\Pester Test Dir\'
$Cache:SiteURL = 'http://localhost:1001'
$Cache:Filenames = @{}
$Cache:PageContent = @{}
$Cache:Directories = @{}
$Cache:TestResults = @{}
$Cache:TestGridData = @{}

# Setup Functions
Function Add-TestStaticCharts {
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
}

Function Set-CachedGridData {
    Param ($xml)
    Foreach ($t in $xml.'test-results'.'test-suite'.results.'test-suite'){
        $Guid = (New-Guid).guid
        @{$t.name= $Guid}
        $Cache:TestGridData.Add($Guid,$($t.results.'test-case' | Select-Object Description, Result | Out-UDGridData))
    }
}

Function Set-CachedPages {
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
        $Cache:TestResults.Add($($Url+$Filename),(Set-CachedGridData -xml $xml))
        $Cache:PageContent.Add($($url+$Filename),(Add-TestStaticCharts -XML $xml))

    }
}


Function Initialize-CachePages {
    Param (
        $Path
        , 
        $ParentID
    )
    Push-Location -Path $Path
    $Path = Get-Location
    Pop-Location
    Foreach ($Directory in  (Get-ChildItem -path $Path -Directory)){
        $DirID = $($Directory | Resolve-Path -Relative).Substring(1).Replace(' ','').Replace('\','-')
        $Cache:Directories.Add($DirID,(
            New-Object psobject -Property @{
                Directory = $Directory.name;
                Parent = $Directory.Parent.Name;
                DirID = $dirID;
                ParentID = $ParentID;
                Children = $(Get-ChildItem -Path $Directory.FullName -Directory).count;
                TestCount = (Get-ChildItem -Path $Directory.FullName -Filter "*.xml").count;
            }
        ))
        Set-CachedPages -Path $Directory.FullName -DirID $DirID
        If (Get-ChildItem -path $Directory.FullName -Directory){
            Initialize-CachePages -Path $Directory.FullName -ParentID $DirID.Replace('Directory/','')
        }
        
    }
}


$GetFiles = New-UDEndpoint -Schedule $Schedule -Endpoint {
    Initialize-CachePages -Path $Cache:PesterFolder -ParentID $Cache:PesterFolder
}

$Endpoints += $GetFiles

$EndpointInitialization = New-UDEndpointInitialization -Function @('Add-TestStaticCharts','Initialize-CachePages','Set-CachedPages','Set-CachedGridData') 

$HomePage = . (Join-Path $PSScriptRoot "pages\home.ps1")
$FilePage = . (Join-Path $PSScriptRoot "pages\FilePage.ps1")
$DirectoryPage = . (Join-Path $PSScriptRoot "pages\DirectoryPage.ps1")

$Pages = @($HomePage, $DirectoryPage, $FilePage)
$Dashboard = New-UDDashboard -Title "Pester Test $path" -Pages $Pages -EndpointInitialization $EndpointInitialization
Get-UDdashboard -Name PesterDashboard | Stop-UDDashboard  
Start-UDDashboard -Port 1001 -Dashboard $Dashboard -Name PesterDashboard -AutoReload -Endpoint $Endpoints