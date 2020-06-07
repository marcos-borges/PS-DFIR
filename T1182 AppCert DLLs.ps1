#T1182 AppCert DLLs
$Array = @()

$keys = @(
        "registry::HKLM\System\CurrentControlSet\Control\Session Manager\AppCertDlls",
        "registry::HKLM\System\ControlSet001\Control\Session Manager\AppCertDlls"
        )

foreach($key in $keys){
    foreach($value in Get-Item -Path $key -ErrorAction SilentlyContinue){
        $value | Select-Object -ExpandProperty Property | ForEach-Object{
            $Output = "" | Select ComputerName,Hive,Name,Data
            $Output.Hive = "CurrentControlSet"
            
            if($key -like "*ControlSet001*"){
                $Output.Hive = "ControlSet001"
            }
            $Output.ComputerName = $env:computername | Select-Object
            $Output.Name = $_
            $Output.Data = (Get-ItemProperty -Path $key -Name $_).$_
            $Array += $Output
        }
    }
}
$Array | Format-Table -Wrap -AutoSize | Out-String
