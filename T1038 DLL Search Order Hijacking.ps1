# T1038 DLL Search Order Hijacking
$Array = @()

$key = @(
        "registry::HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\KnownDLLs"
        )

$DllDirectory = (Get-ItemProperty -Path $key -Name "DllDirectory" -ErrorAction SilentlyContinue)."DllDirectory"
$DllDirectory32 = (Get-ItemProperty -Path $key -Name "DllDirectory32" -ErrorAction SilentlyContinue)."DllDirectory32"

foreach($value in Get-Item -Path $key -ErrorAction SilentlyContinue){
    $value | Select-Object -ExpandProperty Property | ForEach-Object{
        if($_ -NotLike "DllDirectory*"){
            $Output = "" | Select ComputerName,Name,KnownDLLs,$DllDirectory,Integrity,Signature,$DllDirectory32,Integrity2,Signature2
            $Output.ComputerName = $env:computername | Select-Object
            $Output.Name = $_
            $Output.KnownDLLs = (Get-ItemProperty -Path $key -Name $_).$_
            $t1 = "$Env:windir$DllDirectory\" + (Get-ItemProperty -Path $key -Name $_).$_
            $t2 = "$Env:windir$DllDirectory32\" + (Get-ItemProperty -Path $key -Name $_).$_
            $Output.$DllDirectory = Test-Path $t1 -PathType Leaf
            $Output.$DllDirectory32 = Test-Path $t2 -PathType Leaf
            if($Output.$DllDirectory ){
                $Output.Integrity = "OK"
                $OutputVariable = (sfc /VERIFYFILE=$t1) | Out-String
                if (($OutputVariable | Measure-Object -Character).Characters -gt 158){
                    $Output.Integrity = "Failed"
                }
                $Output.Signature = (Get-AuthenticodeSignature $t1).Status
            }
            if($Output.$DllDirectory32){
                $Output.Integrity2 = "OK"
                $OutputVariable = (sfc /VERIFYFILE=$t2) | Out-String
                if (($OutputVariable | Measure-Object -Character).Characters -gt 158){
                    $Output.Integrity2 = "Failed"
                }
                $Output.Signature2 = (Get-AuthenticodeSignature $t2).Status
            }
            $Array += $Output
        }
    }
}

$Array | Format-Table -AutoSize | Out-String
