#T1122 Component Object Model (COM) Hijacking
#
# WARNING: CPU RESOURCE INTENSIVE
#
$Array = @()

Get-ItemProperty -Path "registry::HKLM\SOFTWARE\Classes\*\shell\open\command" -ErrorAction SilentlyContinue | ForEach-Object {
    $key = $_."(Default)"
    if ($key -match "\\Users\\|ProgramData"){
        $Output = "" | Select ComputerName,Classe,Command,Status
        $Output.ComputerName = $env:computername | Select-Object
        $Output.Classe = ($_.PSPath -Replace '.*Classes\\(.*)\\shell.*', '$1')
        $Output.Command = $key
        $Output.Status = "Suspicious"
        $Array += $Output            
    }
}
$Array | Format-Table -Wrap -AutoSize | Out-String
