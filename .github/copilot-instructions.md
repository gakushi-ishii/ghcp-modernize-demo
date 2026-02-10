# GitHub Copilot モダナイズデモ — プロジェクト背景

## プロジェクト概要

このリポジトリは、**レガシー言語で書かれたアプリケーションを、モダン言語へモダナイズするプロセスを体験するデモ環境**です。

ユーザーは自身でレガシー言語・業務題材・モダン言語を指定して、GitHub Copilot の支援を受けながら移行作業をシミュレートできます。

## デモの流れ

```
Step 1: レガシーアプリ生成
  ↓ Copilot Chat に prompts/01-generate-legacy-app.md を活用
  workspace/legacy/ にコード・ドキュメント・サンプルデータが生成される
  ↓
Step 2: モダナイズ（TDD ガードレール）
  ↓ Copilot Chat に prompts/02-modernize-app.md を活用
  workspace/modern/ にテスト駆動で移行コードが生成される
  ↓
動作確認・検証
  ↓ example/ フォルダの完成例（COBOL → Python）と比較
  学習完了
```

## プロジェクト構造

```
.
├── example/                    # 完成サンプル（COBOL → Python の参考実装）
│   ├── legacy/                 # レガシー版（COBOL）
│   └── modern/                 # モダン版（Python）
│
├── prompts/                    # ステップごとのプロンプトテンプレート
│   ├── 01-generate-legacy-app.md   # ユーザーが読むガイド（言語指定可能）
│   └── 02-modernize-app.md         # ユーザーが読むガイド（言語指定可能）
│
├── .github/
│   ├── copilot-instructions.md      # このファイル（プロジェクト全体の背景）
│   └── instructions/                # Copilot 用ガイドライン（言語不問）
│       ├── step1-generate-legacy.md # レガシー生成時のルール
│       └── step2-modernize.md       # モダナイズ時のルール（TDD ガードレール）
│
└── workspace/                  # ★ ユーザーの作業ディレクトリ
    ├── legacy/                 # Step 1 で生成したコード・データ
    └── modern/                 # Step 2 で生成したコード・テスト
```

## 全ステップで適用される共通制約

以下の制約は、**レガシー言語・モダン言語の選択に関わらず** 常に適用されます。

### 前提条件

> **❗ このデモは Windows OS（WSL なし）を前提としています。**
> 
> エージェントによる動作確認は、Windows 標準のコマンドプロンプト（cmd.exe）および PowerShell で実行可能な言語のみ対応します。

### 環境制約
- **データベース不使用** — ファイルベース（CSV, JSON, 固定長テキスト）で永続化
- **外部 API 不使用** — ネットワーク通信なし
- **追加ミドルウェア不使用** — 言語標準のランタイムのみで動作
- **OS 固有機能を避ける** — クロスプラットフォーム対応
- **外部パッケージは最小限** — 標準ライブラリを優先

### アプリケーション設計
- **CLI アプリケーション** として実装
- **サンプルデータ必須** — クローン直後に動作確認できる状態
- **ビジネスロジック必須** — 計算処理・バリデーション・条件分岐を最低 2～3 個含める
- **1 ファイル 300 行以内** に収める
- **関数・サブルーチン単位でモジュール化**
- **メインの処理フロー明確** に構成

### コード品質
- **日本語コメント** を適切に記載
- **型ヒント・型注釈** を使用（言語が対応している場合）
- **命名規則・インデント** は言語の標準に従う

### ⚠️ 文字エンコーディング（重要）

Windows 環境でレガシー言語を扱う際、**文字エンコーディングの不一致** が動作エラーの主要な原因となります。

#### エンコーディング要件

| 言語 | 必要なエンコーディング | 理由 |
|------|------------------------|------|
| VBScript | **Shift-JIS** | cscript.exe が Shift-JIS を期待 |
| JScript | **Shift-JIS** | cscript.exe が Shift-JIS を期待 |
| Batch Script | **Shift-JIS** | cmd.exe が Shift-JIS を期待 |
| PowerShell | UTF-8 / Shift-JIS | 両対応（UTF-8 推奨） |
| Python | **UTF-8** | # -*- coding: utf-8 -*- を推奨 |
| Java / C# / Go | **UTF-8** | モダン言語は UTF-8 が標準 |

#### 問題の原因

VS Code のファイル作成ツール（`create_file` 等）は **デフォルトで UTF-8** を使用します。
しかし、VBScript などのレガシー言語は **Shift-JIS** を期待するため、日本語を含むファイルで「文字が正しくありません」エラーが発生します。

#### 解決方法：Shift-JIS でファイルを保存する

レガシー言語（VBScript, JScript, Batch）で日本語を使用する場合は、以下の PowerShell コマンドでファイルを保存してください：

```powershell
# Shift-JIS エンコーディングで保存
$enc = [System.Text.Encoding]::GetEncoding("shift_jis")
[System.IO.File]::WriteAllText("ファイルパス", $content, $enc)
```

