New-UDPage -Url "/File/:FilePath" -Endpoint {
    Param ($FilePath)
    New-UDCard -Content {
        [Array]$Breadcrumbs = New-BreadCrumbLinks -directorypath $FilePath -File
        New-UDLink -Text 'Home' -Url "/Home/" 
        ' / '
        Foreach ($Crumb in ($Breadcrumbs | Sort-Object -Descending )){
            Write-Output $Crumb
            If ($Breadcrumbs.indexof($Crumb) -ne 0){
                Write-Output ' /'
            }
        }
    }
    # Load static charts from cache
    $Cache:PageContent.item($FilePath)
    # Generate some elements and load grid data from cache
    $rowGUID = (New-Guid).Guid
    New-UDRow -Id $rowGUID {
        Foreach ($t in $Cache:TestResults.Item($FilePath)){
            New-UDCard -Content {
                New-UDCollapsible -Popout -Items {
                    New-UDCollapsibleItem -Title $($t.keys) -Icon crosshairs -Content {
                        New-UDGrid <#-Title $($t.keys)#> -Headers @('Test Name','Status','Error Message') -Properties @('description','result','failmessage') -Endpoint {
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