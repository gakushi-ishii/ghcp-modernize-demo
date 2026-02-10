Option Explicit

' ================================================
' 在庫管理システム (VBScript版)
' ファイル: inventory.vbs
' 機能: 入出庫処理、在庫アラート、レポート出力
' ================================================

' グローバル定数
Const DATA_DIR = "data\"
Const INVENTORY_FILE = "inventory.csv"
Const TRANS_FILE = "transactions.csv"

' FileSystemObject
Dim fso
Set fso = CreateObject("Scripting.FileSystemObject")

' スクリプトのディレクトリを取得
Dim scriptDir
scriptDir = fso.GetParentFolderName(WScript.ScriptFullName) & "\"

' メイン処理
Call Main()

' ================================================
' メイン処理
' ================================================
Sub Main()
    Dim args, cmd
    Set args = WScript.Arguments
    
    If args.Count = 0 Then
        Call ShowUsage()
        WScript.Quit 1
    End If
    
    cmd = LCase(args(0))
    
    Select Case cmd
        Case "list"
            Call ShowInventoryList()
        Case "in"
            If args.Count < 3 Then
                WScript.Echo "使用方法: cscript //nologo inventory.vbs in <商品コード> <数量>"
                WScript.Quit 1
            End If
            Call ProcessStockIn(args(1), CLng(args(2)))
        Case "out"
            If args.Count < 3 Then
                WScript.Echo "使用方法: cscript //nologo inventory.vbs out <商品コード> <数量>"
                WScript.Quit 1
            End If
            Call ProcessStockOut(args(1), CLng(args(2)))
        Case "alert"
            Call ShowStockAlert()
        Case "report"
            Call ShowStockReport()
        Case Else
            WScript.Echo "不明なコマンド: " & cmd
            Call ShowUsage()
            WScript.Quit 1
    End Select
End Sub

' ================================================
' 使用方法を表示
' ================================================
Sub ShowUsage()
    WScript.Echo "================================================"
    WScript.Echo "在庫管理システム"
    WScript.Echo "================================================"
    WScript.Echo ""
    WScript.Echo "使用方法:"
    WScript.Echo "  cscript //nologo inventory.vbs <コマンド> [引数]"
    WScript.Echo ""
    WScript.Echo "コマンド一覧:"
    WScript.Echo "  list              在庫一覧を表示"
    WScript.Echo "  in <コード> <数量>  入庫処理（在庫増加）"
    WScript.Echo "  out <コード> <数量> 出庫処理（在庫減少）"
    WScript.Echo "  alert             在庫不足アラートを表示"
    WScript.Echo "  report            在庫レポートを出力"
End Sub

' ================================================
' 在庫データを読み込み（連想配列を返す）
' ================================================
Function LoadInventory()
    Dim dict, filePath, ts, line, fields, isHeader
    Set dict = CreateObject("Scripting.Dictionary")
    
    filePath = scriptDir & DATA_DIR & INVENTORY_FILE
    
    If Not fso.FileExists(filePath) Then
        WScript.Echo "エラー: ファイルが見つかりません - " & filePath
        WScript.Quit 1
    End If
    
    Set ts = fso.OpenTextFile(filePath, 1, False)
    isHeader = True
    
    Do While Not ts.AtEndOfStream
        line = ts.ReadLine()
        If isHeader Then
            isHeader = False
        Else
            If Len(Trim(line)) > 0 Then
                fields = Split(line, ",")
                If UBound(fields) >= 4 Then
                    dict.Add fields(0), Array(fields(1), CLng(fields(2)), CLng(fields(3)), CLng(fields(4)))
                End If
            End If
        End If
    Loop
    
    ts.Close
    Set LoadInventory = dict
End Function

' ================================================
' 在庫データを保存
' ================================================
Sub SaveInventory(dict)
    Dim filePath, ts, key, item
    
    filePath = scriptDir & DATA_DIR & INVENTORY_FILE
    Set ts = fso.CreateTextFile(filePath, True, False)
    
    ts.WriteLine "商品コード,商品名,現在庫数,最低在庫数,単価"
    
    For Each key In dict.Keys
        item = dict(key)
        ts.WriteLine key & "," & item(0) & "," & item(1) & "," & item(2) & "," & item(3)
    Next
    
    ts.Close
End Sub

' ================================================
' 入出庫履歴を記録
' ================================================
Sub RecordTransaction(productCode, transType, quantity)
    Dim filePath, ts, transDate
    
    filePath = scriptDir & DATA_DIR & TRANS_FILE
    
    If Not fso.FileExists(filePath) Then
        Set ts = fso.CreateTextFile(filePath, True, False)
        ts.WriteLine "日時,商品コード,処理種別,数量"
        ts.Close
    End If
    
    Set ts = fso.OpenTextFile(filePath, 8, True)
    
    transDate = FormatDateTime(Now(), 0) & " " & FormatDateTime(Now(), 4)
    ts.WriteLine transDate & "," & productCode & "," & transType & "," & quantity
    
    ts.Close
End Sub

' ================================================
' 在庫一覧を表示
' ================================================
Sub ShowInventoryList()
    Dim dict, key, item
    Set dict = LoadInventory()
    
    WScript.Echo "================================================"
    WScript.Echo "在庫一覧"
    WScript.Echo "================================================"
    WScript.Echo String(60, "-")
    WScript.Echo "コード" & vbTab & "商品名" & vbTab & vbTab & "在庫数" & vbTab & "閾値"
    WScript.Echo String(60, "-")
    
    For Each key In dict.Keys
        item = dict(key)
        WScript.Echo key & vbTab & item(0) & vbTab & item(1) & vbTab & item(2)
    Next
    
    WScript.Echo String(60, "-")
    WScript.Echo "合計 " & dict.Count & " 件"
