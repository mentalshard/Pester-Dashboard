Describe 'Tests with Contexts'{ 
    It "The current day of the week is $((Get-date).DayOfWeek)" {
        (Get-date).DayOfWeek | should be (Get-date).DayOfWeek
    }
    Context 'Should fail'{
        It 'This test always fails'{
            $false | Should Be $false
        }
    }
    Context 'Should not fail'{
        It 'This test always fails'{
            $true | Should Be $true
        }
    }

}