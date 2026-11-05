BeforeAll {
    $script:repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
    # Keep retired customer names out of active content, including this test.
    $script:legacyCustomer = '(?i)(?:Mobi' + 'liar|Mobi' + 'lière|Mobi' + 'liare|Mobi' + '24)' +
        '|\bmo' + 'bi_|\bmo' + 'biNav\b|--publisher-prefix\s+mo' + 'bi\b'
    $script:legacyRepository = 'urruegg/' + 'CRMShowcase'
    $script:legacyProduct = 'CRM\s+Frontier\s+Firm\s+' + 'Showcase|CRM\s+' + 'Showcase'
    $contract = Get-Content -LiteralPath (Join-Path $script:repoRoot 'solution/schema/insurance-foundation.json') -Raw | ConvertFrom-Json
    $script:technicalRoleLabels = @($contract.roles | ForEach-Object {
        $_.metadata.label.PSObject.Properties.Value
    })
    # Negative identity fixtures also keep their existing deployment identifiers.
    $script:technicalRoleLabels += @('Escalation', 'DataModel Reviewer', 'Archive' | ForEach-Object {
        'CRM ' + 'Showcase Insurance ' + $_
    })
    $script:technicalRoleLabels += 'CRM ' + 'Showcase Operator'

    $tracked = @(& git -C $script:repoRoot -c core.quotepath=false ls-files --cached)
    if ($LASTEXITCODE -ne 0) { throw 'Cannot enumerate tracked branding inputs.' }
    $newBranding = @(& git -C $script:repoRoot -c core.quotepath=false ls-files --others --exclude-standard -- `
        docs/brandkit intake/caldova scripts/solution/tests/CaldovaBranding.Tests.ps1 `
        docs/superpowers/sprints/sprint-004-advisor-cockpit-demo-data/streams/caldova-intake-governance.md)
    if ($LASTEXITCODE -ne 0) { throw 'Cannot enumerate new branding inputs.' }
    $script:activePaths = @(@($tracked) + @($newBranding) | Sort-Object -Unique | Where-Object {
        # A separate migration slice owns infrastructure, CI and its governance.
        $_ -notmatch '^(infra/|\.github/workflows/)' -and
        $_ -notin @('.env.example', '.gitignore', 'docs/ENVIRONMENTS.md', 'docs/BACKLOG.md',
            'scripts/solution/tests/ReviewedRefControls.Tests.ps1') -and
        $_ -notmatch '^docs/adr/ADR-0042-' -and
        $_ -notmatch '^docs/superpowers/(specs|plans)/2026-11-05-' -and
        $_ -notmatch '(^|/)(source|\.raw|\.scan|node_modules|dist|out|build|obj|bin)/' -and
        $_ -notmatch '\.(png|jpg|jpeg|gif|ico|pdf|zip|woff2?)$' -and
        (Test-Path -LiteralPath (Join-Path $script:repoRoot $_) -PathType Leaf)
    })
}

