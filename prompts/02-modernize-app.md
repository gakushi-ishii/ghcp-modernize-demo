# Step 2: モダナイズ — プロンプト例

以下は Copilot Chat（Agent モード推奨）に投げるプロンプトの例です。
移行先の言語は自由に変更してください。

---

## 基本プロンプト

```
workspace/legacy/ の <レガシー言語> プログラムを <モダン言語> にモダナイズしてください。
成果物は workspace/modern/ に配置してください。
```

## 具体例

### 例 1: COBOL → Python

```
workspace/legacy/ の COBOL プログラムを Python にモダナイズしてください。
成果物は workspace/modern/ に配置してください。
テストフレームワークは pytest を使用してください。
```

### 例 2: VBA → TypeScript

```
workspace/legacy/ の VBA プログラムを TypeScript (Node.js) にモダナイズしてください。
成果物は workspace/modern/ に配置してください。
テストフレームワークは Jest を使用してください。
```

### 例 3: Perl → Go

```
workspace/legacy/ の Perl プログラムを Go にモダナイズしてください。
成果物は workspace/modern/ に配置してください。
テストは標準の testing パッケージを使用してください。
```

---
## 確認ポイント

生成後、以下を確認してください：

- [ ] `workspace/modern/tests/` にテストコードが生成されているか
- [ ] テストが全てパスするか
- [ ] `workspace/modern/docs/how-to-run.md` が生成されているか
- [ ] レガシー版と同じサンプルデータで同じ結果が得られるか