End Sub

' ================================================
' 入庫処理
' ================================================
Sub ProcessStockIn(productCode, quantity)
    Dim dict, item, newQty
    Set dict = LoadInventory()
    
    If Not dict.Exists(productCode) Then
        WScript.Echo "エラー: 商品が見つかりません - " & productCode
        WScript.Quit 1
    End If
    
    If quantity <= 0 Then
        WScript.Echo "エラー: 数量は1以上を指定してください"
        WScript.Quit 1
    End If
    
    item = dict(productCode)
    newQty = item(1) + quantity
    dict(productCode) = Array(item(0), newQty, item(2), item(3))
    
    Call SaveInventory(dict)
    Call RecordTransaction(productCode, "IN", quantity)
    
    WScript.Echo "================================================"
    WScript.Echo "入庫処理完了"
    WScript.Echo "================================================"
    WScript.Echo "商品コード: " & productCode
    WScript.Echo "商品名: " & item(0)
    WScript.Echo "入庫数量: " & quantity
    WScript.Echo "変更前在庫: " & item(1)
    WScript.Echo "変更後在庫: " & newQty
End Sub

' ================================================
' 出庫処理
' ================================================
Sub ProcessStockOut(productCode, quantity)
    Dim dict, item, newQty
    Set dict = LoadInventory()
    
    If Not dict.Exists(productCode) Then
        WScript.Echo "エラー: 商品が見つかりません - " & productCode
        WScript.Quit 1
    End If
    
    If quantity <= 0 Then
        WScript.Echo "エラー: 数量は1以上を指定してください"
        WScript.Quit 1
    End If
    
    item = dict(productCode)
    
    If item(1) < quantity Then
        WScript.Echo "エラー: 在庫が不足しています"
        WScript.Echo "商品: " & item(0)
        WScript.Echo "現在庫: " & item(1)
        WScript.Echo "出庫要求: " & quantity
        WScript.Quit 1
    End If
    
    newQty = item(1) - quantity
    dict(productCode) = Array(item(0), newQty, item(2), item(3))
    
    Call SaveInventory(dict)
    Call RecordTransaction(productCode, "OUT", quantity)
    
    WScript.Echo "================================================"
    WScript.Echo "出庫処理完了"
    WScript.Echo "================================================"
    WScript.Echo "商品コード: " & productCode
    WScript.Echo "商品名: " & item(0)
    WScript.Echo "出庫数量: " & quantity
    WScript.Echo "変更前在庫: " & item(1)
    WScript.Echo "変更後在庫: " & newQty
    
    If newQty <= item(2) Then
        WScript.Echo ""
        WScript.Echo "【警告】在庫が閾値以下です！（閾値: " & item(2) & "）"
    End If
End Sub

' ================================================
' 在庫不足アラートを表示
' ================================================
Sub ShowStockAlert()
    Dim dict, key, item, alertCount
    Set dict = LoadInventory()
    
    WScript.Echo "================================================"
    WScript.Echo "在庫不足アラート"
    WScript.Echo "================================================"
    
    alertCount = 0
    
    For Each key In dict.Keys
        item = dict(key)
        If item(1) <= item(2) Then
            alertCount = alertCount + 1
            WScript.Echo ""
            WScript.Echo "[警告] " & key & " - " & item(0)
            WScript.Echo "  現在庫: " & item(1) & " / 閾値: " & item(2)
            WScript.Echo "  不足数: " & (item(2) - item(1) + 1)
        End If
    Next
    
    WScript.Echo ""
    WScript.Echo String(60, "-")
    
    If alertCount = 0 Then
        WScript.Echo "在庫不足の商品はありません。"
    Else
        WScript.Echo "アラート対象: " & alertCount & " 件"
    End If
End Sub

' ================================================
' 在庫レポートを出力
' ================================================
Sub ShowStockReport()
    Dim dict, key, item
    Dim totalQty, totalValue, itemValue
    Set dict = LoadInventory()
    
    totalQty = 0
    totalValue = 0
    
    WScript.Echo "================================================"
    WScript.Echo "在庫レポート"
    WScript.Echo "================================================"
    WScript.Echo "出力日時: " & Now()
    WScript.Echo ""
    WScript.Echo String(70, "-")
    WScript.Echo "コード" & vbTab & "商品名" & vbTab & vbTab & "在庫" & vbTab & "単価" & vbTab & vbTab & "在庫金額"
    WScript.Echo String(70, "-")
    
    For Each key In dict.Keys
        item = dict(key)
        itemValue = item(1) * item(3)
        totalQty = totalQty + item(1)
        totalValue = totalValue + itemValue
        
        WScript.Echo key & vbTab & item(0) & vbTab & item(1) & vbTab & FormatNumber(item(3), 0) & vbTab & FormatNumber(itemValue, 0)
    Next
    
    WScript.Echo String(70, "-")
    WScript.Echo ""
    WScript.Echo "【サマリー】"
    WScript.Echo "  総商品数: " & dict.Count & " 種類"
    WScript.Echo "  総在庫数: " & totalQty & " 個"
    WScript.Echo "  総在庫金額: " & FormatNumber(totalValue, 0) & " 円"
    
    Dim alertCount
    alertCount = 0
    For Each key In dict.Keys
        item = dict(key)
        If item(1) <= item(2) Then
            alertCount = alertCount + 1
        End If
    Next
    
    If alertCount > 0 Then
        WScript.Echo ""
        WScript.Echo "【注意】在庫不足商品: " & alertCount & " 件"
        WScript.Echo "  詳細は alert コマンドで確認してください。"
    End If
End Sub
