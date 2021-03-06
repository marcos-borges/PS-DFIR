#T1053 Scheduled Task/Job
param(
    [Parameter(Mandatory=$false)]
    [string]
    $File
)

$Array = @()

schtasks /query /V /FO CSV | ConvertFrom-Csv | Sort-Object -Unique -Property TaskName,"Task To Run" | ForEach-Object {
	if ($PSBoundParameters.ContainsKey('File')) {
		if ($_."Task to Run" -like ("*" + $File + "*")) {
			$Output = "" | Select ComputerName,TaskName,TaskToRun
			$Output.ComputerName = $env:computername | Select-Object
			$Output.TaskName = $_.TaskName
			$Output.TaskToRun = $_."Task to Run"
			$Array += $Output
		}
	} else {
		$Output = "" | Select ComputerName,TaskName,TaskToRun
		$Output.ComputerName = $env:computername | Select-Object
		$Output.TaskName = $_.TaskName
		$Output.TaskToRun = $_."Task to Run"
        $Array += $Output
    }
}
$Array | Format-Table -Wrap -AutoSize | Out-String