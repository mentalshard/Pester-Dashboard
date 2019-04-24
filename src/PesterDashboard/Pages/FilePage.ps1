New-UDPage -Url "/File/:FilePath" -Endpoint {
    Param ($FilePath)
    
    New-UDCard -Content {
        New-PDBreadCrumbLinks -directorypath $FilePath -File
    }
    $Cache:PageContent.item($FilePath)

}