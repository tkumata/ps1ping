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
    $body = "<h1>Hosts Aliveness</h1>`n<div class=`"msg`">This page is refreshed at random time.</div>`n"
    
    while (1) {
        $randomObj = new-object random
        $interval = $randomObj.next(600,1800)
        $refresh = $interval + 10
        $head = "<meta charset=`"UTF-8`">
<meta http-equiv=`"refresh`" content=`"$refresh`" />
<style>
html {font-family:arial;}
h1 {font-size:32px;font-weight:bold;margin:10px 0;}
h2 {font-size:24px;font-weight:bold;margin:10px 0;}
table {width:50%;}
th {font-weight:normal;color:#fff;background:#14a;width:50%;text-align:center;border-bottom:1px solid #ccc;}
table tr:nth-child(2n+1) {background:#def;}
.msg {margin:10px 0;}
.redStr {color:#c00;font-weight:bold;}
</style>"
        $preContent = "<!-- preContent -->
<h2>ping result</h2>
<div class=`"msg`">Refresh time is $refresh sec.</div>
<!-- //preContent -->"
        $postContent = "<!-- postContent -->
<div class=`"msg`">Check at " + (Get-Date).ToString() + "</div>
<!-- postContent -->"
        
        $isalive = @(Test-Connection -ComputerName $pcname -Count 1 -Quiet)
        $result = 0..($pcname.Count - 1) | %{if($isalive[$_] -eq "True"){$pcname[$_] + "," + $isalive[$_]}else{$pcname[$_] + "," + "###red###" + $isalive[$_] + "###/red###"}}
        $html = $result | ConvertFrom-Csv -Header "Host Name","isAlive" | ConvertTo-Html -Head $head -Title "Hosts" -PreContent $preContent -Body $body -PostContent $postContent
        $html -creplace("###red###","<span class=`"redStr`">") -creplace("###/red###","</span>") | Out-File $outputpath -Encoding UTF8
        
        sleep -s $interval
    }
}
Main
