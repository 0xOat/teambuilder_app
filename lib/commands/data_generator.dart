import 'dart:math';
import '../services/pocketbase_service.dart';
import '../models/category.dart';
import '../models/food.dart';
import '../models/order.dart';
import '../models/order_item.dart';

class DataGenerator {
  static final DataGenerator _instance = DataGenerator._internal();
  factory DataGenerator() => _instance;
  DataGenerator._internal();

  final _pbService = PocketBaseService();
  final _random = Random();

  // Sample data
  final List<String> _categoryNames = [
    'อาหารจานหลัก',
    'ของทานเล่น',
    'เครื่องดื่ม',
    'ของหวาน',
    'สลัด',
    'ซุป',
    'อาหารทะเล',
    'อาหารเจ',
    'บาร์บีคิว',
    'ผลไม้'
  ];

  final List<Map<String, dynamic>> _foodData = [
    {'name': 'ผัดไทย', 'price': 60, 'category': 'อาหารจานหลัก', 'spicy': 'medium'},
    {'name': 'ต้มยำกุ้ง', 'price': 120, 'category': 'ซุป', 'spicy': 'hot'},
    {'name': 'ส้มตำไทย', 'price': 40, 'category': 'สลัด', 'spicy': 'hot'},
    {'name': 'แกงเขียวหวานไก่', 'price': 80, 'category': 'อาหารจานหลัก', 'spicy': 'medium'},
    {'name': 'ข้าวผัดกุ้ง', 'price': 70, 'category': 'อาหารจานหลัก', 'spicy': 'mild'},
    {'name': 'ลาบหมู', 'price': 60, 'category': 'ของทานเล่น', 'spicy': 'hot'},
    {'name': 'น้ำแข็งใส', 'price': 25, 'category': 'เครื่องดื่ม', 'spicy': null},
    {'name': 'โค้กโซดา', 'price': 20, 'category': 'เครื่องดื่ม', 'spicy': null},
    {'name': 'กาแฟเย็น', 'price': 35, 'category': 'เครื่องดื่ม', 'spicy': null},
    {'name': 'ข้าวเหนียวมะม่วง', 'price': 50, 'category': 'ของหวาน', 'spicy': null},
    {'name': 'ทอดมันปลา', 'price': 45, 'category': 'ของทานเล่น', 'spicy': 'mild'},
    {'name': 'กุ้งอบวุ้นเส้น', 'price': 150, 'category': 'อาหารทะเล', 'spicy': 'mild'},
    {'name': 'ผัดผักรวม', 'price': 50, 'category': 'อาหารเจ', 'spicy': null},
    {'name': 'หมูย่าง', 'price': 90, 'category': 'บาร์บีคิว', 'spicy': 'mild'},
    {'name': 'สลัดผลไม้', 'price': 35, 'category': 'ผลไม้', 'spicy': null}
  ];

  final List<String> _customerNames = [
    'สมชาย ใจดี',
    'สุดา รักษ์งาม',
    'วิชัย มั่นคง',
    'นันทา สุขสม',
    'ประเสริฐ ดีเด่น',
    'มานี น่ารัก',
    'สมศักดิ์ กล้าหาญ',
    'จันทร์ อร่าม',
    'บุษบา สวยงาม',
    'กิตติ เก่งกาจ'
  ];

  // Generate Categories
  Future<List<Category>> generateCategories({int count = 5}) async {
    print('กำลังสร้างหมวดหมู่ $count รายการ...');
    
    final List<Category> generatedCategories = [];
    final selectedNames = _categoryNames.take(count).toList();
    
    for (String name in selectedNames) {
      final category = Category(
        id: '',
        name: name,
        description: 'หมวดหมู่ $name สำหรับร้านอาหาร',
        isActive: true,
        created: DateTime.now(),
        updated: DateTime.now(),
      );
      
      final created = await _pbService.create<Category>(
        'categories',
        category.toJson(),
        Category.fromJson,
      );
      
      if (created != null) {
        generatedCategories.add(created);
        print('สร้าง: ${created.name}');
      }
    }
    
    print('สร้างหมวดหมู่เสร็จสิ้น: ${generatedCategories.length} รายการ');
    return generatedCategories;
  }

