"""在庫管理システム テスト

COBOL 版在庫管理システムの入出力仕様に基づき、
Python 版の全ビジネスロジックをテストする。
"""

import csv
import json
import os

import pytest

from src.inventory import InventoryManager, Product, Transaction


# ==============================================================
# フィクスチャ
# ==============================================================


@pytest.fixture
def manager() -> InventoryManager:
    """テスト用の InventoryManager（初期データ付き）を作成する"""
    mgr = InventoryManager()
    mgr.products = [
        Product("PROD001", "Notebook PC", 150, 150000.0, 10),
        Product("PROD002", "Mouse", 500, 2500.0, 50),
        Product("PROD003", "Keyboard", 300, 4500.0, 30),
        Product("PROD004", "Monitor", 20, 35000.0, 5),
        Product("PROD005", "USB Cable", 1000, 800.0, 100),
    ]
    return mgr


@pytest.fixture
def sample_inventory_csv(tmp_path) -> str:
    """テスト用在庫 CSV ファイルを作成する"""
    filepath = tmp_path / "inventory.csv"
    with open(filepath, "w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=[
                "product_id", "product_name", "quantity",
                "unit_price", "threshold",
            ],
        )
        writer.writeheader()
        writer.writerow({
            "product_id": "PROD001", "product_name": "Notebook PC",
            "quantity": 150, "unit_price": 150000.0, "threshold": 10,
        })
        writer.writerow({
            "product_id": "PROD002", "product_name": "Mouse",
            "quantity": 500, "unit_price": 2500.0, "threshold": 50,
        })
    return str(filepath)


@pytest.fixture
def sample_transactions_csv(tmp_path) -> str:
    """テスト用トランザクション CSV ファイルを作成する"""
    filepath = tmp_path / "transactions.csv"
    with open(filepath, "w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(
            f, fieldnames=["product_id", "type", "quantity"],
        )
        writer.writeheader()
        writer.writerow({"product_id": "PROD001", "type": "ADD", "quantity": 20})
        writer.writerow({"product_id": "PROD002", "type": "SUB", "quantity": 100})
    return str(filepath)


# ==============================================================
# 在庫データ読み込みテスト
# ==============================================================


class TestLoadInventory:
    """在庫データ読み込みのテスト"""

    def test_load_inventory_count(self, sample_inventory_csv: str) -> None:
        """CSV から正しい件数が読み込めること"""
        mgr = InventoryManager()
        count = mgr.load_inventory(sample_inventory_csv)
        assert count == 2

    def test_load_inventory_data(self, sample_inventory_csv: str) -> None:
        """CSV から正しいデータが読み込めること"""
        mgr = InventoryManager()
        mgr.load_inventory(sample_inventory_csv)
        assert mgr.products[0].product_id == "PROD001"
        assert mgr.products[0].product_name == "Notebook PC"
        assert mgr.products[0].quantity == 150
        assert mgr.products[0].unit_price == 150000.0
        assert mgr.products[0].threshold == 10


# ==============================================================
# 商品検索テスト
# ==============================================================


class TestFindProduct:
    """商品検索のテスト"""

    def test_find_existing_product(self, manager: InventoryManager) -> None:
        """存在する商品IDで検索できること"""
        product = manager.find_product("PROD001")
        assert product is not None
        assert product.product_name == "Notebook PC"

    def test_find_nonexistent_product(self, manager: InventoryManager) -> None:
        """存在しない商品IDで None が返ること"""
        product = manager.find_product("PROD999")
        assert product is None


# ==============================================================
# 入庫処理テスト
# ==============================================================


class TestAddStock:
    """入庫処理のテスト"""

    def test_add_stock_success(self, manager: InventoryManager) -> None:
        """入庫処理で在庫が正しく増えること"""
        original_qty = manager.find_product("PROD001").quantity
        result = manager.add_stock("PROD001", 20)
        assert result is True
        assert manager.find_product("PROD001").quantity == original_qty + 20

    def test_add_stock_product_not_found(self, manager: InventoryManager) -> None:
        """存在しない商品への入庫が失敗すること"""
        result = manager.add_stock("PROD999", 10)
        assert result is False


# ==============================================================
# 出庫処理テスト
# ==============================================================


class TestRemoveStock:
    """出庫処理のテスト"""

    def test_remove_stock_success(self, manager: InventoryManager) -> None:
        """出庫処理で在庫が正しく減ること"""
        original_qty = manager.find_product("PROD002").quantity
        result = manager.remove_stock("PROD002", 100)
        assert result is True
        assert manager.find_product("PROD002").quantity == original_qty - 100

    def test_remove_stock_insufficient(self, manager: InventoryManager) -> None:
        """在庫不足時に出庫が失敗すること（在庫数は変わらない）"""
        result = manager.remove_stock("PROD004", 999)
        assert result is False
        assert manager.find_product("PROD004").quantity == 20

    def test_remove_stock_product_not_found(self, manager: InventoryManager) -> None:
        """存在しない商品への出庫が失敗すること"""
        result = manager.remove_stock("PROD999", 10)
        assert result is False


# ==============================================================
# トランザクション処理テスト
# ==============================================================