Describe 'Caldova branding migration (source-controlled and illustrative sources)' {
    It 'has no retired customer names in active paths or content' {
        $findings = @(
            foreach ($path in $script:activePaths) {
                if ($path -match $script:legacyCustomer) { "path: $path" }
                $text = [System.IO.File]::ReadAllText((Join-Path $script:repoRoot $path))
                if ($text -match $script:legacyCustomer) { "content: $path" }
            }
        )
        $findings | Should -BeNullOrEmpty
    }

    It 'uses the renamed repository and product without renaming technical role identifiers' {
        $findings = @(
            foreach ($path in $script:activePaths) {
                $text = [System.IO.File]::ReadAllText((Join-Path $script:repoRoot $path))
                foreach ($roleLabel in $script:technicalRoleLabels) {
                    $text = $text -replace [regex]::Escape($roleLabel), ''
                }
                # This deployment lookup prefix is also an immutable role identifier.
                $text = $text.Replace(("'CRM " + "Showcase Insurance '"), '')
                # Repository URLs move; the existing absolute local checkout does not.
                $text = $text -replace [regex]::Escape($script:repoRoot.Replace('\', '/')), ''
                if ($text.Contains($script:legacyRepository) -or $text -match $script:legacyProduct) { $path }
            }
        )
        $findings | Should -BeNullOrEmpty
        $readme = Get-Content -LiteralPath (Join-Path $script:repoRoot 'README.md') -Raw
        $readme | Should -Match 'Caldova CRM Frontier'
        $contract = Get-Content -LiteralPath (Join-Path $script:repoRoot 'solution/schema/insurance-foundation.json') -Raw | ConvertFrom-Json
        $solution = [xml](Get-Content -LiteralPath (Join-Path $script:repoRoot 'solution/core/foundation/Other/Solution.xml') -Raw)
        $solution.ImportExportXml.SolutionManifest.Publisher.UniqueName | Should -Be 'CRMShowcase'
        @($contract.roles.name) | Should -Contain 'CRM Showcase Insurance Data Steward'
    }

    It 'keeps sanitized intake references at the renamed paths' {
        foreach ($path in @(
            'intake/caldova/README.md',
            'intake/caldova/bom/README.md',
            'intake/caldova/ideas/00. ERD Visualizer.html',
            'intake/caldova/ideas/Caldova - CRM Architecture Decisions.html',
            'intake/caldova/ideas/Caldova - Demo Curveballs & Architecture.html',
            'intake/caldova/ideas/Caldova - Voice Integration Architecture.html',
            'intake/caldova/mappings/curveball-to-fixture-map.md',
            'docs/superpowers/sprints/sprint-004-advisor-cockpit-demo-data/streams/caldova-intake-governance.md'
        )) {
            Join-Path $script:repoRoot $path | Should -Exist
        }
        $intake = Get-Content -LiteralPath (Join-Path $script:repoRoot 'intake/caldova/README.md') -Raw
        $intake | Should -Match '(?i)adapted'
        $intake | Should -Match '(?i)not.*(ownership|endorsement)'
        foreach ($html in Get-ChildItem -LiteralPath (Join-Path $script:repoRoot 'intake/caldova/ideas') -Filter '*.html') {
            $content = Get-Content -LiteralPath $html.FullName -Raw
            $content | Should -Match '(?i)adapted sanitized legacy design reference'
            $content | Should -Match '(?i)not.*ownership'
        }
    }

    It 'exposes consistently renamed brandkit entry points' {
        $kit = Join-Path $script:repoRoot 'docs/brandkit'
        $package = Get-Content -LiteralPath (Join-Path $kit 'package.json') -Raw | ConvertFrom-Json
        $package.name | Should -Be '@caldova/fluent-brandkit'
        foreach ($export in $package.exports.PSObject.Properties) {
            Join-Path $kit $export.Value | Should -Exist
        }
        $lock = Get-Content -LiteralPath (Join-Path $kit 'package-lock.json') -Raw | ConvertFrom-Json -AsHashtable
        $lock.name | Should -Be $package.name
        $lock.packages[''].name | Should -Be $package.name
        $index = Get-Content -LiteralPath (Join-Path $kit 'src/index.ts') -Raw
        $index | Should -Match 'components/CaldovaProvider'
        $index | Should -Match 'components/CaldovaSurface'
        $manifest = [xml](Get-Content -LiteralPath (Join-Path $kit 'pcf/CaldovaCard/ControlManifest.Input.xml') -Raw)
        $manifest.manifest.control.namespace | Should -Be 'Caldova'
        $manifest.manifest.control.constructor | Should -Be 'CaldovaCard'
    }

    It 'labels retained styling as illustrative rather than approved corporate identity' {
        $readme = Get-Content -LiteralPath (Join-Path $script:repoRoot 'docs/brandkit/README.md') -Raw
        $readme | Should -Match '(?i)illustrative'
        $readme | Should -Match '(?i)not approved corporate identity'
        $readme | Should -Match '(?i)adapted'
        $readme | Should -Match '(?i)not.*(ownership|endorsement)'
        $fontStack = Get-Content -LiteralPath (Join-Path $script:repoRoot 'docs/brandkit/src/tokens/typography.ts') -Raw
        $fontStack | Should -Not -Match "'Caldova Sans'"
        $css = Get-Content -LiteralPath (Join-Path $script:repoRoot 'docs/brandkit/src/styles/caldova.tokens.css') -Raw
        $css | Should -Not -Match "'Caldova Sans'"
        $css | Should -Match '--caldova-font-base: Arial,'
    }

    It 'keeps sanitized CSV, JSON and domain-map inventories aligned' {
        $intake = Join-Path $script:repoRoot 'intake/contoso-insurance'
        $csv = @(Import-Csv -LiteralPath (Join-Path $intake 'bom/artefacts.csv'))
        $json = @(Get-Content -LiteralPath (Join-Path $intake 'bom/artefacts.json') -Raw | ConvertFrom-Json)
        $map = @(Import-Csv -LiteralPath (Join-Path $intake 'mappings/domain-map.csv'))
        $csv | Should -HaveCount 941
        $json | Should -HaveCount $csv.Count
        $map | Should -HaveCount $csv.Count
        $csvKeys = @($csv | ForEach-Object { "$($_.componentType)|$($_.logicalName)|$($_.parent)|$($_.sourcePath)" } | Sort-Object)
        $jsonKeys = @($json | ForEach-Object { "$($_.componentType)|$($_.logicalName)|$($_.parent)|$($_.sourcePath)" } | Sort-Object)
        $mapKeys = @($map | ForEach-Object { "$($_.componentType)|$($_.logicalName)|$($_.parent)|$($_.sourcePath)" } | Sort-Object)
        $jsonKeys | Should -Be $csvKeys
        $mapKeys | Should -Be $csvKeys
    }
}
