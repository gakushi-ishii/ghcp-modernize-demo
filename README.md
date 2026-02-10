# GitHub Copilot モダナイズ化デモ

GitHub Copilot を活用して、レガシーコードをモダンな言語・アーキテクチャに移行するデモ用テンプレートリポジトリです。

## 🎯 概要

このリポジトリは以下の 2 ステップで「Copilot 駆動のモダナイズ体験」を提供します：

| ステップ | やること | Copilot の役割 |
|---|---|---|
| **Step 1** | レガシーアプリを生成 | 言語・題材を指示してアプリを自動生成 |
| **Step 2** | TDD でモダナイズ | カスタムインストラクション（ガードレール）に従い、テスト駆動で移行 |

## 📁 リポジトリ構成

```
.
├── README.md                              # このファイル
├── .github/
│   ├── copilot-instructions.md            # 現在有効なカスタムインストラクション
│   └── instructions/
│       ├── step1-generate-legacy.md       # Step 1 用インストラクション
│       └── step2-modernize.md             # Step 2 用インストラクション
├── prompts/                               # Copilot に投げるプロンプト例
│   ├── 01-generate-legacy-app.md
│   └── 02-modernize-app.md
├── example/                               # 完成サンプル（COBOL → Python）
│   ├── legacy/                            # レガシー版（COBOL 在庫管理）
│   └── modern/                            # モダン版（Python 在庫管理 + テスト）
└── workspace/                             # ★ あなたの作業ディレクトリ
    ├── legacy/                            # Step 1 の成果物をここに生成
    └── modern/                            # Step 2 の成果物をここに生成
```

---

## 🚀 デモの進め方

### 前提条件

- [Visual Studio Code](https://code.visualstudio.com/) がインストール済み
- [GitHub Copilot](https://github.com/features/copilot) の拡張機能が有効
- GitHub Copilot Chat が利用可能

### Step 0: 準備

1. このリポジトリをクローン（またはフォーク）します：

   ```bash
   git clone https://github.com/<your-org>/ghcp-modernize-demo.git
   cd ghcp-modernize-demo
   ```

2. VS Code でワークスペースを開きます：

   ```bash
   code .
   ```

### Step 1: レガシーアプリの生成

1. **カスタムインストラクションを設定する**

   `.github/instructions/step1-generate-legacy.md` の内容を `.github/copilot-instructions.md` にコピーします：

   ```bash
   cp .github/instructions/step1-generate-legacy.md .github/copilot-instructions.md
   ```

2. **Copilot にレガシーアプリの生成を依頼する**

   Copilot Chat（Agent モード推奨）を開き、プロンプト例を参考にレガシーアプリの生成を依頼します。

   > 📝 プロンプト例は [prompts/01-generate-legacy-app.md](prompts/01-generate-legacy-app.md) を参照

   例：
   ```
   COBOL で在庫管理システムを workspace/legacy/ に作成してください。
   ```

3. **動作確認**

   Copilot が `workspace/legacy/docs/how-to-run.md` に動作確認手順を生成するので、それに従って動作を確認します。

### Step 2: TDD でモダナイズ

1. **カスタムインストラクションを切り替える**

   `.github/instructions/step2-modernize.md` の内容を `.github/copilot-instructions.md` にコピーします：

   ```bash
   cp .github/instructions/step2-modernize.md .github/copilot-instructions.md
   ```

2. **Copilot にモダナイズを依頼する**

   Copilot Chat（Agent モード推奨）を開き、プロンプト例を参考にモダナイズを依頼します。

   > 📝 プロンプト例は [prompts/02-modernize-app.md](prompts/02-modernize-app.md) を参照

   例：
   ```
   workspace/legacy/ の COBOL プログラムを Python にモダナイズしてください。
   成果物は workspace/modern/ に配置してください。
   ```

3. **テストの実行・動作確認**

   カスタムインストラクションにより、Copilot は **テストを先に作成** します。
   `workspace/modern/docs/how-to-run.md` に従ってテストと動作確認を行います。

---

## ⚙️ カスタムインストラクションについて

### 仕組み

`.github/copilot-instructions.md` は、GitHub Copilot が自動的に参照するリポジトリレベルのカスタムインストラクションです。このファイルの内容に基づき、Copilot の生成コードの品質や方針を制御できます。

### 無効化する方法

カスタムインストラクションを一時的に無効にしたい場合：

- **方法 1**: `.github/copilot-instructions.md` を空にする

  ```bash
  echo "" > .github/copilot-instructions.md
  ```

- **方法 2**: VS Code 設定で無効化する

  `settings.json` に以下を追加：
  ```json
  {
    "github.copilot.chat.codeGeneration.useInstructionFiles": false
  }
  ```

### 各ステップのインストラクション内容

| ファイル | 目的 |
|---|---|
| `step1-generate-legacy.md` | レガシーアプリ生成時の制約（外部依存排除・デモ品質確保） |
| `step2-modernize.md` | TDD ガードレール（テスト先行・仕様保持・段階的移行） |

---

## 📦 サンプル（example/）

`example/` ディレクトリには、**COBOL → Python** の在庫管理システムを一例として完成品を配置しています。

- [example/legacy/](example/legacy/) - COBOL 版在庫管理システム
- [example/modern/](example/modern/) - Python 版在庫管理システム（pytest テスト付き）

デモの参考や、期待される成果物のイメージとしてご利用ください。

---

## 💡 Tips

- **レガシー言語の選択肢**: COBOL, VB6, VBA, Perl, Classic ASP など、自由に選べます
- **モダナイズ先の選択肢**: Python, TypeScript, C#, Java, Go など、自由に選べます
- **アプリ題材の選択肢**: 在庫管理、給与計算、顧客管理、注文処理など、自由に選べます
- Copilot のモデルやバージョンによって生成結果が変わる場合があります
- `example/` の完成品と比較することで、Copilot の生成品質を評価できます

## 📄 ライセンス

MIT License