class TestProcessTransaction:
    """トランザクション処理のテスト"""

    def test_add_transaction(self, manager: InventoryManager) -> None:
        """ADD トランザクションで在庫が増えること"""
        trn = Transaction("PROD001", "ADD", 50)
        result = manager.process_transaction(trn)
        assert result["success"] is True
        assert manager.find_product("PROD001").quantity == 200

    def test_sub_transaction(self, manager: InventoryManager) -> None:
        """SUB トランザクションで在庫が減ること"""
        trn = Transaction("PROD002", "SUB", 100)
        result = manager.process_transaction(trn)
        assert result["success"] is True
        assert manager.find_product("PROD002").quantity == 400

    def test_sub_insufficient_stock(self, manager: InventoryManager) -> None:
        """在庫不足の SUB トランザクションが失敗すること"""
        trn = Transaction("PROD004", "SUB", 999)
        result = manager.process_transaction(trn)
        assert result["success"] is False
        assert "Insufficient stock" in result["message"]

    def test_transaction_unknown_product(self, manager: InventoryManager) -> None:
        """未登録商品のトランザクションが失敗すること"""
        trn = Transaction("PROD999", "ADD", 10)
        result = manager.process_transaction(trn)
        assert result["success"] is False
        assert "Product not found" in result["message"]

    def test_transaction_invalid_type(self, manager: InventoryManager) -> None:
        """不正なトランザクション種別が失敗すること"""
        trn = Transaction("PROD001", "XXX", 10)
        result = manager.process_transaction(trn)
        assert result["success"] is False
        assert "Invalid type" in result["message"]

    def test_process_transactions_from_file(
        self,
        sample_transactions_csv: str,
    ) -> None:
        """ファイルからトランザクションを正しく処理できること"""
        mgr = InventoryManager()
        mgr.products = [
            Product("PROD001", "Notebook PC", 150, 150000.0, 10),
            Product("PROD002", "Mouse", 500, 2500.0, 50),
        ]
        results = mgr.process_transactions_from_file(sample_transactions_csv)
        assert len(results) == 2
        assert results[0]["success"] is True   # ADD
        assert results[1]["success"] is True   # SUB
        assert mgr.find_product("PROD001").quantity == 170
        assert mgr.find_product("PROD002").quantity == 400


# ==============================================================
# 在庫不足チェックテスト
# ==============================================================


class TestCheckLowStock:
    """在庫不足チェックのテスト"""

    def test_no_alerts_when_stock_above_threshold(
        self, manager: InventoryManager,
    ) -> None:
        """全商品が閾値を超えている場合、アラートがないこと"""
        alerts = manager.check_low_stock()
        assert len(alerts) == 0

    def test_alert_when_stock_at_threshold(
        self, manager: InventoryManager,
    ) -> None:
        """在庫数が閾値ちょうどの場合、アラートが出ること"""
        manager.find_product("PROD001").quantity = 10  # threshold=10
        alerts = manager.check_low_stock()
        alert_ids = [a["product_id"] for a in alerts]
        assert "PROD001" in alert_ids

    def test_alert_when_stock_below_threshold(
        self, manager: InventoryManager,
    ) -> None:
        """在庫数が閾値未満の場合、アラートが出ること"""
        manager.find_product("PROD001").quantity = 5  # threshold=10
        alerts = manager.check_low_stock()
        alert_ids = [a["product_id"] for a in alerts]
        assert "PROD001" in alert_ids


# ==============================================================
# 在庫金額計算テスト
# ==============================================================


class TestCalculateInventoryValue:
    """在庫金額計算のテスト"""

    def test_total_value(self, manager: InventoryManager) -> None:
        """在庫合計金額が正しく計算されること"""
        # PROD001: 150 * 150000 = 22,500,000
        # PROD002: 500 * 2500   =  1,250,000
        # PROD003: 300 * 4500   =  1,350,000
        # PROD004:  20 * 35000  =    700,000
        # PROD005: 1000 * 800   =    800,000
        # Total                 = 26,600,000
        expected = 26600000.0
        assert manager.calculate_inventory_value() == expected

    def test_value_with_empty_inventory(self) -> None:
        """在庫が空の場合、合計金額が 0 であること"""
        mgr = InventoryManager()
        assert mgr.calculate_inventory_value() == 0.0


# ==============================================================
# レポート生成テスト
# ==============================================================


class TestGenerateReport:
    """レポート生成のテスト"""

    def test_report_content(
        self, manager: InventoryManager, tmp_path,
    ) -> None:
        """レポートの内容が正しいこと"""
        report_path = str(tmp_path / "output" / "report.json")
        report = manager.generate_report(report_path)

        assert report["item_count"] == 5
        assert report["total_value"] == 26600000.0
        assert len(report["items"]) == 5

    def test_report_file_created(
        self, manager: InventoryManager, tmp_path,
    ) -> None:
        """レポートファイルが生成されること"""
        report_path = str(tmp_path / "output" / "report.json")
        manager.generate_report(report_path)
        assert os.path.exists(report_path)

    def test_report_file_is_valid_json(
        self, manager: InventoryManager, tmp_path,
    ) -> None:
        """レポートファイルが有効な JSON であること"""
        report_path = str(tmp_path / "output" / "report.json")
        manager.generate_report(report_path)

        with open(report_path, "r", encoding="utf-8") as f:
            saved = json.load(f)
        assert saved["item_count"] == 5
        assert len(saved["items"]) == 5