#### 実装時のガードレール

1. **レガシー言語で日本語を使用する場合**
   - `create_file` ツールでファイルを作成した後、PowerShell で Shift-JIS に変換する
   - または、最初から PowerShell の `WriteAllText` で Shift-JIS 保存する

2. **CSV などのデータファイル**
   - レガシー言語から読み込む CSV も Shift-JIS で保存する
   - モダン言語から読み込む CSV は UTF-8 で保存する

3. **動作確認前のチェック**
   - 日本語を含むファイルでエラーが出た場合、まずエンコーディングを疑う
   - PowerShell で `Get-Content -Encoding Default` で読み込みテスト

## Copilot との使い方

### Step 1: レガシーアプリ生成

1. VS Code で Copilot Chat を開く（または `@Copilot` モード）
2. `prompts/01-generate-legacy-app.md` を参考に、Copilot に指示を出す
3. 例:
   ```
   VB6 で給与計算システムを作成してください。
   以下の機能を含めてください：
   - CSV ファイルからの従業員データ読み込み
   - 基本給・手当・控除の計算
   - 給与明細レポート出力
   ソースコードとデータファイルは workspace/legacy/ に配置してください。
   ```
4. 生成後、`workspace/legacy/docs/how-to-run.md` に従って動作確認

### Step 2: モダナイズ

1. `.github/copilot-instructions.md` がアクティブになっていることを確認
   - VS Code で Copilot Chat を開くと、自動的にこのファイルが読み込まれます
   - 「References」に `copilot-instructions.md` が表示されれば OK
2. `prompts/02-modernize-app.md` を参考に、Copilot に指示を出す
3. 例:
   ```
   workspace/legacy/ の VB6 プログラムを Java にモダナイズしてください。
   成果物は workspace/modern/ に配置してください。
   テストフレームワークは JUnit を使用してください。
   ```
4. Copilot が自動的に:
   - テストを先に作成
   - specification.md を参照してテストケースを設計
   - TDD で進める
5. 生成後、`workspace/modern/docs/how-to-run.md` に従ってテスト実行・動作確認

## サポート対象言語の例

以下の言語組み合わせを試すことができます（実装は Copilot 側で対応）：

### レガシー言語

#### ✅ エージェントが動作確認**可能**（Windows 標準環境）
以下の言語は Windows に標準搭載のランタイムで実行可能です：
- **VBScript** — `cscript.exe` で実行（Windows 標準）⚠️ **Shift-JIS 必須**
- **Batch Script (.bat/.cmd)** — `cmd.exe` で実行（Windows 標準）⚠️ **Shift-JIS 必須**
- **JScript** — `cscript.exe` で実行（Windows 標準）⚠️ **Shift-JIS 必須**
- **PowerShell** — `powershell.exe` で実行（Windows 標準）

#### ⚠️ エージェントが動作確認**困難**（追加インストールが必要）
以下の言語は追加のランタイム/コンパイラが必要なため、動作確認はスキップされます：
- **COBOL** （GnuCOBOL が必要）
- **VB6** （VB6 IDE/ランタイムが必要）
- **FORTRAN** （gfortran が必要）
- **Perl** （Strawberry Perl 等のインストールが必要）
- **RPG** （IBM i 環境が必要）
- **PL/I** （専用コンパイラが必要）

> 💡 動作確認できない言語の場合、エージェントは構文チェック・ドキュメント検証・データ整合性確認を代替で実施します。

### モダン言語
- **Python** （スクリプト、データ処理）
- **Java** （エンタープライズ）
- **C#** （.NET）
- **Go** （軽量、並行処理）
- **TypeScript** （Node.js）
- その他の現代的言語

## ステップ別チェックリスト

### Step 1 完了時の確認
- [ ] `workspace/legacy/` にソースコードが生成されている
- [ ] `workspace/legacy/docs/how-to-run.md` に実行手順が記載されている
- [ ] `workspace/legacy/docs/specification.md` に仕様が記載されている
- [ ] `workspace/legacy/data/` にサンプルデータが含まれている
- [ ] **エンコーディング確認**（VBScript/JScript/Batch の場合）：
  - ソースコードが Shift-JIS で保存されている
  - CSV などのデータファイルも Shift-JIS で保存されている
- [ ] 動作確認（以下のいずれか）：
  - ✅ 実行可能な言語：実際にコマンドを実行して確認
  - ⚠️ 実行困難な言語：構文・ドキュメント・データ整合性を検証

### Step 2 完了時の確認
- [ ] `workspace/modern/tests/` にテストコードが生成されている
- [ ] `workspace/modern/src/` にモダン言語のコードが生成されている
- [ ] テストが全てパスしている
- [ ] レガシー版と同じデータで同じ結果が得られている
- [ ] `workspace/modern/docs/how-to-run.md` に実行手順が記載されている

---

**このファイルは Copilot Chat を開くたびに自動的に読み込まれます。**
新しい Copilot Chat セッションで自動的に反映されます。
