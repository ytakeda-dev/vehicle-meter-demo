## 画面共有ナビ

### 目的
- 画面共有しながらデモ・設計・実装を説明
- 道しるべ

---

## 0. 導入（1〜2分）
- デモアプリ上で、設計と実装を説明
- 修正指示があれば対応

---

## 1. デモ操作（5分）
- IGNITION → warm up → running
- THROTTLE → RPM上昇 / リリース
- メーターモード切替（Analog / Bar）
- ブランド切替
- キーボード操作（Enter / Space）

---

## 2. 画面構成（DashboardScreen）
- 上：メーターモード切替
- 中：メーター表示
- 下：ブランドカルーセル / 操作ボタン
- UIは state を読むだけ

---

## 3. メーターUI
- Analog / Bar を別Widgetに分離
- 表示専用・状態は持たない
- 定数は constants.dart に集約

---

## 4. 状態管理
- DashboardState に集約
  - engineState
  - meterMode
  - displayRpm
  - brand

---

## 5. 入力設計
- EngineInput に正規化
- EventBus に集約
- UI / Keyboard / GPIO を同一経路に

---

## 6. DashboardNotifier
- EngineInputを購読
- Timer + dt で連続更新
- warmUp / running / cooling を分離

---

## 7. テスト
- debugTick による unit test
- widget / integration は最小限

---

## 8. 締め
- 拡張・修正に強い構成
- 状態管理と入力設計を重視
