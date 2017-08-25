$projectRoot = Resolve-Path "$PSScriptRoot\.."
$script:ModuleName = 'FortiAuth-Import'
$moduleRoot = "$projectRoot\$ModuleName"

Describe "PSScriptAnalyzer rule-sets" -Tag Build {

    $Rules = Get-ScriptAnalyzerRule
    $scripts = Get-ChildItem $moduleRoot -Include *.ps1, *.psm1, *.psd1 -Recurse | where fullname -notmatch 'classes'

    foreach ( $Script in $scripts )
    {
        Context "Script '$($script.FullName)'" {

            foreach ( $rule in $rules )
            {
                It "Rule [$rule]" {
                    # Suppress these rules for these files.
                    if ($rule -like "PSAvoidShouldContinueWithoutForce" -and $script.Name -like "Users.ps1")
                    {
                        # This isn't needed to -Force anything as we are talking to an API for this
                        (Invoke-ScriptAnalyzer -Path $script.FullName -IncludeRule $rule.RuleName ).Count | Should Be 3
                    }
                    elseif ($rule -like "PSUseShouldProcessForStateChangingFunctions" -and $script.Name -like "Users.ps1")
                    {
                        # This isn't needed to and Should Process checks as we are talking to an API for this
                        (Invoke-ScriptAnalyzer -Path $script.FullName -IncludeRule $rule.RuleName ).Count | Should Be 2
                    }
                    else
                    {
                        (Invoke-ScriptAnalyzer -Path $script.FullName -IncludeRule $rule.RuleName ).Count | Should Be 0
                    }
                }
            }
        }
    }
}


Describe "General project validation: $moduleName" -Tags Build {

    It "Module '$moduleName' can import cleanly" {
        {Import-Module (Join-Path $moduleRoot "$moduleName.psm1") -force } | Should Not Throw
    }
}
