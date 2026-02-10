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
- **COBOL** （メインフレーム）
- **VB6 / VBScript** （Windows レガシー）
- **Perl** （スクリプト系）
- **FORTRAN** （科学計算）
- その他の古い言語

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
- [ ] 実際に動作確認できている

### Step 2 完了時の確認
- [ ] `workspace/modern/tests/` にテストコードが生成されている
- [ ] `workspace/modern/src/` にモダン言語のコードが生成されている
- [ ] テストが全てパスしている
- [ ] レガシー版と同じデータで同じ結果が得られている
- [ ] `workspace/modern/docs/how-to-run.md` に実行手順が記載されている

---

**このファイルは Copilot Chat を開くたびに自動的に読み込まれます。**
新しい Copilot Chat セッションで自動的に反映されます。
