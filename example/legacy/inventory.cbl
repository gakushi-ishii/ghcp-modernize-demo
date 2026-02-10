       IDENTIFICATION DIVISION.
       PROGRAM-ID. INVENTORY-MGMT.
       AUTHOR. LEGACY-SYSTEM.
      *================================================================
      * 在庫管理システム
      * - 在庫データの読み込み・表示
      * - 入出庫処理（在庫の増減）
      * - 在庫不足アラート（閾値チェック）
      * - 在庫レポート出力
      *================================================================

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT INVENTORY-FILE
               ASSIGN TO 'data/inventory.dat'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT TRANSACTION-FILE
               ASSIGN TO 'data/transactions.dat'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT REPORT-FILE
               ASSIGN TO 'output/report.txt'
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.

      * 在庫マスタファイル
       FD INVENTORY-FILE.
       01 INVENTORY-RECORD.
           05 INV-PRODUCT-ID     PIC X(10).
           05 INV-PRODUCT-NAME   PIC X(20).
           05 INV-QUANTITY        PIC 9(5).
           05 INV-UNIT-PRICE     PIC 9(7)V99.
           05 INV-THRESHOLD      PIC 9(5).

      * トランザクションファイル
       FD TRANSACTION-FILE.
       01 TRANSACTION-RECORD.
           05 TRN-PRODUCT-ID     PIC X(10).
           05 TRN-TYPE           PIC X(3).
           05 TRN-QUANTITY       PIC 9(5).

      * レポート出力ファイル
       FD REPORT-FILE.
       01 REPORT-RECORD           PIC X(80).

       WORKING-STORAGE SECTION.
       01 WS-EOF-INV              PIC X VALUE 'N'.
       01 WS-EOF-TRN              PIC X VALUE 'N'.
       01 WS-ITEM-COUNT           PIC 9(3) VALUE 0.
       01 WS-ALERT-COUNT          PIC 9(3) VALUE 0.
       01 WS-TOTAL-VALUE          PIC 9(10)V99 VALUE 0.

      * 在庫テーブル（最大100件）
       01 WS-INVENTORY-TABLE.
           05 WS-ITEM OCCURS 100 TIMES.
               10 WS-PROD-ID     PIC X(10).
               10 WS-PROD-NAME   PIC X(20).
               10 WS-QTY         PIC 9(5).
               10 WS-PRICE       PIC 9(7)V99.
               10 WS-THRESH      PIC 9(5).

       01 WS-IDX                  PIC 9(3).
       01 WS-FOUND                PIC X VALUE 'N'.
       01 WS-ITEM-VALUE           PIC 9(10)V99.
       01 WS-DISPLAY-QTY          PIC Z(4)9.
       01 WS-DISPLAY-PRICE        PIC Z(6)9.99.
       01 WS-DISPLAY-VALUE        PIC Z(9)9.99.
       01 WS-DISPLAY-TOTAL        PIC Z(9)9.99.

       PROCEDURE DIVISION.

      *----------------------------------------------------------------
      * メイン処理
      *----------------------------------------------------------------
       MAIN-PROCESS.
           PERFORM LOAD-INVENTORY
           PERFORM PROCESS-TRANSACTIONS
           PERFORM CHECK-LOW-STOCK
           PERFORM GENERATE-REPORT
           STOP RUN.

      *----------------------------------------------------------------
      * 在庫データファイルを読み込む
      *----------------------------------------------------------------
       LOAD-INVENTORY.
           OPEN INPUT INVENTORY-FILE
           MOVE 0 TO WS-ITEM-COUNT
           PERFORM UNTIL WS-EOF-INV = 'Y'
               READ INVENTORY-FILE
                   AT END
                       MOVE 'Y' TO WS-EOF-INV
                   NOT AT END
                       ADD 1 TO WS-ITEM-COUNT
                       MOVE INV-PRODUCT-ID TO
                           WS-PROD-ID(WS-ITEM-COUNT)
                       MOVE INV-PRODUCT-NAME TO
                           WS-PROD-NAME(WS-ITEM-COUNT)
                       MOVE INV-QUANTITY TO
                           WS-QTY(WS-ITEM-COUNT)
                       MOVE INV-UNIT-PRICE TO
                           WS-PRICE(WS-ITEM-COUNT)
                       MOVE INV-THRESHOLD TO
                           WS-THRESH(WS-ITEM-COUNT)
               END-READ
           END-PERFORM
           CLOSE INVENTORY-FILE
           DISPLAY "Inventory loaded: " WS-ITEM-COUNT " items".

      *----------------------------------------------------------------
      * 入出庫トランザクションを処理する
      *----------------------------------------------------------------
       PROCESS-TRANSACTIONS.
           OPEN INPUT TRANSACTION-FILE
           PERFORM UNTIL WS-EOF-TRN = 'Y'
               READ TRANSACTION-FILE
                   AT END
                       MOVE 'Y' TO WS-EOF-TRN
                   NOT AT END
                       PERFORM FIND-AND-UPDATE-ITEM
               END-READ
           END-PERFORM
           CLOSE TRANSACTION-FILE.

      *----------------------------------------------------------------
      * 商品IDで検索し、在庫を更新する
      *----------------------------------------------------------------
       FIND-AND-UPDATE-ITEM.
           MOVE 'N' TO WS-FOUND
           PERFORM VARYING WS-IDX FROM 1 BY 1
               UNTIL WS-IDX > WS-ITEM-COUNT OR WS-FOUND = 'Y'
               IF WS-PROD-ID(WS-IDX) = TRN-PRODUCT-ID
                   MOVE 'Y' TO WS-FOUND
                   EVALUATE TRN-TYPE
                       WHEN 'ADD'
                           ADD TRN-QUANTITY TO WS-QTY(WS-IDX)
                           DISPLAY "Stock in:  "
                               TRN-PRODUCT-ID " +" TRN-QUANTITY
                       WHEN 'SUB'
                           IF WS-QTY(WS-IDX) >= TRN-QUANTITY
                               SUBTRACT TRN-QUANTITY FROM
                                   WS-QTY(WS-IDX)
                               DISPLAY "Stock out: "
                                   TRN-PRODUCT-ID " -" TRN-QUANTITY
                           ELSE
                               DISPLAY "ERROR: Insufficient stock "
                                   TRN-PRODUCT-ID
                           END-IF
                       WHEN OTHER
                           DISPLAY "ERROR: Invalid type "
                               TRN-TYPE
                   END-EVALUATE
               END-IF
           END-PERFORM
           IF WS-FOUND = 'N'
               DISPLAY "ERROR: Product not found " TRN-PRODUCT-ID
           END-IF.

      *----------------------------------------------------------------
      * 在庫が閾値以下の商品をチェックする
      *----------------------------------------------------------------
       CHECK-LOW-STOCK.
           MOVE 0 TO WS-ALERT-COUNT
           PERFORM VARYING WS-IDX FROM 1 BY 1
               UNTIL WS-IDX > WS-ITEM-COUNT
               IF WS-QTY(WS-IDX) <= WS-THRESH(WS-IDX)
                   ADD 1 TO WS-ALERT-COUNT
                   MOVE WS-QTY(WS-IDX) TO WS-DISPLAY-QTY
                   DISPLAY "ALERT: Low stock - "
                       WS-PROD-NAME(WS-IDX)
                       " qty=" WS-DISPLAY-QTY
                       " threshold=" WS-THRESH(WS-IDX)
               END-IF
           END-PERFORM
           DISPLAY "Low stock alerts: " WS-ALERT-COUNT " items".

      *----------------------------------------------------------------
      * 在庫レポートを生成する
      *----------------------------------------------------------------
       GENERATE-REPORT.
           OPEN OUTPUT REPORT-FILE

           MOVE "=== Inventory Report ===" TO REPORT-RECORD
           WRITE REPORT-RECORD

           MOVE SPACES TO REPORT-RECORD
           STRING "ID"
               DELIMITED SIZE
               "          "
               DELIMITED SIZE
               "Name"
               DELIMITED SIZE
               "                "
               DELIMITED SIZE
               "  Qty"
               DELIMITED SIZE
               "     Price"
               DELIMITED SIZE
               "        Value"
               DELIMITED SIZE
               INTO REPORT-RECORD
           WRITE REPORT-RECORD

           MOVE SPACES TO REPORT-RECORD
           MOVE ALL "-" TO REPORT-RECORD
           WRITE REPORT-RECORD

           MOVE 0 TO WS-TOTAL-VALUE
           PERFORM VARYING WS-IDX FROM 1 BY 1
               UNTIL WS-IDX > WS-ITEM-COUNT
               COMPUTE WS-ITEM-VALUE =
                   WS-QTY(WS-IDX) * WS-PRICE(WS-IDX)
               ADD WS-ITEM-VALUE TO WS-TOTAL-VALUE
               MOVE WS-QTY(WS-IDX) TO WS-DISPLAY-QTY
               MOVE WS-PRICE(WS-IDX) TO WS-DISPLAY-PRICE
               MOVE WS-ITEM-VALUE TO WS-DISPLAY-VALUE
               MOVE SPACES TO REPORT-RECORD
               STRING WS-PROD-ID(WS-IDX)
                   DELIMITED SIZE
                   WS-PROD-NAME(WS-IDX)
                   DELIMITED SIZE
                   WS-DISPLAY-QTY
                   DELIMITED SIZE
                   WS-DISPLAY-PRICE
                   DELIMITED SIZE
                   WS-DISPLAY-VALUE
                   DELIMITED SIZE
                   INTO REPORT-RECORD
               WRITE REPORT-RECORD
           END-PERFORM

           MOVE SPACES TO REPORT-RECORD
           MOVE ALL "-" TO REPORT-RECORD
           WRITE REPORT-RECORD

           MOVE WS-TOTAL-VALUE TO WS-DISPLAY-TOTAL
           MOVE SPACES TO REPORT-RECORD
           STRING "Total inventory value: "
               DELIMITED SIZE
               WS-DISPLAY-TOTAL
               DELIMITED SIZE
               INTO REPORT-RECORD
           WRITE REPORT-RECORD

           CLOSE REPORT-FILE
           DISPLAY "Report generated: output/report.txt".
