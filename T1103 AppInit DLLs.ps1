#T1103 AppInit DLLs
$Array = @()

$keys = @(
        "registry::HKLM\Software\Microsoft\Windows NT\CurrentVersion\Windows",
        "registry::HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Windows",
        "registry::HKU\*\Software\Microsoft\Windows NT\CurrentVersion\Windows",
        "registry::HKU\*\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Windows"
        )

foreach($key in $keys){
    try{
        $AppInit_DLLs = (Get-Itemproperty -Path $key -Name "AppInit_DLLs" -ErrorAction SilentlyContinue | Select-Object AppInit_DLLs).AppInit_DLLs
        $AppInit_DLLs = $AppInit_DLLs.Split(",")
        $AppInit_DLLs | ForEach-Object {
            $Output = "" | Select ComputerName,User,Hive,Dll        
            $Output.Hive = "64-bit"
            $Output.User = "SYSTEM"

            if($key -like "*HKU*"){
                Get-ItemProperty -Path $key -ErrorAction SilentlyContinue | % { 
                    if($_ -match "(S\-1\-5\-[0-9]{2}(\-[0-9]{10}){3}\-[0-9]{4})") { 
                        $objSID = New-Object System.Security.Principal.SecurityIdentifier($Matches[1])
                        $objUser = $objSID.Translate([System.Security.Principal.NTAccount])
                        $Output.User = $objUser.Value
                    }
                }
            }

            if(-not [Environment]::Is64BitProcess){
                $Output.Hive = "32-bit"
            }

            if($key -like "*Wow6432Node*"){
                $Output.Hive = "32-bit"
            }

            $Output.ComputerName = $env:computername | Select-Object
            $Output.Dll = $_
            $Array += $Output
        }
    }
    catch{}
}
$Array | Format-Table -Wrap -AutoSize | Out-String