  // Generate Foods
  Future<List<Food>> generateFoods({int count = 10}) async {
    print('กำลังสร้างรายการอาหาร $count รายการ...');
    
    // Get existing categories
    final categories = await _pbService.getList<Category>(
      'categories',
      Category.fromJson,
    );
    
    if (categories.isEmpty) {
      print('ไม่พบหมวดหมู่ กรุณาสร้างหมวดหมู่ก่อน');
      return [];
    }
    
    final List<Food> generatedFoods = [];
    final selectedFoods = _foodData.take(count).toList();
    
    for (var foodData in selectedFoods) {
      // Find category by name
      final category = categories.firstWhere(
        (cat) => cat.name == foodData['category'],
        orElse: () => categories[_random.nextInt(categories.length)],
      );
      
      final food = Food(
        id: '',
        name: foodData['name'],
        description: 'อาหารอร่อยสไตล์ไทยแท้ ${foodData['name']}',
        price: (foodData['price'] as int).toDouble(),
        categoryId: category.id,
        ingredients: _generateIngredients(foodData['name']),
        spicyLevel: foodData['spicy'],
        isAvailable: _random.nextBool() ? true : _random.nextDouble() > 0.2, // 80% available
        created: DateTime.now(),
        updated: DateTime.now(),
      );
      
      final created = await _pbService.create<Food>(
        'foods',
        food.toJson(),
        Food.fromJson,
      );
      
      if (created != null) {
        generatedFoods.add(created);
        print('สร้าง: ${created.name} (${created.price}฿)');
      }
    }
    
    print('สร้างรายการอาหารเสร็จสิ้น: ${generatedFoods.length} รายการ');
    return generatedFoods;
  }

  // Generate Orders
  Future<List<Order>> generateOrders({int count = 20}) async {
    print('กำลังสร้างคำสั่งซื้อ $count รายการ...');
    
    // Get existing foods
    final foods = await _pbService.getList<Food>(
      'foods',
      Food.fromJson,
    );
    
    if (foods.isEmpty) {
      print('ไม่พบรายการอาหาร กรุณาสร้างรายการอาหารก่อน');
      return [];
    }
    
    final List<Order> generatedOrders = [];
    
    for (int i = 0; i < count; i++) {
      final orderNumber = 'ORD-${(100000 + _random.nextInt(900000)).toString()}';
      final customerName = _customerNames[_random.nextInt(_customerNames.length)];
      final orderType = OrderType.values[_random.nextInt(OrderType.values.length)];
      final status = _getRandomStatus();
      final orderDate = _getRandomDate();
      
      // Generate order items
      final itemCount = _random.nextInt(4) + 1; // 1-4 items
      final selectedFoods = <Food>[];
      final quantities = <int>[];
      double totalAmount = 0;
      
      for (int j = 0; j < itemCount; j++) {
        final food = foods[_random.nextInt(foods.length)];
        final quantity = _random.nextInt(3) + 1; // 1-3 quantity
        
        selectedFoods.add(food);
        quantities.add(quantity);
        totalAmount += food.price * quantity;
      }
      
      final order = Order(
        id: '',
        orderNumber: orderNumber,
        customerName: customerName,
        customerPhone: _generatePhoneNumber(),
        tableNumber: orderType == OrderType.dineIn ? _random.nextInt(20) + 1 : null,
        status: status,
        orderType: orderType,
        totalAmount: totalAmount,
        notes: _random.nextBool() ? _generateNotes() : null,
        orderDate: orderDate,
        created: orderDate,
        updated: orderDate,
      );
      
      final createdOrder = await _pbService.create<Order>(
        'orders',
        order.toJson(),
        Order.fromJson,
      );
      
      if (createdOrder != null) {
        // Create order items
        for (int j = 0; j < selectedFoods.length; j++) {
          final orderItem = OrderItem(
            id: '',
            orderId: createdOrder.id,
            foodId: selectedFoods[j].id,
            quantity: quantities[j],
            unitPrice: selectedFoods[j].price,
            specialInstructions: _random.nextBool() ? _generateSpecialInstructions() : null,
            created: orderDate,
            updated: orderDate,
          );
          
          await _pbService.create<OrderItem>(
            'order_items',
            orderItem.toJson(),
            OrderItem.fromJson,
          );
        }
        
        generatedOrders.add(createdOrder);
        print('สร้าง: ${createdOrder.orderNumber} - ${createdOrder.customerName} (${createdOrder.totalAmount.toStringAsFixed(0)}฿)');
      }
    }
    
    print('สร้างคำสั่งซื้อเสร็จสิ้น: ${generatedOrders.length} รายการ');
    return generatedOrders;
  }

