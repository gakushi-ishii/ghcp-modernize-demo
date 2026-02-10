# GitHub Copilot モダナイズ化デモ

GitHub Copilot を活用して、レガシーコードをモダンな言語・アーキテクチャに移行するデモ用テンプレートリポジトリです。

## 🎯 概要

このリポジトリは以下の 2 ステップで「Copilot 駆動のモダナイズ体験」を提供します：

| ステップ | やること | Copilot の役割 |
|---|---|---|
| **Step 1** | レガシーアプリを生成 | 言語・題材を指示してアプリを自動生成 |
| **Step 2** | TDD でモダナイズ | カスタムインストラクション（ガードレール）に従い、テスト駆動で移行 |

> 💡 **Step 2（モダナイズ）だけ試したい場合**は Step 1 をスキップして、`workspace/legacy/example/` の VBScript サンプルを使えます。

## 📁 リポジトリ構成

```
.
├── README.md                              # このファイル
├── .github/
│   ├── copilot-instructions.md            # プロジェクト共通のカスタムインストラクション
│   └── instructions/
│       ├── step1-generate-legacy.md       # Step 1 用ガードレール
│       └── step2-modernize.md             # Step 2 用ガードレール
├── prompts/                               # Copilot に投げるプロンプト例
│   ├── 01-generate-legacy-app.md
│   └── 02-modernize-app.md
└── workspace/                             # ★ エージェントの作業ディレクトリ
    ├── legacy/
    │   ├── example/                       # VBScript 在庫管理サンプル（Step 2 から始める用）
    │   └── work/                          # Step 1 の成果物をここに生成
    └── modern/
        └── work/                          # Step 2 の成果物をここに生成
```

---

## 🚀 デモの進め方

### 前提条件

