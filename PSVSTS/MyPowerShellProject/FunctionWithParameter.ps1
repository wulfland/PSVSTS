<#
.Synopsis
   FunctionWithParameter.
.DESCRIPTION
   Returns the file length of a file.
.EXAMPLE
   FunctionWithParameter -Path .\somefile.txt
#>
function FunctionWithParameter {

    [CmdletBinding()]
    [OutputType([int])]
    Param (
		[Parameter(Mandatory=$true, Position=0)]
		[string]$Path
	)

	if (Test-Path $Path) {
		return (Get-ChildItem $Path).Length
	}else{
		return 0
	}
}