# Step 2: モダナイズ — プロンプト例

以下は Copilot Chat（Agent モード推奨）に投げるプロンプトの例です。
移行先の言語は自由に変更してください。

---

## 基本プロンプト

### サンプル（VBScript 在庫管理）を使う場合

```
workspace/legacy/example/ の VBScript プログラムを <モダン言語> にモダナイズしてください。
成果物は workspace/modern/work/ に配置してください。
```

### Step 1 で生成したアプリを使う場合

```
workspace/legacy/work/ の <レガシー言語> プログラムを <モダン言語> にモダナイズしてください。
成果物は workspace/modern/work/ に配置してください。
```

---

## 具体例

### 例 1: VBScript サンプル → Python（推奨）

```
workspace/legacy/example/ の VBScript プログラムを Python にモダナイズしてください。
成果物は workspace/modern/work/ に配置してください。
テストフレームワークは pytest を使用してください。
```

### 例 2: VBScript サンプル → TypeScript

```
workspace/legacy/example/ の VBScript プログラムを TypeScript (Node.js) にモダナイズしてください。
成果物は workspace/modern/work/ に配置してください。
テストフレームワークは Jest を使用してください。
```

### 例 3: VBScript サンプル → Go

```
workspace/legacy/example/ の VBScript プログラムを Go にモダナイズしてください。
成果物は workspace/modern/work/ に配置してください。
テストは標準の testing パッケージを使用してください。
```

### 例 4: Step 1 で生成した VBScript → Java

```
workspace/legacy/work/ の VBScript プログラムを Java にモダナイズしてください。
成果物は workspace/modern/work/ に配置してください。
テストフレームワークは JUnit を使用してください。
```

---

## 確認ポイント

生成後、以下を確認してください：

- [ ] `workspace/modern/work/tests/` にテストコードが生成されているか
- [ ] テストが全てパスするか
- [ ] `workspace/modern/work/docs/how-to-run.md` が生成されているか
- [ ] レガシー版と同じサンプルデータで同じ結果が得られるか
