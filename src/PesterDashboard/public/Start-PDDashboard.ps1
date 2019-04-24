Function Start-PDDashboard {
    Param (
    [string]$PesterOutputDir = '.\Pester Test Dir\'
    ,
    [string]$Port = '1001'
    ,
    [string]$SiteURL = 'http://localhost:1001'
    ,
    [int]$Timeout
)

$Endpoints = @()
$Schedule = New-UDEndpointSchedule -Every 1 -Minute

# Set Configuration and initialize Cache Variables
$Cache:PesterFolder = $PesterOutputDir
$Cache:SiteURL = $SiteURL
$Cache:Filenames = @{}
$Cache:PageContent = @{}
$Cache:Directories = @{}
$Cache:PageData = @{}


$GetFiles = New-UDEndpoint  -Schedule $Schedule -Endpoint {
    Initialize-PDCachePages -Path $Cache:PesterFolder -ParentID $Cache:PesterFolder
}
$Endpoints += $GetFiles

If ($null -ne $Timeout){
    $TimeoutSchedule = New-UDEndpointSchedule -Every $Timeout -Minute
    $ScheduledTimeout = New-UDEndpoint -Schedule $TimeoutSchedule -Endpoint {
        Stop-PDDashboard
    }
}
$Endpoints += $ScheduledTimeout

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
    
} -Parent "default"

$EndpointInitialization = New-UDEndpointInitialization -Module "$(Split-Path $PSScriptRoot -Parent)\PesterDashboard.psm1"

$HomePage = . (Join-Path $(Split-Path $PSScriptRoot -Parent) "Pages\home.ps1")
$FilePage = . (Join-Path $(Split-Path $PSScriptRoot -Parent) "Pages\FilePage.ps1")
$DirectoryPage = . (Join-Path $(Split-Path $PSScriptRoot -Parent) "Pages\DirectoryPage.ps1")

$Navigation = New-UDSideNav -None
$Pages = @($HomePage, $DirectoryPage, $FilePage)
$Dashboard = New-UDDashboard -Title "Pester Test $path" -Pages $Pages -EndpointInitialization $EndpointInitialization -Theme $Theme -Navigation $Navigation
Get-UDdashboard -Name PesterDashboard | Stop-UDDashboard
Start-UDDashboard -Port $Port -Dashboard $Dashboard -Name PesterDashboard -AutoReload -Endpoint $Endpoints
}