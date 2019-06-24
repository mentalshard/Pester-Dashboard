
Function New-PDCollapsibleGrid {
    [CmdletBinding(DefaultParameterSetName = "content")]
    param(
        [Parameter()]
        [String]$Id = (New-Guid)
        ,
        [Parameter()]
        [String]$Title
        ,
		[Parameter(ParameterSetName = "content")]
        [ScriptBlock]$Content
        ,
        [Parameter(ParameterSetName = "endpoint")]
        [ScriptBlock]$Endpoint
        ,
        [Parameter(ParameterSetName = "endpoint")]
        [Switch]$AutoRefresh
        ,
        [Parameter(ParameterSetName = "endpoint")]
        [int]$RefreshInterval = 5
        ,
		[Parameter()]
        [Switch]$Active
        ,
        [Parameter()]
        [UniversalDashboard.Models.DashboardColor]$BackgroundColor = 'White'
        ,
        [Parameter()]
        [UniversalDashboard.Models.DashboardColor]$FontColor = 'Black'
        ,
        [Parameter()]
        $Time
        ,
        [Parameter()]
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
            New-PDProgress -Percent $FailurePercent -Label $Title
        }
        if ($PSCmdlet.ParameterSetName -eq "content") {
            New-UDElement -Tag "div" -Attributes @{
                className = "collapsible-body"
            } -Content $Content -Id "$Id-body"
        }
        New-UDElement -Tag "time"  -Content {"$Time`s"}
    }
}