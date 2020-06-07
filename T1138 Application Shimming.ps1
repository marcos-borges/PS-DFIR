#T1138 Application Shimming
$Array = @()

Get-ItemProperty -Path "registry::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Custom\*" | ForEach-Object {
    $guid = ($_ -Replace '^.*(\{[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}\}).*', '$1')
    $Output = "" | Select ComputerName,SDBGUID,FileName,DatabaseDescription,DatabasePath
    $Output.ComputerName = $env:computername | Select-Object
    $Output.SDBGUID = $guid
    $Output.FileName = (Get-Itemproperty -Path $_.PSPath).PSChildName
    Get-Itemproperty -Path "registry::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\InstalledSDB\$guid\" -ErrorAction SilentlyContinue | ForEach-Object {
        $Output.DatabaseDescription = $_.DatabaseDescription
        $Output.DatabasePath = $_.DatabasePath
    }
    $Array += $Output
}
$Array | Format-Table -Wrap -AutoSize | Out-String
