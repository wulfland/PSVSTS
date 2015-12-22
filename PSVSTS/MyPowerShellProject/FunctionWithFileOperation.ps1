<#
.Synopsis
   FunctionWithFileOperation
.DESCRIPTION
   Gets the ID of a XML file
.EXAMPLE
   FunctionWithFileOperation -Path .\somefile.txt
#>
function FunctionWithFileOperation {

    [CmdletBinding()]
    [OutputType([int])]
    Param (

		[Parameter(Mandatory=$true, Position=0)]
		[ValidateNotNullOrEmpty()]
		[ValidateScript({ Test-Path $Path })]
		[string]$Path
	)

	if (-not (Test-Path $Path)) { throw "The config file does not exist." }

	[xml]$xml = Get-Content $Path

	$id = $xml.App.Id

	if (-not $id) { throw "The config file is invalid." }

	return [int]$id
}