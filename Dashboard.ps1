$path = '.\test.xml'
[xml]$xml = Get-Content -path $path


Get-UDdashboard -Name PesterTest | Stop-UDDashboard 

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


    $ei = New-UDEndpointInitialization -Function 'New-UDStaticTable' 
$Cache:TestResults = @{}


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
    $rowGUID = (New-Guid).Guid
    New-UDRow -Id $rowGUID {
        Foreach ($t in $xml.'test-results'.'test-suite'.results.'test-suite'){
            New-UDCard -Content {
                New-UDCollapsible -Items {
                    New-UDCollapsibleItem -Title $($t.name) -Icon crosshairs -Content {
                        New-UDStaticTable -Headers @('Test Name','Status') -Title ' ' -Content {
                            $t.results.'test-case' | Select-Object description, result | Out-UDTableData -Property @('description','result')
                        }
                        #Need to modify New-UDgrid to accept content instead of just endpoint.
                        <#New-UDGrid -Title $Title -Headers @('Test Name','Status') -Property @('description','result') -Endpoint {
                            $t.results.'test-case' | Select-Object description, result | Out-UDGridData
                        }#>
                    }
                }
            }
        } 
    }
}


$pages = @()
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
                    display = $false;
                }
            }
        }
    }
    $rowGUID = (New-Guid).Guid
    New-UDRow -Id $rowGUID {
        Foreach ($t in $xml.'test-results'.'test-suite'.results.'test-suite'){
            New-UDCard -Content {
                New-UDCollapsible -Items {
                    New-UDCollapsibleItem -Title $($t.name) -Icon crosshairs -Content {
                        New-udrow -endpoint {
                            New-UDColumn -Content {
                                New-UDStaticTable -Headers @('Test Name','Status') -Title ' ' -Content {
                                    $t.results.'test-case' | Select-Object description, result, @{Name='Image';Expression={
                                            New-UDParagraph -Content {
                                                $_.failure.message 
                                                $_.failure.'stack-trace'
                                            }
                                        } | Out-UDTableData -Property @('description','result', 'Image')
                                    }
                                }
                            }
                            New-UDColumn -Content {
                                $Passed = ($t.results.'test-case' | Group-Object success).Where{$_.Name -eq 'True'}.count
                                $Failed = ($t.results.'test-case' | Group-Object success).Where{$_.Name -ne 'True'}.count
                                $totaltests = ($t.results.'test-case' | measure-object).count
                                $Info = New-object psobject -Property @{
                                    TotalTime = ($t.results.'test-case' | measure-object time -sum).sum
                                    TotalTests = $totaltests
                                    TotalAsserts = ($t.results.'test-case' | measure-object asserts -sum).sum
                                    Passed = $Passed
                                    PassPercent = ($Passed/$totaltests)
                                    Failed = $Failed
                                    FailPercent = ($Failed/$totaltests)
                                    
                                }
                                New-UDHtml -Markup "<h5>Test Stats:</h5>"
                                New-UDParagraph -Text "Total Time: $($info.totaltime)"
                                New-UDParagraph -Text "Total Tests: $($info.TotalTests)"
                                New-UDParagraph -Text "Total Asserts: $($info.TotalAsserts)"
                                
                                New-UDChart -Type Doughnut -Labels 'test' -Height 150px -Width 150px -Endpoint {
                                    $t.results.'test-case' | ForEach-Object {
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
                                    } | Group-Object -property 'Type' | Sort-Object | Out-UDChartData -DataProperty "Count" -LabelProperty "Name"
                                } -Options @{
                                    legend = @{
                                        display = $false;
                                    }
                                }
                            }
                        }
                    
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
Start-UDDashboard -Port 1002 -Dashboard $Dashboard -Name PesterTest -AutoReload 