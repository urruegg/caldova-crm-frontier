BeforeAll {
    $script:root = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
}

Describe 'Caldova foundation integration with the existing Code Apps baseline' {
    It 'keeps one decision per stable ADR number' {
        $duplicates = Get-ChildItem (Join-Path $script:root 'docs\adr') -Filter 'ADR-????-*.md' |
            Group-Object { $_.Name.Substring(0, 8) } |
            Where-Object Count -gt 1
        $duplicates | Should -BeNullOrEmpty
    }

    It 'preserves Code Apps ADR-0041 and assigns the new foundation ADR-0042' {
        Join-Path $script:root 'docs\adr\ADR-0041-code-apps-primary-for-bespoke-full-page-crm-ux.md' |
            Should -Exist
        Join-Path $script:root 'docs\adr\ADR-0042-caldova-platform-foundation.md' |
            Should -Exist
    }

    It 'retains the renamed UX design pattern without restoring its retired path' {
        Join-Path $script:root 'docs\design\06-crm-ux-placement-options.md' | Should -Exist
        Test-Path (Join-Path $script:root 'docs\design\ADR-0033-crm-ux-placement-options.md') |
            Should -BeFalse
    }

    It 'retains both the earlier sprint history and the newer Code Apps sprint' {
        $index = Get-Content (Join-Path $script:root 'docs\superpowers\sprints\README.md') -Raw
        $index | Should -Match '\| sprint-004 \|'
        $index | Should -Match '\| sprint-005 \|'
        $index | Should -Not -Match '(?m)^<<<<<<<|^=======|^>>>>>>>'
    }
}
