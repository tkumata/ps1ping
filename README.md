# ps1ping.ps1

## 概要
PowerShell を用いて延々と、10 分から 30 分範囲のランダムなタイミングで疎通確認して結果を html ファイルに出力するだけのスクリプト。

!["html スクショ"](./screenshot.png)

## 使い方
引数なしは Google と Microsoft に ping します。
```
PS> ps1ping.ps1
or
PS> ps1ping.ps1 -configfile C:\path\to\config.txt
or
PS> ps1ping.ps1 -servers 192.168.1.1,www.example.com,winsname
or
PS> ps1ping.ps1 -outputfile C:\path\to\output.html
```
設定ファイルの形式
```
outputfile=C:\path\to\file.html
servers=192.168.1.1,192.168.1.2,winsname,www.example.com
```

## 備考
- 無通信状態が長いと、たまに ISP の認証エラーが起こりインターネットに出られなくなる傾向がある(ようなないような)
- じゃあ試しに無通信状態が長くならないようにしてみて様子見してみよう
- 壊れても気にならなくて暇を持て余している低電力マシンが Windows だった

ってことで PowerShell と。

- 文字化けの原因は VSCode で UTF8 で書いてたからだった。
- START -> UTF8 -> Encoding を無視して SJIS 化 -> Encoding によって UTF8 なり他のエンコーディングへ変換 -> 文字化け

ってことで PowerShell スクリプト自体 SJIS で書いたらあっさり文字化けしない。これ...外人とソースをやりとりするとき問題なんじゃ...
