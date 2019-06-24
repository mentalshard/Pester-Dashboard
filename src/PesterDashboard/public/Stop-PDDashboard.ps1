Function Stop-PDDashboard {
    [cmdletbinding()]
    Param ()
    Get-UDDashboard -Name PesterDashboard | Stop-UDDashboard
}