# Explorers

### エクスプローラーを複数起動させる。起動したエクスプローラーはデスクトップ上に整列した状態で表示される

### 使い方

- そのまま起動するだけでいいです
    - そのまま起動するとマイコンピュータをエクスプローラーが２つ開きます
- コマンドライン引数を指定することである程度操作することができます
    - １つ目：起動させるエクスプローラーの数
        - 例：C:\Tools\Explorer.exe 6
            - エクスプローラーを６つ起動する
        - 何も指定しない場合は２つ起動します
    - ２つ目：起動するフォルダ（Explorersが起動した時に表示するフォルダ）
        - 例：C:\Tools\Explorer.exe 6 "C:\Tools" 
            - "C:\Tools"フォルダを６つ起動させる

### その他
- コードは以下のサイトを参考にして作成しました
    - [https://autohotkey.com/board/topic/25868-run-command-to-assing-ahk-pid-variable/page-2](https://autohotkey.com/board/topic/25868-run-command-to-assing-ahk-pid-variable/page-2)
