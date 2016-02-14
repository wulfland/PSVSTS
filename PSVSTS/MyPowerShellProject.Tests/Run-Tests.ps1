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

$result = Invoke-Pester -Path $SourceDir -CodeCoverage "$SourceDir\PSVSTS\MyPowerShellProject\*.ps1" -PassThru -OutputFile $outputFile -OutputFormat NUnitXml -EnableExit

[xml]$template = "<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE coverage SYSTEM 'http://cobertura.sourceforge.net/xml/coverage-04.dtd'>
<coverage branches-covered='' branches-valid='' branch-rate='' complexity='' line-rate='' lines-covered='' lines-valid='' timestamp='' version=''>
	<packages></packages>
</coverage>"

$linesCovered = $result.CodeCoverage.NumberOfCommandsExecuted - $result.CodeCoverage.NumberOfCommandsMissed

#$template.coverage.timestamp = "$(Get-Date)"
#$template.coverage.version = "1.0.0.0"
#$template.coverage.'lines-covered' = "$linesCovered"
#$template.coverage.'lines-valid' = "$($result.CodeCoverage.NumberOfCommandsAnalyzed)"
#$template.coverage.'line-rate' = "$($linesCovered / $result.CodeCoverage.NumberOfCommandsAnalyzed)"

$template | Out-File (Join-Path $SourceDir "coverage.xml")

$result
