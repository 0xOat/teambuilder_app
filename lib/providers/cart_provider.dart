import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/food.dart';

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    return [];
  }

  void addItem(Food food, int quantity, {String? specialInstructions}) {
    final existingIndex = state.indexWhere((item) => 
      item.food.id == food.id && item.specialInstructions == specialInstructions);
    
    if (existingIndex >= 0) {
      final updatedItems = [...state];
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + quantity,
      );
      state = updatedItems;
    } else {
      state = [
        ...state,
        CartItem(
          food: food,
          quantity: quantity,
          specialInstructions: specialInstructions,
        ),
      ];
    }
  }

  void updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      removeItem(index);
      return;
    }
    
    final updatedItems = [...state];
    updatedItems[index] = updatedItems[index].copyWith(quantity: quantity);
    state = updatedItems;
  }

  void removeItem(int index) {
    state = state.where((item) => state.indexOf(item) != index).toList();
  }

  void clear() {
    state = [];
  }

  double get totalAmount {
    return state.fold(0, (sum, item) => sum + item.totalPrice);
  }

  int get totalItems {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }
}

class CartItem {
  final Food food;
  final int quantity;
  final String? specialInstructions;

  CartItem({
    required this.food,
    required this.quantity,
    this.specialInstructions,
  });

  double get totalPrice => food.price * quantity;

  CartItem copyWith({
    Food? food,
    int? quantity,
    String? specialInstructions,
  }) {
    return CartItem(
      food: food ?? this.food,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
}