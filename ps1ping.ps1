<#
 # Usage
 #     ps1ping.ps1 -inputpath C:\file\path\hoge.txt
 #     ps1ping.ps1 -servers www.google.co.jp,192.168.2.1
 #
#>
param (
    [string]$inputpath,
    [string[]]$Servers,
    [string]$outputpath = "C:\temp\pingresult.html"
)

if ($inputpath) {
    $pcname = Get-Content $inputpath
} elseif ($Servers) {
    $pcname = $Servers
} else {
    Write-Warning "Please Specify Params"
    exit
}

while (1) {
    $isalive = @(Test-Connection -ComputerName $pcname -Quiet)
    $result = 0..($pcname.Count - 1) | %{$pcname[$_] + "," + $isalive[$_]}
    $head = "Checking server aliveness at " + (Get-Date).ToString()
    $html = $result | ConvertFrom-Csv -Header "Server Name","isAlive" | ConvertTo-Html -Head $head -Title "Servers"
    $html | Out-File $outputpath
    sleep -s 600
}
