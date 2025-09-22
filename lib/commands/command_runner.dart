import 'dart:io';
import 'data_generator.dart';
import '../services/pocketbase_service.dart';

void main(List<String> arguments) async {
  // Initialize PocketBase
  PocketBaseService().initialize();
  
  // Login as admin or user
  await _authenticate();
  
  await CommandRunner.run(arguments);
}

Future<void> _authenticate() async {
  final pbService = PocketBaseService();
  
  print('กำลังเข้าสู่ระบบ...');
  
  // Try to authenticate with admin first
  try {
    print('กรุณาใส่ข้อมูลการเข้าสู่ระบบ:');
    stdout.write('Email: ');
    final email = stdin.readLineSync() ?? '';
    
    stdout.write('Password: ');
    stdin.echoMode = false; // Hide password input
    final password = stdin.readLineSync() ?? '';
    stdin.echoMode = true;
    print(''); // New line after password
    
    final success = await pbService.login(email, password);
    
    if (success) {
      print('เข้าสู่ระบบสำเร็จ!');
    } else {
      print('เข้าสู่ระบบไม่สำเร็จ กรุณาตรวจสอบ email และ password');
      exit(1);
    }
  } catch (error) {
    print('เกิดข้อผิดพลาดในการเข้าสู่ระบบ: $error');
    exit(1);
  }
}

class CommandRunner {
  static Future<void> run(List<String> arguments) async {
    if (arguments.isEmpty) {
      _printHelp();
      return;
    }

    final command = arguments[0].toLowerCase();
    final generator = DataGenerator();

    switch (command) {
      case 'generate':
        await _handleGenerateCommand(arguments, generator);
        break;
      case 'clear':
        await _handleClearCommand(generator);
        break;
      case 'help':
      case '--help':
      case '-h':
        _printHelp();
        break;
      default:
        print('คำสั่งไม่ถูกต้อง: $command');
        _printHelp();
    }
  }

  static Future<void> _handleGenerateCommand(List<String> arguments, DataGenerator generator) async {
    if (arguments.length < 2) {
      print('กรุณาระบุประเภทข้อมูลที่ต้องการสร้าง');
      _printGenerateHelp();
      return;
    }

    final type = arguments[1].toLowerCase();

    switch (type) {
      case 'categories':
        final count = arguments.length > 2 ? int.tryParse(arguments[2]) ?? 5 : 5;
        await generator.generateCategories(count: count);
        break;
      case 'foods':
        final count = arguments.length > 2 ? int.tryParse(arguments[2]) ?? 10 : 10;
        await generator.generateFoods(count: count);
        break;
      case 'orders':
        final count = arguments.length > 2 ? int.tryParse(arguments[2]) ?? 20 : 20;
        await generator.generateOrders(count: count);
        break;
      case 'all':
        await generator.generateAllData();
        break;
      default:
        print('ประเภทข้อมูลไม่ถูกต้อง: $type');
        _printGenerateHelp();
    }
  }

  static Future<void> _handleClearCommand(DataGenerator generator) async {
    print('คุณแน่ใจหรือไม่ที่จะลบข้อมูลทั้งหมด? (y/N)');
    final input = stdin.readLineSync()?.toLowerCase();
    
    if (input == 'y' || input == 'yes') {
      await generator.clearAllData();
    } else {
      print('ยกเลิกการลบข้อมูล');
    }
  }

  static void _printHelp() {
    print('''
Restaurant App Data Generator

การใช้งาน:
  dart run lib/commands/command_runner.dart <คำสั่ง> [ตัวเลือก]

คำสั่งที่ใช้ได้:
  generate <ประเภท> [จำนวน]  สร้างข้อมูลตัวอย่าง
  clear                     ลบข้อมูลทั้งหมด
  help                      แสดงคำแนะนำ

ตัวอย่าง:
  dart run lib/commands/command_runner.dart generate categories 5
  dart run lib/commands/command_runner.dart generate foods 15
  dart run lib/commands/command_runner.dart generate orders 30
  dart run lib/commands/command_runner.dart generate all
  dart run lib/commands/command_runner.dart clear
''');
  }

  static void _printGenerateHelp() {
    print('''
ประเภทข้อมูลที่สามารถสร้างได้:
  categories  หมวดหมู่อาหาร (ค่าเริ่มต้น: 5)
  foods       รายการอาหาร (ค่าเริ่มต้น: 10)
  orders      คำสั่งซื้อ (ค่าเริ่มต้น: 20)
  all         สร้างข้อมูลทั้งหมด

ตัวอย่าง:
  dart run lib/commands/command_runner.dart generate categories 8
  dart run lib/commands/command_runner.dart generate all
''');
  }
}