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

Invoke-Pester -Path $SourceDir -CodeCoverage "$SourceDir\PSVSTS\MyPowerShellProject\*.ps1" -PassThru -OutputFile $outputFile -OutputFormat NUnitXml -EnableExit

[Reflection.Assembly]::LoadWithPartialName('Microsoft.TeamFoundation.Client')
[Reflection.Assembly]::LoadWithPartialName('Microsoft.TeamFoundation.Build.Client')
     
$tpc = [Microsoft.TeamFoundation.Client.TfsTeamProjectCollectionFactory]::GetTeamProjectCollection($env:BUILD_COLLECTIONURI)
$buildService = $tpc.GetService([Microsoft.TeamFoundation.Build.Client.IBuildServer])
$build = $buildService.GetBuild($env:BUILD_BUILDURI)
 
$message = "Write something..."
[Microsoft.TeamFoundation.Build.Client.InformationNodeConverters]::AddCustomSummaryInformation($build.Information, $message, "ConfigurationSummary", "Javascript Coverage", 200)
$build.Information.Save();

