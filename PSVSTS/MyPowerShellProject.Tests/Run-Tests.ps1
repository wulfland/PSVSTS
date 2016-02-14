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

[xml]$template = "<?xml version='1.0'?>
<!DOCTYPE coverage SYSTEM 'http://cobertura.sourceforge.net/xml/coverage-04.dtd'>

<coverage line-rate='0.9' branch-rate='0.75' version='1.9' timestamp='1187350905008'>
    <sources>
        <source>C:/local/mvn-coverage-example/src/main/java</source>
        <source>--source</source>
    </sources>
    <packages>
        <package name='' line-rate='1.0' branch-rate='1.0' complexity='1.0'>
            <classes>
                <class name='Main' filename='Main.java' line-rate='1.0' branch-rate='1.0' complexity='1.0'>
                    <methods>
                        <method name='&lt;init&gt;' signature='()V' line-rate='1.0' branch-rate='1.0'>
                            <lines>
                                <line number='10' hits='3' branch='false'/>
                            </lines>
                        </method>
                        <method name='doSearch' signature='()V' line-rate='1.0' branch-rate='1.0'>
                            <lines>
                                <line number='23' hits='3' branch='false'/>
                                <line number='29' hits='3' branch='false'/>
                                <line number='30' hits='3' branch='false'/>
                            </lines>
                        </method>
                        <method name='main' signature='([Ljava/lang/String;)V' line-rate='1.0' branch-rate='1.0'>
                            <lines>
                                <line number='16' hits='3' branch='false'/>
                                <line number='19' hits='3' branch='false'/>
                            </lines>
                        </method>
                    </methods>
                    <lines>
                        <line number='10' hits='3' branch='false'/>
                        <line number='16' hits='3' branch='false'/>
                        <line number='17' hits='3' branch='false'/>
                        <line number='30' hits='3' branch='false'/>
                    </lines>
                </class>
            </classes>
        </package>
        <package name='search' line-rate='0.8421052631578947' branch-rate='0.75' complexity='3.25'>
            <classes>
                <class name='search.BinarySearch' filename='search/BinarySearch.java' line-rate='0.9166666666666666'
                       branch-rate='0.8333333333333334' complexity='3.0'>
                    <methods>
                        <method name='&lt;init&gt;' signature='()V' line-rate='1.0' branch-rate='1.0'>
                            <lines>
                                <line number='12' hits='3' branch='false'/>
                            </lines>
                        </method>
                        <method name='find' signature='([II)I' line-rate='0.9090909090909091' branch-rate='0.8333333333333334'>
                            <lines>
                                <line number='16' hits='3' branch='false'/>
                                <line number='18' hits='12' branch='true' condition-coverage='100% (2/2)'>
                                    <conditions>
                                        <condition number='0' type='jump' coverage='100%'/>
                                    </conditions>
                                </line>
                                <line number='20' hits='9' branch='false'/>
                                <line number='21' hits='9' branch='false'/>
                                <line number='23' hits='9' branch='true' condition-coverage='50% (1/2)'>
                                    <conditions>
                                        <condition number='0' type='jump' coverage='50%'/>
                                    </conditions>
                                </line>
                                <line number='24' hits='0' branch='false'/>
                                <line number='25' hits='9' branch='true' condition-coverage='100% (2/2)'>
                                    <conditions>
                                        <condition number='0' type='jump' coverage='100%'/>
                                    </conditions>
                                </line>
                                <line number='26' hits='6' branch='false'/>
                                <line number='28' hits='3' branch='false'/>
                                <line number='29' hits='9' branch='false'/>
                                <line number='31' hits='3' branch='false'/>
                            </lines>
                        </method>
                    </methods>
                    <lines>
                        <line number='12' hits='3' branch='false'/>
                        <line number='18' hits='12' branch='true' condition-coverage='100% (2/2)'>
                            <conditions>
                                <condition number='0' type='jump' coverage='100%'/>
                            </conditions>
                        </line>
                        <line number='20' hits='9' branch='false'/>
                        <line number='23' hits='9' branch='true' condition-coverage='50% (1/2)'>
                            <conditions>
                                <condition number='0' type='jump' coverage='50%'/>
                            </conditions>
                        </line>
                        <line number='24' hits='0' branch='false'/>
                        <line number='25' hits='9' branch='true' condition-coverage='100% (2/2)'>
                            <conditions>
                                <condition number='0' type='jump' coverage='100%'/>
                            </conditions>
                        </line>
                        <line number='26' hits='6' branch='false'/>
                        <line number='31' hits='3' branch='false'/>
                    </lines>
                </class>
                <class name='search.ISortedArraySearch' filename='search/ISortedArraySearch.java' line-rate='1.0' branch-rate='1.0'
                       complexity='1.0'>
                    <methods>
                    </methods>
                    <lines>
                    </lines>
                </class>
            </classes>
        </package>
    </packages>
</coverage>"

$linesCovered = $result.CodeCoverage.NumberOfCommandsExecuted - $result.CodeCoverage.NumberOfCommandsMissed

#$template.coverage.timestamp = "$(Get-Date)"
#$template.coverage.version = "1.0.0.0"
#$template.coverage.'lines-covered' = "$linesCovered"
#$template.coverage.'lines-valid' = "$($result.CodeCoverage.NumberOfCommandsAnalyzed)"
#$template.coverage.'line-rate' = "$($linesCovered / $result.CodeCoverage.NumberOfCommandsAnalyzed)"

$template.Save((Join-Path $SourceDir "coverage.xml"))

$result
