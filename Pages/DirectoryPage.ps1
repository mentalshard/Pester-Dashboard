# Directory Page

New-UDPage -Url "/Directory/:Dir/" -Endpoint {
    Param ($Dir)
    New-UDCard -Content {
        New-BreadCrumbLinks -directorypath $Dir
    }
    New-UDLayout -Columns 2 -Content {
        If ($($Cache:Directories.getenumerator()).value.where{$_.parentid -eq $dir -and $_.TestCount -ne 0} ) {
            New-UDGrid -Title "Child Directories"  -Headers @('Name', 'Child Directory Count','Test Count') -Properties @('Link','Children','TestCount') -Endpoint {
                $($Cache:Directories.getenumerator()).value.where{$_.parentid -eq $dir -and $_.TestCount -ne 0} | 
                    Select-Object Children, 
                        @{Name='Link'; Expression={New-udlink -Text $_.Directory -Url "$Cache:SiteURL/Directory/$($_.DirID)"}}, 
                        TestCount | 
                        Out-UDGridData
            }
        } Else {
            New-UDCard -Title 'Child Directories' -Content {
                New-UDParagraph -Text "This folder contains no children"
            }
        }
        #Wait-Debugger
        If($Cache:Filenames.ContainsKey($dir)){
            New-UDGrid -Title 'Test files in this folder' -Headers @('Name', 'Successful Tests','Failed Tests', 'Fixture Count') -Properties @('Link','Successful','Failures','FixtureCount') -Endpoint {
                $Cache:Filenames.Item($dir) | ForEach-Object { $_ | Select-Object Successful, FixtureCount, Failures, @{Name='Link'; Expression={New-UDLink -Text $([System.Web.HttpUtility]::Urldecode($_.Filename)) -Url "$Cache:SiteURL/File/$($_.url)--$($_.filename)"}}
                } | Out-UDGridData
            }
        }
    }
}
