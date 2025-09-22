# TeamBuilder App (Flutter)

แอปตัวอย่างสำหรับสร้าง/จัดการทีม Pokémon แบบง่าย ๆ 

##  ความต้องการระบบ (Prerequisites)

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (แนะนำเวอร์ชันล่าสุด)
* Dart (มาพร้อม Flutter)
* Android Studio (สำหรับ Android SDK, Emulator) / Xcode (สำหรับ iOS)
* VS Code หรือ IDE ที่ถนัด
* Git
* (ตัวเลือก) Chrome สำหรับรันแบบ Web

ตรวจสอบสภาพแวดล้อม:

```bash
flutter doctor
```

## การติดตั้ง (Installation)

หากยังไม่ได้โคลนโปรเจกต์จาก GitHub:

```bash
git clone https://github.com/0xOat/teambuilder_app.git
cd teambuilder_app
```

ติดตั้ง dependencies:

```bash
flutter pub get
```

##  การรันแอป (Run)

```bash
flutter run -d chrome
```

## คำสั่งในการสร้างข้อมูล ( Generate Data)

```bash
dart run lib/commands/command_runner.dart generate categories 5
dart run lib/commands/command_runner.dart generate foods 15
dart run lib/commands/command_runner.dart generate orders 30
dart run lib/commands/command_runner.dart generate all
dart run lib/commands/command_runner.dart clear
```