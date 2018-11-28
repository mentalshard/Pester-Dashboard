New-UDPage -Url "/File/:FilePath" -Endpoint {
    Param ($FilePath)

    # Load static charts from cache
    $Cache:PageContent.item($FilePath)
    # Generate some elements and load grid data from cache
    New-UDRow -Id $rowGUID {
        Foreach ($t in $Cache:TestResults.Item($FilePath)){
            New-UDCard -Content {
                New-UDCollapsible -Items {
                    New-UDCollapsibleItem -Title $($t.keys) -Icon crosshairs -Content {
                        New-UDGrid -Title $($t.keys) -Headers @('Test Name','Status') -Properties @('description','result') -Endpoint {
                            # Casting the ID to string to ensure the right type
                            [string]$ID = $t.values
                            $($Cache:TestGridData.Item($ID))
                        }
                    }
                }
            }
        } 
    }
}