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
Function New-BreadCrumbLinks {
    param (
        $DirectoryPath
        ,
        [Switch]$File
        )
    #Wait-Debugger
    $output = @()
    $CurrentPath = $directorypath #.Substring(2,$directorypath.length - 2)
    $DirectoryArray = $CurrentPath -split '--'
    $Directories = @()
    $DirectoryArray[1..$DirectoryArray.length] | foreach-object {
        If ($currentPath -match '--'){
            $Directories += $currentPath
            $CurrentPath = $CurrentPath.Substring(0,$CurrentPath.LastIndexOf('--'))
        }
    }

    
    Foreach ($D in $Directories | Sort-Object -Descending){
        $LinkedItem = $Cache:Directories.item($D)
        If ($null -eq $LinkedItem -and ($File)){
            $Filename = $directorypath.Substring($directorypath.LastIndexOf('--'),$directorypath.Length -$directorypath.LastIndexOf('--'))
            $LinkedItem = $Cache:Filenames.item($d.substring(0,$d.lastindexof('--'))) | Where-Object {$_.Filename -eq $Filename.replace('--','')}
            $output += New-UDLink -Text $([System.Web.HttpUtility]::UrlDecode($LinkedItem.Filename)) -Url "/File/$($D)"
        } Else {
            $output += New-UDLink -Text $LinkedItem.Directory -Url "/directory/$($LinkedItem.DirID)"
        }
    }
    Write-Output $output
}
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
        @{$t.name = $Guid}
        $Cache:TestGridData.Add($Guid,$($t.results.'test-case' | Select-Object Description, Result, @{Name='failmessage';Expression={$_.failure.message + ' ' + $_.failure.'stack-trace'}}  | Out-UDGridData))
    }
}

Function Set-CachedPages {
    Param (
        $Path, $DirID
    )
    #Wait-Debugger
    $XMLFiles = Get-ChildItem -Path $path -Filter '*.xml'
    $XMLContent = @()
    Foreach ($XMLFile in $XMLFiles){
       [xml]$xml = Get-Content -Path $XMLFile.FullName
       $ID = (New-Guid).Guid
       $Directory = [System.Web.HttpUtility]::UrlEncode($xmlfile.Directory.Name)
       $Filename = [System.Web.HttpUtility]::UrlEncode($($XMLFile.Name.Replace('.xml','')))
       $Url = $DirID

       $XMLContent += New-Object psobject -Property @{
           FileID = $ID
           URL = $Url
           Directory = $Directory
           Filename = $Filename
           Successful = $($xml.'test-results'.total - $xml.'test-results'.failures)
           Failures = $xml.'test-results'.failures
           FixtureCount = $xml.'test-results'.total
       }
       $Cache:TestResults.Add($($Url+'--'+$Filename),(Set-CachedGridData -xml $xml))
       $Cache:PageContent.Add($($url+'--'+$Filename),(Add-TestStaticCharts -XML $xml))
   }
   $Cache:Filenames.Add($url,$XMLContent)
    <#Foreach ($XMLFile in $XMLFiles){
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
        $Cache:TestResults.Add($($Url+'--'+$Filename),(Set-CachedGridData -xml $xml))
        $Cache:PageContent.Add($($url+'--'+$Filename),(Add-TestStaticCharts -XML $xml))

    }#>
}


Function Initialize-CachePages {
    Param (
        $Path
        , 
        $ParentID
    )
    If ($Path -eq $Cache:PesterFolder){
        Set-location $Cache:PesterFolder
    }
    Push-Location -Path $Path
    $Path = Get-Location
    Pop-Location
    Foreach ($Directory in  (Get-ChildItem -path $Path -Directory)){
        $DirID = $($Directory | Resolve-Path -Relative).Substring(1).Replace(' ','').Replace('\','--')
        $Cache:Directories.Add($DirID,(
            New-Object psobject -Property @{
                Directory = $Directory.name;
                Parent = $Directory.Parent.Name;
                DirID = $DirID;
                ParentID = $ParentID;
                Children = $(Get-ChildItem -Path $Directory.FullName -Directory).count;
                TestCount = (Get-ChildItem -Path $Directory.FullName -Filter "*.xml").count;
            }
        ))
        Set-CachedPages -Path $Directory.FullName -DirID $DirID
        If (Get-ChildItem -Path $Directory.FullName -Directory){
            Initialize-CachePages -Path $Directory.FullName -ParentID $DirID.Replace('Directory/','')
        }
        
    }
}


$GetFiles = New-UDEndpoint -Schedule $Schedule -Endpoint {
    Initialize-CachePages -Path $Cache:PesterFolder -ParentID $Cache:PesterFolder
}

$Theme = New-UDTheme -Name "Standard" -Definition @{
    UDDashboard = @{
        BackgroundColor = "#efefef"
        FontColor = "rgb(0, 0, 0)"
    }
    UDInput = @{
        BackgroundColor = "rgb(255,255,255)"
        FontColor = "rgb(0, 0, 0)"
    }
    UDNavBar = @{
        BackgroundColor = "#00bcd4"
        FontColor = "rgb(0, 0, 0)"
    }
    UDFooter = @{
        BackgroundColor = "#62efff"
        FontColor = "rgb(0, 0, 0)"
    }
    UDCard = @{
        BackgroundColor = "#62efff"
        FontColor = "rgb(0, 0, 0)"
    }
    UDChart = @{
       # BackgroundColor = "#ffad42"
       # FontColor = "rgb(0, 0, 0)"
    }
    UDGrid = @{
        BackgroundColor = "rgb(255,255,255)"
        FontColor = "rgb(0, 0, 0)"
    }
    <#
    UDCounter = @{
        BackgroundColor = "rgb(255,255,255)"
        FontColor = "rgb(0, 0, 0)"
    }
    UDMonitor = @{
        BackgroundColor = "rgb(255,255,255)"
        FontColor = "rgb(0, 0, 0)"
    }
    
    UDTable = @{
        BackgroundColor = "rgb(255,255,255)"
        FontColor = "rgb(0, 0, 0)"
    }#>
    
} -Parent "default"

$Endpoints += $GetFiles

$EndpointInitialization = New-UDEndpointInitialization -Function @('Add-TestStaticCharts','Initialize-CachePages','Set-CachedPages','Set-CachedGridData','New-BreadCrumbLinks') 

$HomePage = . (Join-Path $PSScriptRoot "pages\home.ps1")
$FilePage = . (Join-Path $PSScriptRoot "pages\FilePage.ps1")
$DirectoryPage = . (Join-Path $PSScriptRoot "pages\DirectoryPage.ps1")

$Pages = @($HomePage, $DirectoryPage, $FilePage)
$Dashboard = New-UDDashboard -Title "Pester Test $path" -Pages $Pages -EndpointInitialization $EndpointInitialization -Theme $Theme
Get-UDdashboard -Name PesterDashboard | Stop-UDDashboard  
Start-UDDashboard -Port 1001 -Dashboard $Dashboard -Name PesterDashboard -AutoReload -Endpoint $Endpoints