---
applyTo: "workspace/legacy/work/**"
---

# Step 1: レガシーアプリ生成ルール

このインストラクションは `workspace/legacy/work/` で作業する際に自動適用されます。
共通制約（環境制約、エンコーディング）は `.github/copilot-instructions.md` を参照してください。

---

## 言語別の実行環境（Windows 前提）

### ✅ エージェントが動作確認**可能**な言語

| 言語 | 実行コマンド | ランタイム |
|------|------------|----------|
| **VBScript** | `cscript //NoLogo script.vbs` | Windows 標準 |
| **Batch Script** | `script.bat` | Windows 標準 |
| **JScript** | `cscript //NoLogo script.js` | Windows 標準 |
| **PowerShell** | `powershell -File script.ps1` | Windows 標準 |

### ⚠️ エージェントが動作確認**困難**な言語

| 言語 | 必要な環境 |
|------|----------|
| COBOL | GnuCOBOL |
| VB6 | VB6 IDE/ランタイム |
| FORTRAN | gfortran |
| Perl | Strawberry Perl 等 |

> 動作確認できない言語の場合、構文チェック・ドキュメント検証・データ整合性確認を代替で実施します。

---

## アプリケーション設計

- **CLI アプリケーション** として実装
- **サンプルデータ必須** — クローン直後に動作確認できる状態に
- **ビジネスロジック必須** — 計算処理・バリデーション・条件分岐を最低 2～3 個含める
- **1 ファイル 300 行以内** に収める
- **関数・サブルーチン単位** でモジュール化
- **メイン処理フローが明確** に構成

---

## 出力先・ディレクトリ構成

```
workspace/legacy/work/
├── <main-source-file>    # 言語によって異なる (*.vbs, *.bat, *.ps1 等)
├── data/                 # サンプルデータファイル
│   └── *.csv (or *.json, *.txt)
└── docs/
    ├── how-to-run.md     # 実行手順
    └── specification.md  # 入出力仕様・ビジネスロジック
```

---

## ドキュメント生成（必須）

### `how-to-run.md`

- 必要な環境・ランタイム
- 実行コマンド（実行例を含める）
- 期待される出力結果の例

### `specification.md`

- **入力ファイルの形式** — カラム定義、データ型、サンプル
- **出力結果の形式** — カラム定義、データ型、サンプル
- **ビジネスロジック** — 計算式、条件判定、閾値等の詳細

---

## コード品質

- **日本語でコメント記載**
- **命名規則** — 言語の慣習に従う
- **エラーハンドリング** — 最低限のチェック（ファイル存在確認など）

---

## チェックリスト

- [ ] `workspace/legacy/work/` にソースコードが生成されている
- [ ] `workspace/legacy/work/docs/how-to-run.md` に実行手順が記載
- [ ] `workspace/legacy/work/docs/specification.md` に仕様が記載
- [ ] `workspace/legacy/work/data/` にサンプルデータが含まれている
- [ ] ソースコードに日本語コメントが含まれている
- [ ] **エンコーディング確認**（VBScript/JScript/Batch の場合）：Shift-JIS で保存
- [ ] 動作確認（実行可能な言語の場合は実際に実行、困難な場合は代替検証）

---

## エージェント向け：動作確認の判断基準

1. 生成した言語が「実行可能な言語」リストに含まれるか確認
2. 含まれる場合 → `run_in_terminal` で実行を試みる
3. 含まれない場合 → 代替検証（構文・ドキュメント・データ整合性）を実施
