<#
 # Usage
 #     ps1ping.ps1
 #     ps1ping.ps1 -inputfile C:\file\path\hoge.txt
 #     ps1ping.ps1 -servers www.google.com,www.microsoft.com
 #
#>

param (
    [string]$inputfile,
    [string[]]$servers = @("www.google.com","www.microsoft.com"),
    [string]$outputpath = "C:\temp\pingresult.html"
)

function Main()
{
    if ($inputfile) {
        $pcname = Get-Content $inputfile
    } elseif ($servers) {
        $pcname = $servers
    } else {
        echo "Please Specify Params"
        exit
    }
    
    $interval = 1800
    $refresh = $interval + 60
    $head = "<meta http-equiv='refresh' content='$refresh' />"
    
    while (1) {
        $isalive = @(Test-Connection -ComputerName $pcname -Count 1 -Quiet)
        $result = 0..($pcname.Count - 1) | %{$pcname[$_] + "," + $isalive[$_]}
        $body = "<h1>Check Hosts Aliveness</h1>`n"
        $body += "<h2>Check at " + (Get-Date).ToString() + "</h2>`n"
        $html = $result | ConvertFrom-Csv -Header "Host Name","isAlive" | ConvertTo-Html -Head $head -Title "Hosts" -Body $body
        $html | Out-File $outputpath
        sleep -s $interval
    }
}

# New-SelfHostedPS ps1ping.ps -Service -ServiceName ps1ping -ServiceDisplayName "ps1ping Demo"
Main
