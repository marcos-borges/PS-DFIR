#T1197 BITS Jobs
$Array = @()

foreach ($event in Get-WinEvent -FilterHashtable @{ LogName='Microsoft-Windows-Bits-Client/Operational'; Id='59'; StartTime=(Get-Date).AddDays(-1) }) {
    $Output = "" | Select ComputerName,TimeCreated,JobID,User,Message
    $Output.ComputerName = $env:computername | Select-Object
    $Output.TimeCreated = ($event.TimeCreated).tostring(“MM-dd-yyyy hh:mm:ss”)
    $Output.JobID = $event.ActivityId
    $objSID = New-Object System.Security.Principal.SecurityIdentifier($event.UserId)
    $objUser = $objSID.Translate([System.Security.Principal.NTAccount])
    $Output.User = $objUser.Value
    $Output.Message = $event.Message
    $Array += $Output
}
$Array | Format-Table -Wrap -AutoSize | Out-String