  // Generate All Data
  Future<void> generateAllData({
    int categoryCount = 5,
    int foodCount = 15,
    int orderCount = 30,
  }) async {
    print('เริ่มสร้างข้อมูลทั้งหมด...');
    
    try {
      // Generate categories first
      await generateCategories(count: categoryCount);
      
      // Wait a bit for database sync
      await Future.delayed(const Duration(seconds: 1));
      
      // Generate foods
      await generateFoods(count: foodCount);
      
      // Wait a bit for database sync
      await Future.delayed(const Duration(seconds: 1));
      
      // Generate orders
      await generateOrders(count: orderCount);
      
      print('สร้างข้อมูลทั้งหมดเสร็จสิ้น!');
      
    } catch (error) {
      print('เกิดข้อผิดพลาด: $error');
    }
  }

  // Clear All Data
  Future<void> clearAllData() async {
    print('เริ่มลบข้อมูลทั้งหมด...');
    
    try {
      // Delete orders first (because of relations)
      final orders = await _pbService.getList<Order>('orders', Order.fromJson);
      for (final order in orders) {
        await _pbService.delete('orders', order.id);
      }
      print('ลบคำสั่งซื้อทั้งหมด');
      
      // Delete foods
      final foods = await _pbService.getList<Food>('foods', Food.fromJson);
      for (final food in foods) {
        await _pbService.delete('foods', food.id);
      }
      print('ลบรายการอาหารทั้งหมด');
      
      // Delete categories
      final categories = await _pbService.getList<Category>('categories', Category.fromJson);
      for (final category in categories) {
        await _pbService.delete('categories', category.id);
      }
      print('ลบหมวดหมู่ทั้งหมด');
      
      print('ลบข้อมูลทั้งหมดเสร็จสิ้น!');
      
    } catch (error) {
      print('เกิดข้อผิดพลาดในการลบข้อมูล: $error');
    }
  }

  // Helper methods
  String _generateIngredients(String foodName) {
    final ingredientsList = {
      'ผัดไทย': 'เส้นหมี่, กุ้ง, ไข่, ถั่วงอก, กุยช่าย, มะขามเปียก',
      'ต้มยำกุ้ง': 'กุ้งแม่น้ำ, ข่า, ตะไคร้, ใบมะกรูด, พริกขี้หนู',
      'ส้มตำไทย': 'มะละกอดิบ, มะเขือเทศ, ถั่วฝักยาว, กะปิ, มะนาว',
      'แกงเขียวหวานไก่': 'ไก่, พริกแกงเขียวหวาน, มะเขือเปราะ, ใบโหระพา',
    };
    
    return ingredientsList[foodName] ?? 'ส่วนผสมคุณภาพดี, ปรุงรสอร่อย';
  }

  String _generatePhoneNumber() {
    return '08${_random.nextInt(90000000) + 10000000}';
  }

  OrderStatus _getRandomStatus() {
    final statusWeights = [
      OrderStatus.pending,
      OrderStatus.preparing,
      OrderStatus.ready,
      OrderStatus.served,
      OrderStatus.served,
      OrderStatus.served, // More served orders
      OrderStatus.cancelled,
    ];
    return statusWeights[_random.nextInt(statusWeights.length)];
  }

  DateTime _getRandomDate() {
    final now = DateTime.now();
    final daysBack = _random.nextInt(7); // Last 7 days
    final hoursBack = _random.nextInt(24);
    final minutesBack = _random.nextInt(60);
    
    return now.subtract(Duration(
      days: daysBack,
      hours: hoursBack,
      minutes: minutesBack,
    ));
  }

  String _generateNotes() {
    final notes = [
      'กรุณาทำเผ็ดน้อย',
      'ไม่ใส่ผักชี',
      'เพิ่มน้ำจิ้มแจ่ว',
      'ขอน้ำแข็งเพิ่ม',
      'ไม่ใส่หอม',
      'ทำพิเศษหน่อย',
      'เสิร์ฟเร็วๆ',
    ];
    return notes[_random.nextInt(notes.length)];
  }

  String _generateSpecialInstructions() {
    final instructions = [
      'ไม่เผ็ด',
      'เผ็ดน้อย',
      'เผ็ดมาก',
      'ไม่ใส่น้ำตาล',
      'เพิ่มผัก',
      'ไม่ใส่เนื้อสัตว์',
    ];
    return instructions[_random.nextInt(instructions.length)];
  }
}