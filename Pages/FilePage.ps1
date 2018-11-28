New-UDPage -Url "/File/:FilePath" -Endpoint {
    Param ($FilePath)
    
    #Wait-Debugger
    $Cache:PageContent.item($FilePath)
    New-UDRow -Id $rowGUID {
        Foreach ($t in $Cache:TestResults.Item($FilePath)){ 
        #$xml.'test-results'.'test-suite'.results.'test-suite'){
            New-UDCard -Content {
                New-UDCollapsible -Items {
                    New-UDCollapsibleItem -Title $($t.keys) -Icon crosshairs -Content {
                        #New-UDStaticTable -Headers @('Test Name','Status') -Title ' ' -Content {
                        #    $t.results.'test-case' | Select-Object description, result | Out-UDTableData -Property @('description','result')
                        #}
                        #Need to modify New-UDgrid to accept content instead of just endpoint.
                        New-UDGrid -Title $($t.keys) -Headers @('Test Name','Status') -Properties @('description','result') -Endpoint {
                            
                            [string]$Title = $t.values
                            #Wait-Debugger
                            $($Cache:TestGridData.Item($Title))
                        }
                    }
                }
            }
        } 
    }
}