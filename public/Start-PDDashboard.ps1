Param (
    [string]$PesterOutputDir = '.\Pester Test Dir\'
    ,
    [string]$Port = '1001'
    ,
    [string]$SiteURL = 'http://localhost:1001'
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


$GetFiles = New-UDEndpoint -Schedule $Schedule -Endpoint {
    Initialize-PDCachePages -Path $Cache:PesterFolder -ParentID $Cache:PesterFolder
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

$Endpoints += $GetFiles

$EndpointInitialization = New-UDEndpointInitialization -Function 'Initialize-PDCachePages','Set-PDCachedPages','New-PDBreadCrumbLinks','new-PDCollapsibleGrid','New-PDProgress'

$HomePage = . (Join-Path $PSScriptRoot "pages\home.ps1")
$FilePage = . (Join-Path $PSScriptRoot "pages\FilePage.ps1")
$DirectoryPage = . (Join-Path $PSScriptRoot "pages\DirectoryPage.ps1")

$Navigation = New-UDSideNav -None
$Pages = @($HomePage, $DirectoryPage, $FilePage)
$Dashboard = New-UDDashboard -Title "Pester Test $path" -Pages $Pages -EndpointInitialization $EndpointInitialization -Theme $Theme -Navigation $Navigation
Get-UDdashboard -Name PesterDashboard | Stop-UDDashboard  
Start-UDDashboard -Port 1001 -Dashboard $Dashboard -Name PesterDashboard -AutoReload -Endpoint $Endpoints