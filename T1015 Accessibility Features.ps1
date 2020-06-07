#T1015 Accessibility Features
$Array = @()
$SystemDirectory = [System.Environment]::SystemDirectory

$afeatures = @(
        "sethc.exe",
        "utilman.exe",
        "AtBroker.exe",
        "Narrator.exe",
        "Magnify.exe",
        "DisplaySwitch.exe",
        "osk.exe"
        )

foreach($afeature in $afeatures){
    $Output = "" | Select ComputerName,Feature,DebuggerValue,IntegrityCheck
    $Output.ComputerName = $env:computername | Select-Object
    $Output.Feature = $afeature
    $Output.IntegrityCheck = "OK"
    Get-ItemProperty -Path "registry::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$afeature" -ErrorAction SilentlyContinue | ForEach-Object {
        $Output.DebuggerValue = (Get-ItemProperty -Path $_.PSPath).Debugger
    }
    $OutputVariable = (sfc /VERIFYFILE=$SystemDirectory\$afeature) | Out-String
    if (($OutputVariable | Measure-Object -Character).Characters -gt 158){
        $Output.IntegrityCheck = "Failed"
    }
    $Array += $Output
}

$Array | Format-Table -Wrap -AutoSize | Out-String
