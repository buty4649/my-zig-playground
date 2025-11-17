# JSON Viewer

Zigの学習目的で作成されたシンプルで美しいJSONビューアーです。

## 特徴

- 🎨 **カラフルな表示**: JSON要素を色分けして見やすく表示
- 🌈 **階層ごとの色分け**: ネストレベルに応じてキーの色が変わります
- 📱 **適切なインデント**: 読みやすい階層構造での表示
- ⚡ **高速**: Zigで書かれているため高速に動作
- 🔧 **シンプル**: 依存関係が少なく軽量

## 色分け

- 🟢 **緑**: 文字列値
- 🟡 **黄**: 真偽値 (`true`/`false`)
- ⚪ **グレー**: `null`値
- 🔢 **白**: 数値
- 🔵 **青**: 階層0のオブジェクトキー
- 🟦 **シアン**: 階層1のオブジェクトキー
- 🟣 **紫**: 階層2のオブジェクトキー
- 🔴 **赤**: 階層3のオブジェクトキー

## インストール

### 前提条件

- Zig 0.15.2以上

### ビルド

```bash
git clone <repository-url>
cd json-viewer
zig build
```

## 使用方法

### 基本的な使い方

```bash
# JSONファイルを表示
./zig-out/bin/json_viewer test.json

# または開発時
zig run src/main.zig -- test.json
```

### 複数ファイルの表示

```bash
zig run src/main.zig -- file1.json file2.json file3.json
```

## 使用例

### 入力例 (test.json)

```json
{
  "name": "田中太郎",
  "age": 28,
  "active": true,
  "scores": [85, 92, 78],
  "address": {
    "city": "東京",
    "coordinates": {
      "lat": 35.6762,
      "lng": 139.6503
    }
  }
}
```

### 出力例

```
{
  "name": "田中太郎"
  "age": 28,
  "active": true,
  "scores": [
    85,
    92,
    78
  ],
  "address": {
    "city": "東京",
    "coordinates": {
      "lat": 35.6762,
      "lng": 139.6503
    }
  }
}
```

*実際の出力では適切な色分けが適用されます。*

## 開発

### テストの実行

```bash
zig build test
```

### デバッグビルド

```bash
zig build -Doptimize=Debug
```

### リリースビルド

```bash
zig build -Doptimize=ReleaseFast
```

## サポートされるJSON機能

- ✅ オブジェクト (`{}`)
- ✅ 配列 (`[]`)
- ✅ 文字列
- ✅ 数値 (整数・浮動小数点)
- ✅ 真偽値 (`true`/`false`)
- ✅ `null`値
- ✅ ネストした構造
- ✅ Unicodeサポート

## 依存関係

- [zig-string](https://github.com/JakubSzark/zig-string) - 効率的な文字列操作

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 作者

buty4649