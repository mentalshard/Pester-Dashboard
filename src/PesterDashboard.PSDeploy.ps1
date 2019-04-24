Deploy 'Deploy ServerInfo script' {
    By Filesystem {
        FromSource 'PesterDashboard\'
        To "$env:userprofile\Documents\WindowsPowerShell\Modules\PesterDashboard\"
        Tagged Prod
    }
}