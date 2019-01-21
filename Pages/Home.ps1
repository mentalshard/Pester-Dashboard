New-UDPage -Name 'Home' -Content {
    New-UDCard -Content {
        New-UDLink -Text 'Home' -Url "/Home/" 
    }
    New-UDGrid -Title 'Child Directories' -Headers @('Name', 'Child Directory Count','Test Count') -Properties @('Link','Children','TestCount') -Endpoint {
        $($Cache:Directories.GetEnumerator()).value | Where-object {$_.parent -eq 'Pester test dir' -and $_.TestCount -ne 0} | ForEach-Object {
            $_ | Select-Object @{Name='Link'; Expression={New-UDLink -Text $_.Directory -Url "$Cache:SiteURL/Directory/$($_.DirID)"}}, Children, TestCount
        } | Out-UDGridData
    }
    If($Cache:Filenames.ContainsKey($Cache:PesterFolder)){
        New-UDGrid -Title 'Tests files in this folder' -Headers @('Name', 'Successful Tests','Failed Tests', 'Fixture Count') -Properties @('Link','Successful','Failures','FixtureCount') -Endpoint {
            $Cache:Filenames.Item($Cache:PesterFolder) | ForEach-Object { $_ | Select-Object Successful, FixtureCount, Failures, @{Name='Link'; Expression={New-UDLink -Text $([System.Web.HttpUtility]::Urldecode($_.Filename)) -Url "$Cache:SiteURL/File/$($_.url)$($_.filename)"}}
                } | Out-UDGridData
        }
    }
}