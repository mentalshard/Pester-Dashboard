# Directory Page
New-UDPage -Url "/Directory/:Dir/"  -Endpoint {
    Param ($Dir)
    $Directory = $Cache:Directories.item($dir)
    New-UDParagraph -Content {"$($Directory.Parent) > $($directory.directory)"}
    New-UDRow {
        New-UDGrid -Title "Child Directories"  -Headers @('Name', 'Child Directory Count') -Properties @('Link','Children') -Endpoint {
            $($Cache:Directories.getenumerator()).value.where{$_.parentid -eq $dir} | Select-Object Children, @{Name='Link'; Expression={New-udlink -Text $_.Directory -Url "$Cache:SiteURL/Directory/$($_.DirID)"}}| Out-UDGridData
        }
    }
    If($Cache:Filenames.ContainsKey($dir)){
        New-UDRow {
            New-UDGrid -Title 'Tests in this folder' -Headers @('Name', 'Successful Tests','Failed Tests', 'Fixture Count') -Properties @('Link','Successful','Failures','FixtureCount') -Endpoint {
                $Cache:Filenames.Item($dir) | ForEach-Object { $_ | Select-Object Successful, FixtureCount, Failures, @{Name='Link'; Expression={New-UDLink -Text $([System.Web.HttpUtility]::Urldecode($_.Filename)) -Url "$Cache:SiteURL/File/$($_.url)$($_.filename)"}}
                } | Out-UDGridData
            }
        }
    }
}
