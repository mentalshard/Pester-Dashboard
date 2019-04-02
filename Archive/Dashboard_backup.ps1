$path = '.\test.xml'
[xml]$xml = Get-Content -path $path

#$xml.'test-results'.'test-suite'

$Cache:TestResults = @{}

Function New-TestTableContent {
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
                    #New-UDElement -Tag 'tbody' -Endpoint $Endpoint -AutoRefresh:$AutoRefresh -RefreshInterval $RefreshInterval
            } -Attributes @{ className = $Style }
        }
            $Actions
    }
}
    

#$ei = New-UDEndpointInitialization -Function 'New-TestTable'

Function New-UDTestObject {
    Param ([psobject[]]$test, $guid)

    #$Cache:Tests = @{$guid = $test}
    Foreach ($t in $test){
        #$Cache:t2 = @{$t.name, $t}
        New-UDCard -Endpoint {
            New-UDCollapsible -Items {
                New-UDCollapsibleItem -Title $T.Name -Icon check -Endpoint {
                    #$Cache:TestResults.Add($t.name,$t.results.'test-case')
                    #New-UDTable -Headers @(' ',' ') -Title ' ' -Id $t.name -Endpoint {
                        #$Cache:TestResults.Item($t.name) | Select-Object description, result  | Out-UDTableData -Property @('description','result')
                        #$t.results.'test-case' | Select-Object description, result  | Out-UDTableData -Property @('description','result')
                    #} 
                    New-TestTable -testobj $t
                }
            }
        }
    }    
}
$pages = @()
#New-UDTestObject -test $xml.'test-results'.'test-suite'.results.'test-suite'
$Page = New-UDPage -Name "test" -Content {
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
        #New-UDTestObject -test $xml.'test-results'.'test-suite'.results.'test-suite'
        #New-UDTestObject -test $xml.'test-results'.'test-suite'.results.'test-suite'[1]
        $cache:hash = @{}
        Foreach ($t in $xml.'test-results'.'test-suite'.results.'test-suite'){
            $cache:hash.add($t.name,$t)
            New-UDCard -Content {
                New-UDCollapsible -Items {
                    
                    
                    $title = $t.name
                    New-UDCollapsibleItem -Title $title -Icon check -Content {
                        New-TestTableContent -Headers @('test1 ','test2 ') -Title $title -Content {
                           $t.results.'test-case' | Select-Object description, result | Out-UDTableData -Property @('description','result')
                        }
                        <#New-UDTable -Headers @(' ',' ') -Title $title  -Endpoint {
                            $cache:hash.item($title).results.'test-case' | Select-Object description, result  | Out-UDTableData -Property @('description','result')
                        } #>
                    }
                }
            }
        } 
    }
    




# pass percentage (tests) bar
# Each Test in UD Grid 
} 

$pages += $page
$Dashboard = New-UDDashboard -Title "Pester Test $path" -Pages $pages -EndpointInitialization $ei 
Get-UDdashboard -Name PesterTest | Stop-UDDashboard  
Start-UDDashboard -Port 1001 -Dashboard $Dashboard -Name PesterTest -AutoReload 