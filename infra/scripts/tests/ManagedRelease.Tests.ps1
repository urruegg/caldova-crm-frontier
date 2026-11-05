BeforeAll {
    $script:path = Join-Path $PSScriptRoot '..\Get-ManagedRelease.ps1'
    if (Test-Path $script:path) { . $script:path }
}
Describe 'Managed release artifact verification' {
    BeforeEach {
        $script:dir = Join-Path $TestDrive ([guid]::NewGuid().ToString())
        New-Item -ItemType Directory $script:dir | Out-Null
        $script:name = 'crmshow_Foundation_managed.zip'
        Set-Content (Join-Path $script:dir $script:name) 'synthetic artifact bytes'
        $script:release = @{
            sourceSha = ('a' * 40)
            mode = 'InstallOrUpdate'
            solutions = @(@{
                name = 'crmshow_Foundation'; version = '1.0.0.0'; file = $script:name
                sha256 = (Get-FileHash (Join-Path $script:dir $script:name)).Hash
            })
        }
    }
    It 'accepts the exact reviewed artifact' {
        $script:release | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $script:dir 'release.json')
        (Get-ManagedRelease -ArtifactPath $script:dir -ExpectedSha ('a' * 40)).solutions.Count | Should -Be 1
    }
    It 'rejects a modified package' {
        $script:release | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $script:dir 'release.json')
        Add-Content (Join-Path $script:dir $script:name) 'tampered'
        { Get-ManagedRelease -ArtifactPath $script:dir -ExpectedSha ('a' * 40) } | Should -Throw '*hash*'
    }
    It 'rejects a release from another source revision' {
        $script:release | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $script:dir 'release.json')
        { Get-ManagedRelease -ArtifactPath $script:dir -ExpectedSha ('b' * 40) } | Should -Throw '*revision*'
    }
    It 'rejects staged-only TEST runs for PROD' {
        $script:release.mode = 'StageForUpgrade'
        $script:release | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $script:dir 'release.json')
        { Get-ManagedRelease -ArtifactPath $script:dir -ExpectedSha ('a' * 40) -ForProduction } | Should -Throw '*staged*'
    }
    It 'rejects package paths outside the artifact' {
        $script:release.solutions[0].file = '..\other.zip'
        $script:release | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $script:dir 'release.json')
        { Get-ManagedRelease -ArtifactPath $script:dir -ExpectedSha ('a' * 40) } | Should -Throw '*filename*'
    }
    It 'rejects an empty release' {
        $script:release.solutions = @()
        $script:release | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $script:dir 'release.json')
        { Get-ManagedRelease -ArtifactPath $script:dir -ExpectedSha ('a' * 40) } | Should -Throw '*empty*'
    }
    It 'rejects a null solution list' {
        $script:release.solutions = $null
        $script:release | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $script:dir 'release.json')
        { Get-ManagedRelease -ArtifactPath $script:dir -ExpectedSha ('a' * 40) } | Should -Throw '*empty*'
    }
    It 'rejects a missing solution list' {
        $script:release.Remove('solutions')
        $script:release | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $script:dir 'release.json')
        { Get-ManagedRelease -ArtifactPath $script:dir -ExpectedSha ('a' * 40) } | Should -Throw '*empty*'
    }
}
