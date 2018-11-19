New-UDPage -Name 'Home' -Content {
    New-UDParagraph -Text "Top level folder $Cache:PesterFolder"
    New-UDGrid -Title 'Child Directories' -Headers @('Name', 'Child Directory Count') -Properties @('Link','Children') -Endpoint {
        $($Cache:Directories.GetEnumerator()).value | Where-object {$_.parent -eq 'Pester test dir'} | ForEach-Object {
            $_ | Select-Object @{Name='Link'; Expression={New-UDLink -Text $_.Directory -Url "$Cache:SiteURL/Directory/$($_.DirID)"}}, Children
        } | Out-UDGridData
    }
    If($Cache:Filenames.ContainsKey($Cache:PesterFolder)){
        New-UDGrid -Title 'Tests in this folder' -Headers @('Name', 'Successful Tests','Failed Tests', 'Fixture Count') -Properties @('Link','Successful','Failures','FixtureCount') -Endpoint {
            $Cache:Filenames.Item($Cache:PesterFolder) | ForEach-Object { $_ | Select-Object Successful, FixtureCount, Failures, @{Name='Link'; Expression={New-UDLink -Text $([System.Web.HttpUtility]::Urldecode($_.Filename)) -Url "$Cache:SiteURL/File/$($_.url)$($_.filename)"}}
                } | Out-UDGridData
        }
    }
}