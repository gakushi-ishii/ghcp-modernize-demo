"""在庫管理システム（モダン版）

レガシー COBOL プログラムを Python にモダナイズした版。
機能:
- 在庫データの読み込み・表示
- 入出庫処理（在庫の増減）
- 在庫不足アラート（閾値チェック）
- 在庫レポート出力
"""

import csv
import json
import os
from dataclasses import dataclass, asdict
from typing import Optional


@dataclass
class Product:
    """商品データクラス"""
    product_id: str
    product_name: str
    quantity: int
    unit_price: float
    threshold: int


@dataclass
class Transaction:
    """トランザクションデータクラス"""
    product_id: str
    type: str       # "ADD"(入庫) or "SUB"(出庫)
    quantity: int


class InventoryManager:
    """在庫管理クラス

    在庫データの読み込み、入出庫処理、在庫チェック、レポート生成を行う。
    """

    def __init__(self) -> None:
        self.products: list[Product] = []

    def load_inventory(self, filepath: str) -> int:
        """在庫データを CSV ファイルから読み込む

        Args:
            filepath: 在庫 CSV ファイルのパス

        Returns:
            読み込んだ商品の件数
        """
        self.products = []
        with open(filepath, "r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            for row in reader:
                product = Product(
                    product_id=row["product_id"],
                    product_name=row["product_name"],
                    quantity=int(row["quantity"]),
                    unit_price=float(row["unit_price"]),
                    threshold=int(row["threshold"]),
                )
                self.products.append(product)
        return len(self.products)

    def find_product(self, product_id: str) -> Optional[Product]:
        """商品IDで商品を検索する

        Args:
            product_id: 検索する商品ID

        Returns:
            見つかった商品。見つからない場合は None
        """
        for product in self.products:
            if product.product_id == product_id:
                return product
        return None

    def add_stock(self, product_id: str, quantity: int) -> bool:
        """入庫処理: 在庫を追加する

        Args:
            product_id: 対象商品ID
            quantity: 追加数量

        Returns:
            処理成功なら True、商品未登録なら False
        """
        product = self.find_product(product_id)
        if product is None:
            return False
        product.quantity += quantity
        return True

    def remove_stock(self, product_id: str, quantity: int) -> bool:
        """出庫処理: 在庫を減らす

        Args:
            product_id: 対象商品ID
            quantity: 出庫数量

        Returns:
            処理成功なら True、商品未登録または在庫不足なら False
        """
        product = self.find_product(product_id)
        if product is None:
            return False
        if product.quantity < quantity:
            return False
        product.quantity -= quantity
        return True

    def process_transaction(self, transaction: Transaction) -> dict:
        """トランザクションを1件処理する

        Args:
            transaction: 処理するトランザクション

        Returns:
            処理結果を含む辞書
        """
        result: dict = {
            "product_id": transaction.product_id,
            "type": transaction.type,
            "quantity": transaction.quantity,
            "success": False,
            "message": "",
        }

        if transaction.type == "ADD":
            if self.add_stock(transaction.product_id, transaction.quantity):
                result["success"] = True
                result["message"] = (
                    f"Stock in:  {transaction.product_id} "
                    f"+{transaction.quantity}"
                )
            else:
                result["message"] = (
                    f"ERROR: Product not found {transaction.product_id}"
                )

        elif transaction.type == "SUB":
            product = self.find_product(transaction.product_id)
            if product is None:
                result["message"] = (
                    f"ERROR: Product not found {transaction.product_id}"
                )
            elif product.quantity < transaction.quantity:
                result["message"] = (
                    f"ERROR: Insufficient stock {transaction.product_id}"
                )
            else:
                self.remove_stock(transaction.product_id, transaction.quantity)
                result["success"] = True
                result["message"] = (
                    f"Stock out: {transaction.product_id} "
                    f"-{transaction.quantity}"
                )
        else:
            result["message"] = (
                f"ERROR: Invalid type {transaction.type}"
            )

        return result

    def process_transactions_from_file(self, filepath: str) -> list[dict]:
        """トランザクションファイルを読み込んで一括処理する

        Args:
            filepath: トランザクション CSV ファイルのパス

        Returns:
            各トランザクションの処理結果リスト
        """
        results: list[dict] = []
        with open(filepath, "r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            for row in reader:
                transaction = Transaction(
                    product_id=row["product_id"],
                    type=row["type"],
                    quantity=int(row["quantity"]),
                )
                result = self.process_transaction(transaction)
                results.append(result)
        return results

    def check_low_stock(self) -> list[dict]:
        """在庫が閾値以下の商品をチェックする

        Returns:
            在庫不足の商品情報リスト
        """
        alerts: list[dict] = []
        for product in self.products:
            if product.quantity <= product.threshold:
                alerts.append({
                    "product_id": product.product_id,
                    "product_name": product.product_name,
                    "quantity": product.quantity,
                    "threshold": product.threshold,
                })
        return alerts

    def calculate_inventory_value(self) -> float:
        """在庫の合計金額を計算する

        Returns:
            全商品の在庫金額合計
        """
        return sum(p.quantity * p.unit_price for p in self.products)

    def generate_report(self, output_path: str) -> dict:
        """在庫レポートを JSON ファイルに生成する

        Args:
            output_path: レポート出力先ファイルパス

        Returns:
            レポート内容の辞書
        """
        os.makedirs(os.path.dirname(output_path), exist_ok=True)

        report: dict = {
            "item_count": len(self.products),
            "items": [],
            "total_value": 0.0,
            "alerts": [],
        }

        for product in self.products:
            item_value = product.quantity * product.unit_price
            report["items"].append({
                "product_id": product.product_id,
                "product_name": product.product_name,
                "quantity": product.quantity,
                "unit_price": product.unit_price,
                "item_value": item_value,
            })

        report["total_value"] = self.calculate_inventory_value()
        report["alerts"] = self.check_low_stock()

        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(report, f, ensure_ascii=False, indent=2)

        return report


def main() -> None:
    """メイン処理"""
    base_dir = os.path.dirname(os.path.abspath(__file__))
    data_dir = os.path.join(base_dir, "..", "data")
    output_dir = os.path.join(base_dir, "..", "output")

    manager = InventoryManager()

    # 1. 在庫データ読み込み
    inventory_file = os.path.join(data_dir, "inventory.csv")
    count = manager.load_inventory(inventory_file)
    print(f"Inventory loaded: {count} items")

    # 2. トランザクション処理
    transaction_file = os.path.join(data_dir, "transactions.csv")
    if os.path.exists(transaction_file):
        results = manager.process_transactions_from_file(transaction_file)
        for result in results:
            print(result["message"])

    # 3. 在庫不足チェック
    alerts = manager.check_low_stock()
    for alert in alerts:
        print(
            f"ALERT: Low stock - {alert['product_name']} "
            f"qty={alert['quantity']} threshold={alert['threshold']}"
        )
    print(f"Low stock alerts: {len(alerts)} items")

    # 4. レポート生成
    report_path = os.path.join(output_dir, "report.json")
    manager.generate_report(report_path)
    print(f"Report generated: {report_path}")


if __name__ == "__main__":
    main()
