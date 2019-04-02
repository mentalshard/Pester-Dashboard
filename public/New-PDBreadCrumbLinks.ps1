Function New-PDBreadCrumbLinks {
    param (
        $DirectoryPath
        ,
        [Switch]$File
        )
    $Directories = @()
    $CurrentPath = $directorypath
    $DirectoryArray = $CurrentPath -split '--'
    $DirectoryArray[1..$DirectoryArray.length] | foreach-object {
        If ($currentPath -match '--'){
            $Directories += $currentPath
            $CurrentPath = $CurrentPath.Substring(0,$CurrentPath.LastIndexOf('--'))
        }
    }

    New-UDLink -Text 'Home' -Url "/Home" 
    Write-Output ' / '

    Foreach ($D in $Directories | Sort-Object){
        $LinkedItem = $Cache:Directories.item($D)
        If ($null -eq $LinkedItem -and ($File)){
            $Filename = $directorypath.Substring($directorypath.LastIndexOf('--'),$directorypath.Length -$directorypath.LastIndexOf('--'))
            $LinkedItem = $Cache:Filenames.item($d.substring(0,$d.lastindexof('--'))) | Where-Object {$_.Filename -eq $Filename.replace('--','')}
            New-UDLink -Text $([System.Web.HttpUtility]::UrlDecode($LinkedItem.Filename)) -Url "/File/$($D)" 
        } Else {
            New-UDLink -Text $LinkedItem.Directory -Url "/directory/$($LinkedItem.DirID)" 
        }
        If ($Directories.indexof($D) -ne 0){ # Output Separator / if not the last item
            Write-Output ' /'
        }
    }
}