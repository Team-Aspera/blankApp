# HarmonyOS build notes

Flutter-OHOS SDK is installed at:

```powershell
C:\Code\flutter-ohos
```

Use it explicitly so the normal Flutter SDK at `C:\Code\flutter` is not replaced globally:

```powershell
C:\Code\flutter-ohos\bin\flutter.bat --version
C:\Code\flutter-ohos\bin\flutter.bat create --platforms ohos .
C:\Code\flutter-ohos\bin\flutter.bat build hap --release
```

Current SDK branch:

```text
https://gitcode.com/openharmony-sig/flutter_flutter.git
oh-3.41.9-dev
```

This SDK supports:

- `flutter create --platforms ohos`
- `flutter build hap`
- `flutter build app`
- Dart 3.11.5, matching this project

The generated HarmonyOS platform folder is `ohos/`.

Remaining machine-level requirement:

- install Huawei HarmonyOS Command Line Tools / HarmonyOS SDK
- configure `HOS_SDK_HOME` or run `C:\Code\flutter-ohos\bin\flutter.bat config --ohos-sdk <sdk-path>`
- add `ohpm` and `hvigorw` from the Command Line Tools to `PATH`

Without those official tools, Flutter-OHOS can generate the project and resolve Dart packages, but cannot analyze or build the HAP.
