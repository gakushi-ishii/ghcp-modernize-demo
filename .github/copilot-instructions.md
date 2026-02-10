# GitHub Copilot モダナイズデモ — プロジェクト背景

## プロジェクト概要

このリポジトリは、**レガシー言語で書かれたアプリケーションを、モダン言語へモダナイズするプロセスを体験するデモ環境**です。

ユーザーは自身でレガシー言語・業務題材・モダン言語を指定して、GitHub Copilot の支援を受けながら移行作業をシミュレートできます。

## デモの流れ

### パターン A: Step 1 から始める（レガシーアプリ生成 → モダナイズ）

```
Step 1: レガシーアプリ生成
  ↓ Copilot Chat に prompts/01-generate-legacy-app.md を活用
  workspace/legacy/work/ にコード・ドキュメント・サンプルデータが生成される
  ↓
Step 2: モダナイズ（TDD ガードレール）
  ↓ Copilot Chat に prompts/02-modernize-app.md を活用
  workspace/modern/work/ にテスト駆動で移行コードが生成される
```

### パターン B: Step 2 だけ試す（サンプルを使ってモダナイズ）

```
Step 2: モダナイズ（TDD ガードレール）
  ↓ workspace/legacy/example/ の VBS サンプルを使用
  ↓ Copilot Chat に prompts/02-modernize-app.md を活用
  workspace/modern/work/ にテスト駆動で移行コードが生成される
```

## プロジェクト構造

```
.
├── prompts/                         # ステップごとのプロンプトテンプレート
│   ├── 01-generate-legacy-app.md    # Step 1 用ガイド（言語指定可能）
│   └── 02-modernize-app.md          # Step 2 用ガイド（言語指定可能）
│
├── .github/
│   ├── copilot-instructions.md      # このファイル（プロジェクト全体の背景）
│   └── instructions/                # Copilot 用ガイドライン（言語不問）
│       ├── step1-generate-legacy.md # レガシー生成時のルール
│       └── step2-modernize.md       # モダナイズ時のルール（TDD ガードレール）
│
└── workspace/                       # ★ エージェントの作業ディレクトリ
    ├── legacy/
    │   ├── example/                 # VBS 在庫管理サンプル（Step 2 から始める用）
    │   │   ├── inventory.vbs
    │   │   ├── data/
    │   │   └── docs/
    │   └── work/                    # Step 1 で生成する作業場所
    │
    └── modern/
        └── work/                    # Step 2 で生成する作業場所
```

---

## 全ステップ共通の制約

以下の制約は、**レガシー言語・モダン言語の選択に関わらず** 常に適用されます。

### 前提条件

> **❗ このデモは Windows OS（WSL なし）を前提としています。**
> 
> エージェントによる動作確認は、Windows 標準のコマンドプロンプト（cmd.exe）および PowerShell で実行可能な言語のみ対応します。

### 環境制約

- **データベース不使用** — ファイルベース（CSV, JSON, 固定長テキスト）で永続化
- **外部 API 不使用** — ネットワーク通信なし
- **追加ミドルウェア不使用** — 言語標準のランタイムのみで動作
- **外部パッケージは最小限** — 標準ライブラリを優先

### ⚠️ 文字エンコーディング（重要）

Windows 環境でレガシー言語を扱う際、**文字エンコーディングの不一致** が動作エラーの主要な原因となります。

| 言語 | 必要なエンコーディング | 理由 |
|------|------------------------|------|
| VBScript / JScript / Batch | **Shift-JIS** | cscript.exe / cmd.exe が Shift-JIS を期待 |
| PowerShell | UTF-8 / Shift-JIS | 両対応（UTF-8 推奨） |
| Python / Java / C# / Go | **UTF-8** | モダン言語は UTF-8 が標準 |

#### Shift-JIS でファイルを保存する方法

レガシー言語（VBScript, JScript, Batch）で日本語を使用する場合：

```powershell
$enc = [System.Text.Encoding]::GetEncoding("shift_jis")
[System.IO.File]::WriteAllText("ファイルパス", $content, $enc)
```

---

## Copilot との使い方

### Step 1: レガシーアプリ生成（パターン A のみ）

`prompts/01-generate-legacy-app.md` を参考に、Copilot に指示を出す。

例:
```
VBScript で給与計算システムを作成してください。
ソースコードとデータファイルは workspace/legacy/work/ に配置してください。
```

### Step 2: モダナイズ

`prompts/02-modernize-app.md` を参考に、Copilot に指示を出す。

**出力先は言語ごとにサブディレクトリを分ける（例: `work/python/`, `work/java/`）。**

例（サンプルを使う場合）:
```
workspace/legacy/example/ の VBScript プログラムを Python にモダナイズしてください。
成果物は workspace/modern/work/python/ に配置してください。
```

例（Step 1 で生成したアプリを使う場合）:
```
workspace/legacy/work/ の VBScript プログラムを Java にモダナイズしてください。
成果物は workspace/modern/work/java/ に配置してください。
```

---

**このファイルは Copilot Chat を開くたびに自動的に読み込まれます。**
