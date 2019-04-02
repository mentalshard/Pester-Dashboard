Function New-PDProgress {
    param(
        [string]$Percent
        ,
        [string]$Label
    )

    New-UDElement -Tag "h5" -Content { $Label }

    New-UDElement -Tag "div" -Attributes @{ className = "percent-right" } -Content {
        New-UDElement -Tag "div" -Attributes @{
            className = "green"
            style = @{height = "100%"} 
        } -Content {
            New-UDElement -Tag "div" -Attributes @{ 
                class = "red"
                role = 'progressbar'
                style = @{ width = "$Percent%"}
                'aria-valuenow' = "$Percent"
                'aria-valuemin' = "0"
                'aria-valuemax' = "100"
            } -Content {
                    "Fail $Percent%"
            }
        }
    }
}