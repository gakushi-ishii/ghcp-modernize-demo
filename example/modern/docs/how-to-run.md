# 在庫管理システム（Python版）— 動作確認手順

## 前提条件

- Python 3.10 以上がインストールされていること
- pip が利用可能であること

## ディレクトリ構成

```
example/modern/
├── src/
│   └── inventory.py           # メインプログラム
├── tests/
│   └── test_inventory.py      # テストコード
├── data/
│   ├── inventory.csv          # 在庫マスタデータ
│   └── transactions.csv       # 入出庫トランザクション
├── output/                    # レポート出力先（実行時に自動作成）
├── requirements.txt           # 依存パッケージ
└── docs/
    └── how-to-run.md          # このファイル
```

## セットアップ

```bash
cd example/modern

# 仮想環境の作成（推奨）
python -m venv .venv
source .venv/bin/activate      # Linux/macOS
# .venv\Scripts\activate       # Windows

# 依存パッケージのインストール
pip install -r requirements.txt
```

## テストの実行

```bash
cd example/modern
python -m pytest tests/ -v
```

### 期待される結果

```
tests/test_inventory.py::TestLoadInventory::test_load_inventory_count PASSED
tests/test_inventory.py::TestLoadInventory::test_load_inventory_data PASSED
tests/test_inventory.py::TestFindProduct::test_find_existing_product PASSED
tests/test_inventory.py::TestFindProduct::test_find_nonexistent_product PASSED
tests/test_inventory.py::TestAddStock::test_add_stock_success PASSED
tests/test_inventory.py::TestAddStock::test_add_stock_product_not_found PASSED
tests/test_inventory.py::TestRemoveStock::test_remove_stock_success PASSED
tests/test_inventory.py::TestRemoveStock::test_remove_stock_insufficient PASSED
tests/test_inventory.py::TestRemoveStock::test_remove_stock_product_not_found PASSED
tests/test_inventory.py::TestProcessTransaction::test_add_transaction PASSED
tests/test_inventory.py::TestProcessTransaction::test_sub_transaction PASSED
tests/test_inventory.py::TestProcessTransaction::test_sub_insufficient_stock PASSED
tests/test_inventory.py::TestProcessTransaction::test_transaction_unknown_product PASSED
tests/test_inventory.py::TestProcessTransaction::test_transaction_invalid_type PASSED
tests/test_inventory.py::TestProcessTransaction::test_process_transactions_from_file PASSED
tests/test_inventory.py::TestCheckLowStock::test_no_alerts_when_stock_above_threshold PASSED
tests/test_inventory.py::TestCheckLowStock::test_alert_when_stock_at_threshold PASSED
tests/test_inventory.py::TestCheckLowStock::test_alert_when_stock_below_threshold PASSED
tests/test_inventory.py::TestCalculateInventoryValue::test_total_value PASSED
tests/test_inventory.py::TestCalculateInventoryValue::test_value_with_empty_inventory PASSED
tests/test_inventory.py::TestGenerateReport::test_report_content PASSED
tests/test_inventory.py::TestGenerateReport::test_report_file_created PASSED
tests/test_inventory.py::TestGenerateReport::test_report_file_is_valid_json PASSED

23 passed
```

## アプリケーションの実行

```bash
cd example/modern
python -m src.inventory
```

### 期待されるコンソール出力

```
Inventory loaded: 5 items
Stock in:  PROD001 +20
Stock out: PROD002 -100
Stock in:  PROD003 +50
Stock out: PROD004 -3
ERROR: Product not found PROD006
ALERT: Low stock - Monitor qty=17 threshold=5
Low stock alerts: 1 items
Report generated: .../output/report.json
```

> ※ PROD004 のトランザクション処理後、在庫は 17 になりますが閾値(5)を上回っているためアラートにはなりません。
> ただし COBOL 版と同じ仕様 `quantity <= threshold` に基づきチェックされるため、
> 初期データによっては結果が変わります。

## レガシー版（COBOL）との比較

| 観点 | COBOL版 | Python版 |
|---|---|---|
| データ形式 | 固定長テキスト | CSV |
| レポート形式 | テキスト | JSON |
| テスト | なし | pytest (23テスト) |
| 入出力仕様 | 同じ | 同じ |
