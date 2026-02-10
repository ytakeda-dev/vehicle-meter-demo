## 画面共有ナビ （要約）

### デモ
- IGNITION / THROTTLE
- モード切替
- ブランド切替

### UI
- dashboard_screen.dart
- analog_rpm_meter.dart
- bar_rpm_meter.dart

### 状態
- dashboard_state.dart
- dashboard_notifier.dart

### 入力
- engine_input.dart
- engine_input_event_bus.dart
- keyboard_engine_input_emitter.dart

### よく来る修正
- RPM上限変更 → constants.dart
- 挙動変更 → dashboard_notifier.dart
- 見た目 → meter widgets

### テスト
- debugTick
- unit中心、E2E最小
