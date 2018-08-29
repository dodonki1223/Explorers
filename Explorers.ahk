;**********************************************************************
;* プログラム名  ：Explorers（Explorers.ahk）                         *
;* プログラム概要：Explorerを複数起動させる                           *
;*                 ・コマンドライン引数に実行させる数、開きたいパスを *
;*                   指定することによりExplorerの数と開くパスを指定す *
;*                   ることができます。また開いたExplorerは画面に整列 *
;*                   されて表示されます                               *
;*                 ・右クリックの送るに「C:\Tools\Explorer.exe 6」の  *
;*                   ようなショートカットを作成しておくと対象フォルダ *
;*                   を６つ開くことが出来ます                         *
;*                   例：C:\Tools\Explorer.exe 6 "C:\Tools"           *
;*                     "C:\Tools"フォルダを６つ起動させる             *
;* 依存関係      ：なし                                               *
;**********************************************************************
;参考にしたページ:https://autohotkey.com/board/topic/25868-run-command-to-assing-ahk-pid-variable/page-2

;------------------------------------------
; AutoHotKey設定
;------------------------------------------
#InstallKeybdHook
#UseHook
#NoTrayIcon
#SingleInstance force

;------------------------------------------
; 作業フォルダを設定
;------------------------------------------
SetWorkingDir,%A_ScriptDir%

;------------------------------------------
; 変数宣言
;------------------------------------------
;Explorerで開くデフォルトフォルダ（コンピュータ）
;※コマンドライン引数の指定が無かった場合はコンピュータを開きます
openPath      := "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}" 

;実行するExplorer数
;※コマンドライン引数の指定が無かった場合は２つ起動します
explorerCount := 2                                          

;------------------------------------------
; コマンドライン引数を取得
;------------------------------------------
;コマンドライン引数の数を取得
argCount =%0% 

;コマンドライン引数の数分繰り返す(２番目の引数まで対象とする)
;※コマンドラインが正しいことが前提で作成してある（引数チェックは行っていない）
Loop, %argCount%
{
    if(a_index == 1){
    
        ;表示するExplorer数を取得
        explorerCount := %a_index%
        
    } else if (a_index == 2){

        ;表示するフォルダーを取得
        openPath := %a_index%
        break
        
    }
}

;------------------------------------------
; ポインタ、タクスバー、モニター情報を取得
;------------------------------------------
;座標の扱いをスクリーン上での絶対位置に変更
CoordMode,Mouse,Screen

;ポインタの座標を取得
MouseGetPos, mouseX, mouseY                        

;タスクバーの高さを取得
WinGetPos, , , , taskbarH, ahk_class Shell_TrayWnd 

;モニター数を取得
SysGet, monitorCount, MonitorCount                 

;プライマリーモニターを取得
SysGet, monitorPrimary, MonitorPrimary             

