
Function Set-PDCachedPages {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$True)]
        [string]$Path
        ,
        [Parameter(Mandatory=$True)]
        [string]$DirID
    )

    $XMLFiles = Get-ChildItem -Path $path -Filter '*.xml'
    $XMLContent = @()
    Foreach ($XMLFile in $XMLFiles){
        $Url = $DirID
        $Directory = [System.Web.HttpUtility]::UrlEncode($xmlfile.Directory.Name)
        $Filename = [System.Web.HttpUtility]::UrlEncode($($XMLFile.Name.Replace('.xml','')))

        <#If ($Cache:PageData.ContainsKey($url) -eq $True){
            Continue
        }#>

        [xml]$xml = Get-Content -Path $XMLFile.FullName

        $XMLContent += New-Object psobject -Property @{
            FileID = (New-Guid).Guid
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
                        Foreach ($Test in $PageData.GridData){
                            New-UDCard -Content {
                                New-UDCollapsible -Popout -Items {
                                    New-PDCollapsibleGrid -Title $($Test.Title)  -Time $Test.Time -FailurePercent $Test.FailurePercent -Content {
                                        New-UDGrid -Headers @('Test Name','Status','Error Message') -Properties @('description','result','failmessage') -Endpoint {
                                            $Test.Data
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