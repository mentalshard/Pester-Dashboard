New-UDPage -Url "/File/:FilePath" -Endpoint {
    Param ($FilePath)
    Measure-Command {
    New-UDCard -Content {
        New-PDBreadCrumbLinks -directorypath $FilePath -File
    }
    $Cache:PageContent.item($FilePath)
} 
New-UDCard -Content {
    $time.TotalSeconds
}
}