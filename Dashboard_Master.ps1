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
$Cache:PageData = @{}
# Setup Functions

Function New-PDProgress {
    param($Percent, $Label)

    New-UDElement -Tag "h5" -Content { $Label }

<#
    New-UDElement -Tag "div" -Attributes @{ className = "row" } -Content {
        #New-UDElement -Tag "span" -Attributes @{ className = "grey-text lighten-1" } -Content { "Fail $Percent%" }
        New-UDElement -Tag "div" -Attributes @{ className = 'grey ud-percentage progress-bar-striped' } -Content {
            New-UDElement -Tag "div" -Attributes @{ className = "progress-bar-striped determinate $color"; style = @{ width = "$Percent%"} } -Content {
                New-UDElement -Tag "span" -Attributes @{
                    className = 'centertext'
                } -Content {
                    "Fail $Percent%"
                }
            }
            
        }
    }#>
    New-UDElement -Tag "div" -Attributes @{ className = "percent-right" } -Content {
        New-UDElement -Tag "div" -Attributes @{
                className = "green"
                style = @{height = "100%"} 
            } -Content {
                New-UDElement -Tag "div" -Attributes @{ 
                    class = "red"
                    role = 'progressbar' 
                    style = @{ width = "$Percent%"}
                    'aria-valuenow' = "$Percent"
                    'aria-valuemin' = "0" 
                    'aria-valuemax' = "100"
                } -Content {
                        "Fail $Percent%"
                } 
        }
    }

<#
    New-UDElement -Tag "div" -Attributes @{ className = "row ud-percentage" } -Content {
        New-UDElement -Tag "span" -Attributes @{ className = "Progress" } -Content {
            New-UDElement -Tag "div" -Attributes @{
                className = 'progress-bar progress-bar-warning progress-bar-striped';
                role = 'progressbar';
                'aria-valuenow'="50";
                'aria-valuemin'="0";
                'aria-valuemax'="100";
                style = @{width = "50%"}
            } -Content {
                #"Fail $Percent%"
                New-UDElement -Tag "div" -Attributes @{ className = "determinate $color"; style = @{ width = "$Percent%"} } -Content {
                    New-UDElement -Tag "P" -Attributes @{
                        className = 'centertext'
                    } -Content {
                        "Fail $Percent%"
                    }
                }
            }
        }
    }
    #>
    
    <#New-UDElement -Tag "div" -Attributes @{ className = 'progress grey ud-percentage' } -Content {
        New-UDElement -Tag "div" -Attributes @{ className = "determinate $color"; style = @{ width = "$Percent%"} }
    } #>
       
}

Function New-PDCollapsibleGrid {
    [CmdletBinding(DefaultParameterSetName = "content")]
    param(
        [Parameter()]
        [String]$Id = (New-Guid),
        [Parameter()]
		[String]$Title,
		#[Parameter()]
	    #[UniversalDashboard.Models.FontAwesomeIcons]$Icon,
		[Parameter(ParameterSetName = "content")]
        [ScriptBlock]$Content,
        [Parameter(ParameterSetName = "endpoint")]
        [ScriptBlock]$Endpoint,
        [Parameter(ParameterSetName = "endpoint")]
        [Switch]$AutoRefresh,
        [Parameter(ParameterSetName = "endpoint")]
		[int]$RefreshInterval = 5,
		[Parameter()]
        [Switch]$Active,
        [Parameter()]
        [UniversalDashboard.Models.DashboardColor]$BackgroundColor = 'White',
        [Parameter()]
        [UniversalDashboard.Models.DashboardColor]$FontColor = 'Black',
        $Time,
        $FailurePercent
    )

    $liClassName = "ud-collapsible-item"
    $itemClassName = "collapsible-header" 

    if ($Active) {
        $liClassName += " active"
        $itemClassName += " active"
    }

    New-UDElement -Tag "li" -id $Id -Attributes @{
        style = @{
            backgroundColor = $BackgroundColor.HtmlColor
            color = $FontColor.HtmlColor
        }
        className = $liClassName
    } -Content {
        New-UDElement -Tag "div" -Attributes @{
            className = $itemClassName 
            style = @{
                backgroundColor = $BackgroundColor.HtmlColor
                color = $FontColor.HtmlColor
            }
        } -Id "$Id-header" -Content {
            # put in pester percentage
            <#if ($PSBoundParameters.ContainsKey("Icon")) {
                New-UDIcon -Icon $Icon -Id "$Id-icon"
            } #>
            #Wait-Debugger
            New-PDProgress -Percent $FailurePercent -Label $Title
            #
        }
        if ($PSCmdlet.ParameterSetName -eq "content") {
            New-UDElement -Tag "div" -Attributes @{
                className = "collapsible-body"
            } -Content $Content -Id "$Id-body"
        }
        New-UDElement -Tag "time"  -Content {"$Time`s"}
        
        <#
        else {
            New-UDElement -Tag "div" -Attributes @{
                className = "collapsible-body"
            } -Endpoint $Endpoint -AutoRefresh:$AutoRefresh -RefreshInterval $RefreshInterval -Id "$Id-body"
        }#>
    }
}

