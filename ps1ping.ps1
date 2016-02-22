<#
 # Usage
 #     ps1ping.ps1 -inputpath C:\file\path\hoge.txt
 #     ps1ping.ps1 -servers www.google.co.jp,192.168.2.1
 #
#>

# param (
#     [string]$inputpath,
#     [string[]]$Servers,
#     [string]$outputpath = "C:\temp\pingresult.html"
# )

# if ($inputpath) {
#     $pcname = Get-Content $inputpath
# } elseif ($Servers) {
#     $pcname = $Servers
# } else {
#     echo "Please Specify Params"
#     exit
# }

function Main()
{
    $pcname = @("www.google.com","192.168.2.1")
    $outputpath = "C:\temp\pingresult.html"
    $interval = 1800
    $head = "<meta http-equiv='refresh' content='$interval' />"
    
    while (1) {
        $isalive = @(Test-Connection -ComputerName $pcname -Count 1 -Quiet)
        $result = 0..($pcname.Count - 1) | %{$pcname[$_] + "," + $isalive[$_]}
        $body = "<h1>Check Hosts Aliveness</h1><h2>Check at " + (Get-Date).ToString() + "</h2>"
        $html = $result | ConvertFrom-Csv -Header "Host Name","isAlive" | ConvertTo-Html -Head $head -Title "Hosts" -Body $body
        $html | Out-File $outputpath
        sleep -s $interval
    }
}

# New-SelfHostedPS ps1ping.ps -Service -ServiceName ps1ping -ServiceDisplayName "ps1ping Demo"
Main
