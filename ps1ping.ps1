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

function Main() {
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
    $head = "<meta charset=`"UTF-8`">
<meta http-equiv=`"refresh`" content=`"$refresh`" />
<style>
* {font-family:arial;}
h1 {font-size:32px;font-weight:bold;}
h2 {font-size:24px;font-weight:bold;}
th {font-weight:normal;color:#fff;background:#14a;width:200px;text-align:center;border-bottom:1px solid #ccc;}
table tr:nth-child(2n+1) {background:#f1f6fc;}
.msg {margin:10px 0 10px 0;}
</style>"
    
    while (1) {
        $isalive = @(Test-Connection -ComputerName $pcname -Count 1 -Quiet)
        $result = 0..($pcname.Count - 1) | %{$pcname[$_] + "," + $isalive[$_]}
        $body = "<h1>Check Hosts Aliveness</h1>`n"
        $body += $messText
        $body += "<div class=`"msg`">Check at " + (Get-Date).ToString() + "</div>`n"
        $html = $result | ConvertFrom-Csv -Header "Host Name","isAlive" | ConvertTo-Html -Head $head -Title "Hosts" -Body $body
        $html | Out-File $outputpath -Encoding UTF8
        sleep -s $interval
    }
}

# New-SelfHostedPS ps1ping.ps -Service -ServiceName ps1ping -ServiceDisplayName "ps1ping Demo"
$messText = "<h2>ping result</h2>`n"
Main
