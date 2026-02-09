# Vehicle Meter – Flutter Embedded Dashboard Demo

![CI](https://github.com/ytakeda-dev/vehicle-meter-demo/actions/workflows/main.yml/badge.svg)

Flutter で **車載 Linux（Flutter embedded）向け UI** を想定した、1画面完結のダッシュボード・デモアプリです。  
最終的なターゲットは **Linux + Wayland**（専用ハードウェア）ですが、日々の開発・デモ・ライブコーディングは **macOS / Linux Desktop** 上で行える構成にしています。

本デモの狙いは、**組み込みUI開発でよくある入力（GPIO相当）と状態遷移**を、Flutter + Riverpod で「変更しやすい形」にまとめたことを示す点です。

---

## Features

### UI
- **Meter mode toggle**: `ANALOG` / `BAR`
- **Analog RPM meter**: 針が RPM に追従して回転（視覚表現はステートレス）
- **Bar RPM meter**: 縦ゲージが RPM に追従して伸縮（視覚表現はステートレス）
- **Brand carousel**: 中央選択 + 端をぼかしたカルーセル（Text表示）
- **Controls**
  - `IGNITION`: エンジン ON/OFF（状態に応じて色が変化）
  - `THROTTLE (HOLD)`: 押下中に回転数が上がり、離すとアイドルへ戻る

### Engine behavior (demo simulation)
- **RPM scale max**: `10,000 rpm`（メーターの表示スケール）
- **Rev limiter / redline**: `8,000 rpm`
  - 実車っぽく、スロットル最大でも `8,000 rpm` で頭打ち（rev limit）
  - UI上の警告領域（red zone）は `8,000 rpm` から（表示は `kRedlineStartRpm`）

> 主要パラメータは `lib/features/dashboard/ui/constants.dart` に集約しています。

---

## Controls

### UI buttons
- `IGNITION` ボタン: `KeyboardEngineIgnitionRequested` を発火
- `THROTTLE (HOLD)` ボタン: 押下中 `KeyboardThrottlePressed` / 離したら `KeyboardThrottleReleased`

### Keyboard (desktop)
- `Enter`: Ignition（ON/OFF）
- `Space`: Throttle（押下中ON、離すとOFF）

---

## State management

- **Riverpod 3.x** を採用
- 画面状態は `DashboardState` に集約（single source of truth）

`DashboardState`:
- `engineState`: `off / starting / running`
- `meterMode`: `analog / bar`（UI表示モード）
- `displayRpm`: `double`
- `brand`: `Brand` enum

状態更新は `DashboardNotifier` が担い、UIは `ref.watch(...)` で状態を購読して表示するだけに寄せています。

---

## Input architecture (GPIO-ready)

本デモでは GPIO を実装せず、**EventBus + Emitter** で入力を集約します。

- `EngineInputEventBus`（StreamのHub）
  - `emit(EngineInput)` でイベント投入
  - `inputs`（Stream）で購読
- Emitters
  - `KeyboardEngineInputEmitter`（HardwareKeyboard → EngineInput）
  - `GPIOEngineInputEmitter`（将来用のスタブ）

`DashboardNotifier` は `EngineInputDataSource` を参照し、`inputs` を listen して `EngineInput` を状態に変換します。

---

## Directory structure

```
lib/
├── main.dart
├── domain/
│   ├── engine_input.dart        # EngineInput events (ignition/throttle)
│   └── engine_state.dart        # EngineState (off/starting/running)
└── features/
    └── dashboard/
        ├── data/
        │   ├── engine_input_datasource.dart
        │   └── engine_input_event_bus.dart
        ├── input/
        │   ├── keyboard_engine_input_emitter.dart
        │   └── gpio_engine_input_emitter.dart
        ├── provider/
        │   ├── dashboard_notifier_provider.dart
        │   ├── engine_input_event_bus_provider.dart
        │   ├── engine_input_datasource_provider.dart
        │   └── keyboard_engine_input_emitter_provider.dart
        ├── state/
        │   ├── dashboard_state.dart
        │   ├── brand.dart
        │   ├── meter_mode.dart
        │   └── rpm.dart
        └── ui/
            ├── dashboard_screen.dart
            ├── analog_rpm_meter.dart
            ├── bar_rpm_meter.dart
            └── constants.dart
```

---

## Run

```bash
flutter pub get

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

---

## Notes (for interview / live coding)

- **UI widgets are stateless**: RPM → angle/height の変換に集中し、複雑さは `DashboardNotifier` に閉じています。
- **Constants-first**: rev limit / warm up / idle / sweep 等、変更指示が来やすいパラメータは `constants.dart` に集約しています。
- **GPIO-ready input**: EventBus に集約し、Emitter差し替えで将来拡張可能です。

---

## Diagrams
- Engine state flow: `EngineStateFlow.mmd

## License
This project is licensed under the MIT License.`