Function New-BreadCrumbLinks {
    param (
        $DirectoryPath
        ,
        [Switch]$File
        )
    $Directories = @()
    $CurrentPath = $directorypath
    $DirectoryArray = $CurrentPath -split '--'
    $DirectoryArray[1..$DirectoryArray.length] | foreach-object {
        If ($currentPath -match '--'){
            $Directories += $currentPath
            $CurrentPath = $CurrentPath.Substring(0,$CurrentPath.LastIndexOf('--'))
        }
    }

    New-UDLink -Text 'Home' -Url "/Home" 
    Write-Output ' / '

    Foreach ($D in $Directories | Sort-Object){
        $LinkedItem = $Cache:Directories.item($D)
        If ($null -eq $LinkedItem -and ($File)){
            $Filename = $directorypath.Substring($directorypath.LastIndexOf('--'),$directorypath.Length -$directorypath.LastIndexOf('--'))
            $LinkedItem = $Cache:Filenames.item($d.substring(0,$d.lastindexof('--'))) | Where-Object {$_.Filename -eq $Filename.replace('--','')}
            New-UDLink -Text $([System.Web.HttpUtility]::UrlDecode($LinkedItem.Filename)) -Url "/File/$($D)" 
        } Else {
            New-UDLink -Text $LinkedItem.Directory -Url "/directory/$($LinkedItem.DirID)" 
        }
        If ($Directories.indexof($D) -ne 0){ # Output Separator / if not the last item
            Write-Output ' /'
        }
    }
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
        Wait-Debugger
        $Cache:TestEnvironmentData.Add()
        New-UDColumn {
            New-UDTable -Title 'Environment Information' -Headers @(" "," ") -Endpoint { #need to turn endpoint into content
                @{
                'User' = $xml.'test-results'.Environment.User
                'Machine-Name' = $xml.'test-results'.Environment.'machine-name'
                'Cwd' = $xml.'test-results'.Environment.cwd;
                'User-Domain' = $xml.'test-results'.Environment.'user-domain'
                'Platform' = $xml.'test-results'.Environment.platform
                'nunit-version' = $xml.'test-results'.Environment.'nunit-version'
                'OS-version' = $xml.'test-results'.Environment.'os-version'
                'clr-version' = $xml.'test-results'.Environment.'clr-version'
                }.GetEnumerator() | Out-UDTableData -Property @("Name","Value")
            }
            
        }
    }
}
#>



Function Set-CachedGridData {
    Param ($xml)
    Foreach ($t in $xml.'test-results'.'test-suite'.results.'test-suite'){
        #Wait-Debugger
        $Guid = (New-Guid).guid
        If (!($Fail = ($t.results.'test-case' | Where-object {$_.success -eq 'false'} | Measure-object).count)){
            $Fail = 0
        }
        If (!($Total = $t.results.'test-case'.count)){
            $Total = 1
        }

        @{$t.name = (
            New-Object psobject -Property @{
                Guid = $Guid;
                Time = $t.Time;
                FailPercent = [Math]::Round($Fail / $Total * 100);
            }
        )}
        $Cache:TestGridData.Add($Guid,$($t.results.'test-case' | Select-Object Description, Result, @{Name='failmessage';Expression={$_.failure.message + ' ' + $_.failure.'stack-trace'}}  | Out-UDGridData;))
    }
    
}



