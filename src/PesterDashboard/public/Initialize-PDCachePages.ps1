Function Initialize-PDCachePages {
    Param (
        $Path
        , 
        $ParentID
    )
    If ($Path -eq $Cache:PesterFolder){
        Set-location $Cache:PesterFolder
    }
    Push-Location -Path $Path
    $Path = Get-Location
    Pop-Location
    Foreach ($Directory in  (Get-ChildItem -path $Path -Directory)){
        $DirID = $($Directory | Resolve-Path -Relative).Substring(1).Replace(' ','').Replace('\','--')
        $Cache:Directories.Add($DirID,(
            New-Object psobject -Property @{
                Directory = $Directory.name;
                Parent = $Directory.Parent.Name;
                DirID = $DirID;
                ParentID = $ParentID;
                Children = $(Get-ChildItem -Path $Directory.FullName -Directory).count;
                TestCount = (Get-ChildItem -Path $Directory.FullName -Filter "*.xml").count;
            }
        ))
        Set-PDCachedPages -Path $Directory.FullName -DirID $DirID
        If (Get-ChildItem -Path $Directory.FullName -Directory){
            Initialize-PDCachePages -Path $Directory.FullName -ParentID $DirID.Replace('Directory/','')
        }
        
    }
}