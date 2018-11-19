New-UDPage -Url "/File/:FilePath" -Endpoint {
    Param ($FilePath)
    
    #Wait-Debugger
    $Cache:PageContent.item($FilePath)
    
}
#$filepath = 'pester%20test%20dir/Run%20daily%208.23.2015'