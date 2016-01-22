$project = (Split-Path -Parent $MyInvocation.MyCommand.Path).Replace(".Tests", "")
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".tests.", ".")
. "$project\$sut"

Describe "AnswerToUltimateQuestion" {

	Context "Given an enormous supercomputer named Deep Thought, when we ask the ultimate question about life, the universe, and everything" {

		It "should return 42" {

			AnswerToUltimateQuestion | Should Be 43
		}
	}
}