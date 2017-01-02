# rmbuff
![rmbuff](https://github.com/m1yur1/ToS_Addon/wiki/image/rmbuff_00.jpg)  
/rmbuf tron で、掛かったbuffの名称とbuffTypeをシステムログに表示するようになる。  
表示を停止する場合、/rmbuf troff する。  
とりあえず、スウィフトステップ (138) を除去するよう、設定してみる。  
  
![rmbuff](https://github.com/m1yur1/ToS_Addon/wiki/image/rmbuff_01.png)  
TreeofSaviorJP\\addons\\rmbuff 辺りに有る settings.json を開き、図のように書き加えて保存する。  
/rmbuf reload で、addonがsettings.jsonを再読込する。  
/rmbuf on で、除去可能状態にする。  
/rmbuf off すると、除去しない状態に移行する。  
  
![rmbuff](https://github.com/m1yur1/ToS_Addon/wiki/image/rmbuff_02.gif)  
スウィフトステップbuffが掛かると、即座に除去する。  