Function Set-CachedPages {
    Param (
        $Path, $DirID
    )
    
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
        $Cache:PageContent.Add(
            $($url+'--'+$Filename),(
                $(
                    Add-TestStaticCharts -XML $xml
                    New-UDRow {
                        Foreach ($test in (Set-CachedGridData -xml $xml)){
                            New-UDCard -Content {
                                New-UDCollapsible -Items {
                                    New-PDCollapsibleGrid -Title $($test.keys)  -xml $test -Content {
                                        New-UDGrid -Headers @('Test Name','Status','Error Message') -Properties @('description','result','failmessage') -Endpoint {
                                            [string]$ID = $test.values.guid
                                            $Cache:TestGridData.Item($ID)
                                        }
                                    }
                                }
                            }
                        } 
                    }
                )
            )
        )
    }
    $Cache:Filenames.Add($url,$XMLContent)
}

Function Set-ChartData {
    Param ($xml,$ID)
    $Cache:ChartData.Add($ID,$(
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
    ))
}


Function Set-CachedPages2 {
    Param (
        $Path, $DirID
    )
    
    $XMLFiles = Get-ChildItem -Path $path -Filter '*.xml'
    $XMLContent = @()
    Foreach ($XMLFile in $XMLFiles){

        $ID = (New-Guid).Guid
        $Url = $DirID
        $Directory = [System.Web.HttpUtility]::UrlEncode($xmlfile.Directory.Name)
        $Filename = [System.Web.HttpUtility]::UrlEncode($($XMLFile.Name.Replace('.xml','')))

        If ($Cache:PageData.ContainsKey($url) -eq $True){
            Continue
        }
        
        [xml]$xml = Get-Content -Path $XMLFile.FullName

        $XMLContent += New-Object psobject -Property @{
            FileID = $ID
            URL = $Url
            Directory = $Directory
            Filename = $Filename
            Successful = $($xml.'test-results'.total - $xml.'test-results'.failures)
            Failures = $xml.'test-results'.failures
            FixtureCount = $xml.'test-results'.total
        }
        
        $PageData = New-Object psobject -Property @{
            ChartData = New-Object psobject -Property @{
                Fixture = $(
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
                    } | Group-Object -property 'Type' | Sort-Object | Out-UDChartData -DataProperty "Count" -LabelProperty "Name" -BackgroundColor @('#F44336','#4CAF50') -HoverBackgroundColor @('#ff786e','#adc896')
                )
                TestSummary = $(
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
                    } | Group-Object -property 'Type' | Sort-Object | Out-UDChartData -DataProperty "Count" -LabelProperty "Name" -BackgroundColor @('#F44336','#4CAF50') -HoverBackgroundColor @('#ff786e','#adc896') 
                )
            }
            Environment = $(
                @{
                    'User' = $xml.'test-results'.Environment.User
                    'Machine-Name' = $xml.'test-results'.Environment.'machine-name'
                    'Cwd' = $xml.'test-results'.Environment.cwd;
                    'User-Domain' = $xml.'test-results'.Environment.'user-domain'
                    'Platform' = $xml.'test-results'.Environment.platform
                    'nunit-version' = $xml.'test-results'.Environment.'nunit-version'
                    'OS-version' = $xml.'test-results'.Environment.'os-version'
                    'clr-version' = $xml.'test-results'.Environment.'clr-version'
                }.GetEnumerator() | Out-UDTableData -Property @("Name","Value")
            )
            GridData = $(
                Foreach ($t in $xml.'test-results'.'test-suite'.results.'test-suite'){
                    If (!($Fail = ($t.results.'test-case' | Where-object {$_.success -eq 'false'} | Measure-object).count)){
                        $Fail = 0
                    }
                    If (!($Total = $t.results.'test-case'.count)){
                        $Total = 1
                    }
                                       
                    New-Object psobject -Property @{
                        Data = $t.results.'test-case' | Select-Object Description, Result, @{Name='failmessage';Expression={$_.failure.message + ' ' + $_.failure.'stack-trace'}} | Out-UDGridData;
                        Title = $t.name
                        Time = $t.time
                        FailurePercent = [Math]::Round($Fail / $Total * 100);
                    }
                }
            )
        }

        # Write Data Object to Cache
        $Cache:PageData.add($url,$PageData)

        #performance test options - is it faster to cache the page or just the data
        $Cache:PageContent.Add(
            $($url+'--'+$Filename),(
                $(
                    New-UDRow {
                        # Fixture summary (pass/fail/inconclusive) (Doughnut)
                        New-UDColumn {
                            <#Need to cache#>
                            New-UDChart -Type Doughnut -Title 'Fixture Summary' -Endpoint {
                                #Wait-Debugger
                                $Cache:PageData.Item($url).ChartData.Fixture
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
                        # Test Summary (Doughnut)
                        New-UDColumn {
                            New-UDChart -Type Doughnut -Title 'Test Summary' -Endpoint {
                                #Wait-Debugger
                                $Cache:PageData.Item($url).ChartData.TestSummary
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

                        New-UDColumn {
                            New-UDElement -Tag 'div' -Attributes @{className = "EnvironmentInfo"} -Content {
                                New-UDTable -Title 'Environment Information' -Headers @(" "," ") -Content {
                                    $PageData.Environment
                                }
                            }
                        }
                    }
                    New-UDRow {
                        Foreach ($test in $PageData.GridData){
                            New-UDCard -Content {
                                New-UDCollapsible -Popout -Items {
                                    New-PDCollapsibleGrid -Title $($test.title)  -Time $test.time -FailurePercent $test.FailurePercent -Content {
                                        New-UDGrid -Headers @('Test Name','Status','Error Message') -Properties @('description','result','failmessage') -Endpoint {
                                            $test.data
                                            #$Cache:PageData.Item($url).GridData
                                        }
                                    }
                                }
                            }
                        }
                    }
                )
            )
        )
    }
    $Cache:Filenames.Add($url,$XMLContent)
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
        Set-CachedPages2 -Path $Directory.FullName -DirID $DirID
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
        #BackgroundColor = "#62efff"
        #FontColor = "rgb(0, 0, 0)"
    }
    UDChart = @{
       # BackgroundColor = "#ffad42"
       # FontColor = "rgb(0, 0, 0)"
    }
    UDGrid = @{
        BackgroundColor = "rgb(255,255,255)"
        FontColor = "rgb(0, 0, 0)"
    }
    '.ud-percentage'=@{
        height = '100%'
    }
    '.centertext'=@{
        'text-align' = 'center'
    }
    '.percent-right'=@{
        height = '100%'
        Width = '250px'
        'text-align' = 'center'
        'white-space' = 'nowrap'
        'margin-left' = 'auto'
    }
    '.EnvironmentInfo' = @{
        'font-size' = '.8em'
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

$EndpointInitialization = New-UDEndpointInitialization -Function 'Add-TestStaticCharts','Initialize-CachePages','Set-CachedPages','Set-CachedGridData','New-BreadCrumbLinks','new-PDCollapsibleGrid','New-PDProgress' , 'set-CachedPages2'

$HomePage = . (Join-Path $PSScriptRoot "pages\home.ps1")
$FilePage = . (Join-Path $PSScriptRoot "pages\FilePage.ps1")
$DirectoryPage = . (Join-Path $PSScriptRoot "pages\DirectoryPage.ps1")

$Navigation = New-UDSideNav -None
$Pages = @($HomePage, $DirectoryPage, $FilePage)
$Dashboard = New-UDDashboard -Title "Pester Test $path" -Pages $Pages -EndpointInitialization $EndpointInitialization -Theme $Theme -Navigation $Navigation
Get-UDdashboard -Name PesterDashboard | Stop-UDDashboard  
Start-UDDashboard -Port 1001 -Dashboard $Dashboard -Name PesterDashboard -AutoReload -Endpoint $Endpoints