# 在庫管理システム（COBOL版）— 動作確認手順

## 前提条件

- GnuCOBOL（`cobc`）がインストールされていること
  - Ubuntu/Debian: `sudo apt install gnucobol`
  - macOS (Homebrew): `brew install gnucobol`

## ディレクトリ構成

```
example/legacy/
├── inventory.cbl              # メインプログラム
├── data/
│   ├── inventory.dat          # 在庫マスタデータ
│   └── transactions.dat       # 入出庫トランザクション
├── output/                    # レポート出力先（実行時に自動作成）
└── docs/
    ├── how-to-run.md          # このファイル
    └── specification.md       # 入出力仕様
```

## ビルド手順

```bash
cd example/legacy
cobc -x -o inventory inventory.cbl
```

## 実行手順

```bash
# output ディレクトリを作成（初回のみ）
mkdir -p output

# 実行
./inventory
```

## 期待される出力

### コンソール出力

```
Inventory loaded: 005 items
Stock in:  PROD001    +00020
Stock out: PROD002    -00100
Stock in:  PROD003    +00050
Stock out: PROD004    -00003
ERROR: Product not found PROD006
Low stock alerts: 001 items
Report generated: output/report.txt
```

### レポートファイル (output/report.txt)

在庫一覧と合計金額が出力されます。

## トラブルシューティング

- `cobc: command not found` → GnuCOBOL がインストールされていません
- `inventory.dat: No such file` → `example/legacy/` ディレクトリで実行してください