;モニター数分繰り返す
Loop, %monitorCount% 
{

    ;モニターの解像度、左座標、右座標、上座標、下座標を取得
    SysGet, m, MonitorWorkArea, %a_index%

    ;プライマリーモニターの場合は高さチェック用の変数にタスクバーの高さを足す
    ;※タスクバー上で実行した場合、実行されないための対応
    if (monitorPrimary =a_index ) {
    
        mBottomChk := mBottom + taskbarH
        
    } else {
    
        mBottomChk := mBottom
        
    }

    ;マウスのX座標(mouseX)がモニターの左座標(mLeft)より大きく、マウスのX座標(mouseX)がモニターの右座標(mRight)より小さく、
    ;モニターの下座標(mTop)よりマウスのY座標(mouseY)が大きく、マウスのY座標(mouseY)がモニターの上座標(mBottomChk)より大きい時
    ;※マウスの座標があるモニターの時
    if (mLeft <= mouseX && mouseX <= mRight && mTop <= mouseY && mouseY <= mBottomChk)
    {
        
        ;------------------------------------------
        ; Explorerの表示する列数の選定
        ;------------------------------------------
        columns := 0            
        
        ;Explorer数が２の時
        if(explorerCount == 2){ 
        
             columns := 2
            
        ;Explorer数が２以外の時
        } else {                
        
            ;Explorer数が偶数：「Explorer数 / 2」の整数部分
            ;Explorer数が奇数：「Explorer数 / 2」の整数部分 + 1
            columns := (Mod(explorerCount, 2) == 0) ? floor(explorerCount / 2) : floor(explorerCount / 2) + 1
            
        }
        
        ;表示するExplorer数分繰り返す
        Loop, %explorerCount%
        {
             
            ;------------------------------------------
            ; Explorerの実行処理
            ;------------------------------------------
            explorerIDsBefore := GetExplorersIDs()
            Run, explorer.exe %openPath%
            Loop
            {
                ;Sleep, 10
                explorerIDsAfter := GetExplorersIDs()
                explorerNewID := GetNewExplorer(explorerIDsBefore, explorerIDsAfter)
                If StrLen(explorerNewID)
                    Break
            }
            
            ;------------------------------------------
            ; Explorerのウインドウサイズを取得
            ;------------------------------------------
            ;①ウインドウの幅の選定
            if(a_index <= columns){ 
            
            ;繰り返し数が列数以下の時（上の段）
            ;(モニターの右座標 - モニターの左座標) / 列数
            w := (mRight - mLeft) / columns
            
            } else {
            
                ;繰り返し数が列数より大きい時（下の段）
                ;Explorer数が偶数：(モニターの右座標 - モニターの左座標) / 列数
                ;Explorer数が奇数：(モニターの右座標 - モニターの左座標) / (Explorer数 - 列数)
                w := (Mod(explorerCount, 2) == 0) ? (mRight - mLeft) / columns : (mRight - mLeft) / (explorerCount - columns)
                 
            }

            ;②ウインドウの高さの選定
            ;Explorer数が２以下    ：モニターの上座標 - モニターの下座標
            ;Explorer数が２以下以外：モニターの上座標 - (モニターの下座標 / ２)
            h := (explorerCount <= 2) ? mBottom - mTop : (mBottom - mTop) / 2
             
            ;------------------------------------------
            ; Explorerの表示位置を取得
            ;------------------------------------------
            ;①ウインドウのX座標の選定
            if(a_index <= columns){ 
             
                ;繰り返し数が列数以下の時（上の段）
                ;モニターの左座標 + ((○個目のExplorer - 1) * ウインドウの幅)
                x := mLeft + ((a_index - 1) * w)
                 
            } else {                
             
                ;繰り返し数が列数より大きい時（下の段）
                ;Explorer数が２以下    ：モニターの左座標 + ウインドウの幅
                ;Explorer数が２以下以外：モニターの左座標 + ((○個目のExplorer - 1) * ウインドウの幅)
                x := (explorerCount == 2) ? mLeft + w : mLeft + ((a_index - 1 - columns) * w)
                 
            }
             
            ;②ウインドウのY座標の選定
            if(a_index <= columns){ 
            
                ;繰り返し数が列数以下の時（上の段）
                ;モニターの下座標
                y := mTop
                
            } else {                
            
                ;繰り返し数が列数より大きい時（下の段）
                ;Explorer数が偶数：モニターの下座標
                ;Explorer数が奇数：モニターの下座標 + ウインドウの高さ
                y := (explorerCount == 2) ? mTop : mTop + h
                
            }
             
            ;------------------------------------------
            ; Explorerの移動処理
            ;------------------------------------------
            ;Explorerが起動し終わるまで待つ
            WinWait, ahk_id %explorerNewID%
             
            ;Explorerを指定の表示位置に移動
            WinMove, ahk_id %explorerNewID%, , %x%, %y%, %w%, %h%
             
         }
         
         break
         
    }
    
}

;------------------------------------------
; Explorersを終了する
;------------------------------------------
ExitApp

;**********************************************************************
;* 処理概要：Explorerの現在のIDを取得する                             *
;* 処理説明：                                                         *
;* 引数    ：なし                                                     *
;* 返り値  ：なし                                                     *
;**********************************************************************
GetExplorersIDs()
{

    explorerIDs := ""
    
    for objExplorer in ComObjCreate("Shell.Application").Windows
    {
    
        strType := ""
        
        ; Gets the type name of the contained document object. "Document HTML" for IE windows. Should be empty for file Explorer windows.
        try strType := objExplorer.Type             
        
        strWindowID := ""
        
        ; Try to get the handle of the window. Some ghost Explorer in the ComObjCreate may return an empty handle
        try strWindowID := objExplorer.HWND         
        
        ; strType must be empty and strWindowID must not be empty
        if !StrLen(strType) and StrLen(strWindowID) 
            explorerIDs := explorerIDs . objExplorer.HWND . "|"
            
    }
    
    return explorerIDs

}

;**********************************************************************
;* 処理概要：新しいExplorerのIDを取得する                             *
;* 処理説明：                                                         *
;* 引数    ：iDsBefore                                                *
;*           iDsAfter                                                 *
;* 返り値  ：なし                                                     *
;**********************************************************************
GetNewExplorer(iDsBefore, iDsAfter)
{

    Loop, Parse, iDsAfter, |
        if !InStr(iDsBefore, A_LoopField)
            return A_LoopField

}
