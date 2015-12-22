$project = (Split-Path -Parent $MyInvocation.MyCommand.Path).Replace(".Tests", "")
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".tests.", ".")
. "$project\$sut"

Describe "FunctionWithFileOperation" {

	Context "Given the file exists, when the config is valid" {
		
		Setup -File config.xml -Content "<App Id='42' />"

		It "retuns the id of the app" {

			FunctionWithFileOperation -Path $TestDrive\config.xml | Should Be 42
		}
	}

	Context "Given the file exists, when the config file is invalid" {
		
		Setup -File config.xml -Content "<App />"

		It "throws 'The config file is invalid.'" {

			{ FunctionWithFileOperation -Path $TestDrive\config.xml } | Should Throw "The config file is invalid."
		}
	}

	Context "Given the file does not exist" {

		It "throws 'The config file is invalid.'" {

			{ FunctionWithFileOperation -Path invalidfile.xml } | Should Throw "The config file does not exist."
		}
	}
}