Function Stop-PDDashboard {
    Param ()
    Get-UDDashboard -Name PesterDashboard | Stop-UDDashboard
}