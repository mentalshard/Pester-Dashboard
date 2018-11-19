Describe 'Basic text tests' {
    IT 'Should be a passing value' {
        'This' | should be 'This'
    }
}
Describe "Basic processor tests" {
    It "Process counts should match" {
        (get-process).count | Should Be (Get-Process).count
    }
    It "Process counts should match [but fail]" {
        (get-process).count | Should Be ((Get-Process).count + 1)
    }
}
Describe 'Tests with Contexts'{ 
    It "The current day of the week is $((Get-date).DayOfWeek)" {
        (Get-date).DayOfWeek | should be (Get-date).DayOfWeek
    }
    Context 'Should fail'{
        It 'This test always fails'{
            $false | Should Be $true
        }
    }
    Context 'Should not fail'{
        It 'This test always fails'{
            $true | Should Be $true
        }
    }

}
Describe 'Tests with Contexts'{ 
    It "The current day of the week is $((Get-date).DayOfWeek)" {
        (Get-date).DayOfWeek | should be (Get-date).DayOfWeek
    }
    Context 'Should fail'{
        It 'This test always fails'{
            $false | Should Be $true
        }
    }
    Context 'Should not fail'{
        It 'This test always fails'{
            $true | Should Be $true
        }
    }

}

#Invoke-pester -Script .\pestertests.ps1 -Outputfile test.xml -outputformat NUnitXml 