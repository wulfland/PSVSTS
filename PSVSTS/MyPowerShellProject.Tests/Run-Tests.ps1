param(
	[string]$SourceDir = $env:BUILD_SOURCESDIRECTORY,
    [string]$TempDir = $env:TEMP
)

(new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex
Install-Module Pester -Global

$outputFile = Join-Path $SourceDir "TEST-pester.xml"

Invoke-Pester -Path $SourceDir -OutputFile $outputFile -PassThru -OutputFormat NUnitXml -EnableExit