- [Visual Studio Code](https://code.visualstudio.com/) がインストール済み
- [GitHub Copilot](https://github.com/features/copilot) の拡張機能が有効
- GitHub Copilot Chat が利用可能

### 動作確認環境について

> **❗ このデモは Windows OS（WSL なし）を前提としています。**

レガシー言語は実行環境が限られるため、Copilot Agent が自動で動作確認できる言語とできない言語があります。

#### ✅ Agent が動作確認**可能**な言語（Windows 標準環境）

以下の言語は Windows に標準搭載のランタイムで実行可能なため、Agent が自動で動作確認を試みます：

| 言語 | 実行コマンド | ランタイム |
|------|------------|----------|
| **VBScript** | `cscript //NoLogo script.vbs` | Windows 標準 (`cscript.exe`) |
| **Batch Script** | `script.bat` | Windows 標準 (`cmd.exe`) |
| **JScript** | `cscript //NoLogo script.js` | Windows 標準 (`cscript.exe`) |
| **PowerShell** | `powershell -File script.ps1` | Windows 標準 (`powershell.exe`) |

#### ⚠️ Agent が動作確認**困難**な言語（追加インストールが必要）

以下の言語は追加のランタイム/コンパイラが必要なため、動作確認はスキップされます：

| 言語 | 必要な環境 |
|------|----------|
| **COBOL** | GnuCOBOL (`cobc`) |
| **VB6** | VB6 IDE/ランタイム |
| **FORTRAN** | gfortran |
| **Perl** | Strawberry Perl 等 |
| **RPG** | IBM i 環境 |
| **PL/I** | 専用コンパイラ |

> 💡 動作確認できない言語の場合、Agent は構文チェック・ドキュメント検証・データ整合性確認を代替で実施します。

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

3. カスタムインストラクションが有効になっていることを確認します：

    - VS Code 設定で有効化する

       ワークスペース設定として、リポジトリ直下の `.vscode/settings.json` に以下を追加（または既存の値を `true` に変更）：
       ```json
       {
          "github.copilot.chat.codeGeneration.useInstructionFiles": true
       }
       ```

    - GUI から有効化する

       1. VS Code で `Ctrl + ,`（macOS: `Cmd + ,`）を押して設定を開く
       2. 検索バーに `useInstructionFiles` と入力
       3. **Copilot > Chat > Code Generation: Use Instruction Files** のチェックボックスをオンにする

### Step 1: レガシーアプリの生成

> 💡 **Step 2 だけ試したい場合はスキップ可能** — `workspace/legacy/example/` の VBScript サンプルを使えます。

1. **Copilot にレガシーアプリの生成を依頼する**

   Copilot Chat（Agent モード推奨）を開き、プロンプト例を参考にレガシーアプリの生成を依頼します。

   > 📝 プロンプト例は [prompts/01-generate-legacy-app.md](prompts/01-generate-legacy-app.md) を参照

   例：
   ```
   VBScript で在庫管理システムを workspace/legacy/work/ に作成してください。
   ```

2. **動作確認**

   Copilot が `workspace/legacy/work/docs/how-to-run.md` に動作確認手順を生成するので、それに従って動作を確認します。

### Step 2: TDD でモダナイズ

1. **Copilot にモダナイズを依頼する**

   Copilot Chat（Agent モード推奨）を開き、プロンプト例を参考にモダナイズを依頼します。

   > 📝 プロンプト例は [prompts/02-modernize-app.md](prompts/02-modernize-app.md) を参照

   例（サンプルを使う場合）：
   ```
   workspace/legacy/example/ の VBScript プログラムを Python にモダナイズしてください。
   成果物は workspace/modern/work/ に配置してください。
   ```

   例（Step 1 で生成したアプリを使う場合）：
   ```
   workspace/legacy/work/ の VBScript プログラムを Python にモダナイズしてください。
   成果物は workspace/modern/work/ に配置してください。
   ```

2. **テストの実行・動作確認**

   カスタムインストラクションにより、Copilot は **テストを先に作成** します。
   `workspace/modern/work/docs/how-to-run.md` に従ってテストと動作確認を行います。

---

## ⚙️ カスタムインストラクションについて

### 仕組み

このリポジトリでは、GitHub Copilot のカスタムインストラクションを **2 層構造** で管理しています：

| ファイル | 役割 | 適用範囲 |
| --- | --- | --- |
| `.github/copilot-instructions.md` | プロジェクト共通の背景・制約 | 全リクエストに自動適用 |
| `.github/instructions/step1-generate-legacy.md` | レガシーアプリ生成のガードレール | `workspace/legacy/**` に自動適用 |
| `.github/instructions/step2-modernize.md` | TDD モダナイズのガードレール | `workspace/modern/**` に自動適用 |

### 一時的に Instruction Files を無効化したい場合

一時的に Instruction Files を使いたくない場合は、VS Code の設定で無効化できます。

- VS Code の設定を開く（`Ctrl+,` または `⌘+,`）
- 「GitHub Copilot: Instruction Files」設定を検索
- `useInstructionFiles` を `false` に設定して OFF にする
---

## 📦 サンプル（workspace/legacy/example/）

`workspace/legacy/example/` ディレクトリには、**VBScript 在庫管理システム** をサンプルとして配置しています。

- [workspace/legacy/example/](workspace/legacy/example/) - VBScript 版在庫管理システム
  - `inventory.vbs` - メインプログラム
  - `data/` - サンプルデータ（CSV）
  - `docs/` - 仕様書・実行手順書

Step 2（モダナイズ）だけ試したい場合は、このサンプルを使用してください。

---

## 💡 Tips

- **レガシー言語の選択肢**: COBOL, VB6, VBA, Perl, Classic ASP など、自由に選べます
- **モダナイズ先の選択肢**: Python, TypeScript, C#, Java, Go など、自由に選べます
- **アプリ題材の選択肢**: 在庫管理、給与計算、顧客管理、注文処理など、自由に選べます
- Copilot のモデルやバージョンによって生成結果が変わる場合があります
- `example/` の完成品と比較することで、Copilot の生成品質を評価できます

## 📄 ライセンス

MIT License
