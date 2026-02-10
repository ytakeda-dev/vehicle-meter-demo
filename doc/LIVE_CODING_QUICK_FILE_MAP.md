# ファイルごとの役割MAP

### RPM挙動を変えたい
- 触る：dashboard_notifier.dart
- 見る関数：
  - _updateRunning(dt)
  - _updateWarmUp(dt)
  - _updateCooling(dt)
- 典型指示：
  - 回転上限変更
  - idle回転数変更
  - 加速/減速を緩やかに

---

### メーター見た目を変えたい
- Analog：
  - analog_rpm_meter.dart
- Bar：
  - bar_rpm_meter.dart
- 共通定数：
  - constants.dart
- 典型指示：
  - redline位置変更
  - 角度/高さ調整
  - 色変更

---

### メーターモード切替ロジック
- 触る：
  - dashboard_state.dart
  - dashboard_notifier.dart
- UI：
  - dashboard_screen.dart
- 典型指示：
  - モード追加
  - 初期モード変更

---

### 入力挙動（ボタン・キー）
- Event定義：
  - engine_input.dart
- UI入力：
  - dashboard_screen.dart
- キーボード：
  - keyboard_engine_input_emitter.dart
- 集約：
  - engine_input_event_bus.dart
- 典型指示：
  - 新しい入力追加
  - ボタン挙動変更

---

### ブランド挙動
- state：
  - brand.dart
- notifier：
  - dashboard_notifier.dart
- UI：
  - dashboard_screen.dart
- 典型指示：
  - ブランドで色/挙動変える

---

### レイアウト変更
- UI：
  - dashboard_screen.dart
- 典型指示：
  - 余白
  - 配置順変更

---

### テスト
- unit：
  - dashboard_notifier_test.dart
- widget：
  - dashboard_screen_test.dart
- integration：
  - app_test.dart
