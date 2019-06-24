Deploy 'Deploy ServerInfo script' {
    By Filesystem {
        FromSource 'PesterDashboard\'
        To "$env:userprofile\Documents\WindowsPowerShell\Modules\PesterDashboard\"
        WriteOptions = @{
            Mirror = $true
        }
        Tagged Prod
    }
}