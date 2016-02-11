param(
	[string]$SourceDir = $env:BUILD_SOURCESDIRECTORY,
    [string]$TempDir = $env:TEMP
)
$ErrorActionPreference = "Stop"

$modulePath = Join-Path $TempDir Pester-master\Pester.psm1

if (-not(Test-Path $modulePath)) {
    
	# Note: PSGet and chocolatey are not supported in hosted vsts build agent  
    $tempFile = Join-Path $TempDir pester.zip
    Invoke-WebRequest https://github.com/pester/Pester/archive/master.zip -OutFile $tempFile
    
    [System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') | Out-Null
    [System.IO.Compression.ZipFile]::ExtractToDirectory($tempFile, $tempDir)
    
    Remove-Item $tempFile
}

Import-Module $modulePath -DisableNameChecking

$outputFile = Join-Path $SourceDir "TEST-pester.xml"

$testCoverageFiles = @()
Get-ChildItem "$SourceDir\PSVSTS\MyPowerShellProject\*.ps1" -Recurse | ForEach-Object { $testCoverageFiles += $_.FullName }

$testResultSettings = @{ 
	OutputFormat = "NUnitXml"
	OutputFile = $outputFile
}

Invoke-Pester -Path $SourceDir -CodeCoverage $testCoverageFiles -PassThru @testResultSettings
