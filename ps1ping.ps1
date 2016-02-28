<#
 # Usage:
 #     ps1ping.ps1
 #     ps1ping.ps1 -configfile C:\path\to\config.txt
 #     ps1ping.ps1 -servers www.google.com,www.microsoft.com
 #     ps1ping.ps1 -outputfile C:\path\to\result.html
 #
 # Config file format:
 #     outputfile=C:\path\to\file.html
 #     servers=www.google.com,www.microsoft.com,192.168.1.1
 #
#>

param (
    [string]$configfile,
    [string[]]$servers = @("www.google.com","www.microsoft.com"),
    [string]$outputfile = "C:\temp\pingresult.html"
)

function Main() {
    if ($configfile) {
        $lines = Get-Content $configfile
        foreach ($line in $lines) {
            if ($line -match "^$") { continue }
            if ($line -match "^\s*;") { continue }
            
            $param = $line.Split("=", 2)
            if ($param[0] -eq "outputfile") {
                $outputfile = $param[1]
            } elseif ($param[0] -eq "servers") {
                $pcname = $param[1].Split(",")
            }
        }
    } elseif ($servers) {
        $pcname = $servers
    }
    
    $interval = 1800
    $body = "<h1>Hosts Aliveness</h1>
<div class=`"msg`">
This page is refreshed at random time.
</div>"
    
    while (1) {
        $randomObj = new-object random
        $interval = $randomObj.next(600,1800)
        $refresh = $interval + 15
        $head = "<meta charset=`"UTF-8`" />
<meta http-equiv=`"refresh`" content=`"$refresh`" />
<style>
html {font-family:arial;}
h1 {font-size:32px;font-weight:bold;margin:10px 0;}
h2 {font-size:24px;font-weight:bold;margin:10px 0;}
table {width:512px;}
table th {font-weight:bold;color:#fff;background:#06c;text-align:center;}
table th:nth-child(1) {width:412px;}
table th:nth-child(2) {width:100px;}
table tr {font-family:Courier;font-size:14px;}
table tr:nth-child(2n+1) {background:#def;}
div {font-size:16px;}
.msg {margin:10px 0;}
.blueStr {color:#00c;font-weight:normal;}
.redStr {color:#c00;font-weight:bold;}
</style>"
        
        $preContent = "<!-- preContent -->
<h2>ping result</h2>
<div class=`"msg`">Check at " + (Get-Date).ToString() + " from <strong>" + $env:COMPUTERNAME + "</strong></div>
<div class=`"msg`">Next refresh after $refresh sec.</div>
<!-- /preContent -->"
        
        $postContent = "<!-- postContent -->
<div class=`"msg`">‚ ‚¢‚¤‚¦‚¨‚©‚«‚­‚¯‚±</div>
<!-- /postContent -->"
        
        $isalive = @(Test-Connection -ComputerName $pcname -Count 1 -Quiet)
        $result = 0..($pcname.Count - 1) |
        % {
            if ($isalive[$_] -eq "True") {
                $pcname[$_] + "," + "###blue###" + $isalive[$_] + "###/blue###"
            } else {
                $pcname[$_] + "," + "###red###" + $isalive[$_] + "###/red###"
            }
        }
        
        $html = $result | ConvertFrom-Csv -Header "Host Name","isAlive" |
                          ConvertTo-Html -Head $head -Title "Hosts" -Body $body `
                                         -PreContent $preContent -PostContent $postContent
        $html -creplace("###red###","<span class=`"redStr`">") -creplace("###/red###","</span>") `
              -creplace("###blue###","<span class=`"blueStr`">") -creplace("###/blue###","</span>") `
              | Out-File -Encoding Default $outputfile
        
        # without BOM
        $data = Get-Content $outputfile
        $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($False)
        [System.IO.File]::WriteAllLines($outputfile, $data, $Utf8NoBomEncoding)
        
        sleep -s $interval
    }
}
Main
