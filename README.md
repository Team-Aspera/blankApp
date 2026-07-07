# BlankApp

全屏纯色 / 截图展示应用，支持 Android、iOS 和 HarmonyOS。

[English](./README_en.md)

## 功能

- 全屏沉浸式显示，隐藏系统 UI
- 点击屏幕切换页面：纯白 → 3DMark 截图 (x3) → GeekBench 截图
- 接近传感器联动：遮挡传感器时屏幕变黑（防误触 / 省电）
- 通过平台通道 `blank_app/device` 接收原生端调用：
  - `proximityChanged` — 告知接近传感器状态
  - `nextPage` — 切换至下一页
  - `enableProximityScreenOff` / `disableProximityScreenOff` — 启停传感器屏幕关闭

## 平台支持

| 平台      | 状态          |
|-----------|---------------|
| Android   | 支持          |
| iOS       | 支持          |
| HarmonyOS | 支持          |
| Windows   | UI 可用（无原生传感器） |
| macOS     | UI 可用（无原生传感器） |
| Linux     | UI 可用（无原生传感器） |

## 快速开始

### 环境要求

- Flutter SDK ≥ 3.11.5 (Dart ≥ 3.11.5)

### 运行

```bash
# 安装依赖
flutter pub get

# 运行（连接设备或模拟器）
flutter run
```

### 构建

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# HarmonyOS（需 Flutter-OHOS SDK）
# 详见 docs/harmonyos.md
C:\Code\flutter-ohos\bin\flutter.bat build hap --release
```

### HarmonyOS 构建

HarmonyOS 构建需要使用 [Flutter-OHOS SDK](https://gitcode.com/openharmony-sig/flutter_flutter.git) (`oh-3.41.9-dev` 分支)。

详细构建说明见 [docs/harmonyos.md](docs/harmonyos.md)。

## 项目结构

```
blank_app/
├── lib/
│   └── main.dart          # 应用主入口
├── assets/
│   ├── branding/          # 品牌素材
│   └── screens/           # 截图素材
├── android/               # Android 平台
├── ios/                   # iOS 平台
├── ohos/                  # HarmonyOS 平台
├── docs/
│   └── harmonyos.md       # HarmonyOS 构建说明
└── pubspec.yaml           # 项目配置
```

## 许可

LGPL v2.1
