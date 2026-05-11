import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

const _cartBoxName = 'fasalx_cart';
const _cartItemsKey = 'items';

class CartProduct {
  const CartProduct({
    required this.id,
    required this.name,
    required this.quantityLabel,
    required this.price,
    required this.iconCodePoint,
    required this.colorValue,
    required this.category,
  });

  final int id;
  final String name;
  final String quantityLabel;
  final int price;
  final int iconCodePoint;
  final int colorValue;
  final String category;

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantityLabel': quantityLabel,
      'price': price,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
      'category': category,
    };
  }

  factory CartProduct.fromJson(Map<dynamic, dynamic> json) {
    return CartProduct(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      quantityLabel: json['quantityLabel'] as String,
      price: (json['price'] as num).toInt(),
      iconCodePoint: (json['iconCodePoint'] as num).toInt(),
      colorValue: (json['colorValue'] as num).toInt(),
      category: json['category'] as String,
    );
  }
}

class CartLine {
  const CartLine({required this.product, required this.quantity});

  final CartProduct product;
  final int quantity;

  int get total => product.price * quantity;

  CartLine copyWith({int? quantity}) {
    return CartLine(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }

  factory CartLine.fromJson(Map<dynamic, dynamic> json) {
    return CartLine(
      product: CartProduct.fromJson(
        Map<dynamic, dynamic>.from(json['product'] as Map),
      ),
      quantity: (json['quantity'] as num).toInt(),
    );
  }
}

class CartController extends ChangeNotifier {
  CartController._();

  static final CartController instance = CartController._();

  final Map<int, CartLine> _items = {};
  Box<dynamic>? _box;

  List<CartLine> get items => List.unmodifiable(_items.values);
  bool get isEmpty => _items.isEmpty;
  int get totalItems => _items.values.fold(0, (sum, item) => sum + item.quantity);
  int get subtotal => _items.values.fold(0, (sum, item) => sum + item.total);
  int get gst => (subtotal * 0.05).round();
  int get deliveryFee => subtotal >= 500 ? 0 : 49;
  int get discount => subtotal >= 2000 ? 150 : 0;
  int get grandTotal => subtotal + gst + deliveryFee - discount;

  Future<void> load() async {
    _box = await Hive.openBox<dynamic>(_cartBoxName);
    final saved = _box?.get(_cartItemsKey);
    if (saved is List) {
      _items
        ..clear()
        ..addEntries(
          saved.map((item) {
            final line = CartLine.fromJson(Map<dynamic, dynamic>.from(item as Map));
            return MapEntry(line.product.id, line);
          }),
        );
    }
    notifyListeners();
  }

  int quantityFor(int productId) => _items[productId]?.quantity ?? 0;

  void add(CartProduct product) {
    final current = _items[product.id];
    _items[product.id] = current == null
        ? CartLine(product: product, quantity: 1)
        : current.copyWith(quantity: current.quantity + 1);
    _persistAndNotify();
  }

  void increment(int productId) {
    final current = _items[productId];
    if (current == null) return;
    _items[productId] = current.copyWith(quantity: current.quantity + 1);
    _persistAndNotify();
  }

  void decrement(int productId) {
    final current = _items[productId];
    if (current == null) return;
    if (current.quantity <= 1) {
      _items.remove(productId);
    } else {
      _items[productId] = current.copyWith(quantity: current.quantity - 1);
    }
    _persistAndNotify();
  }

  void remove(int productId) {
    _items.remove(productId);
    _persistAndNotify();
  }

  void clear() {
    _items.clear();
    _persistAndNotify();
  }

  void _persistAndNotify() {
    _box?.put(_cartItemsKey, _items.values.map((item) => item.toJson()).toList());
    notifyListeners();
  }
}

class CartScope extends InheritedNotifier<CartController> {
  const CartScope({
    super.key,
    required CartController controller,
    required super.child,
  }) : super(notifier: controller);

  static CartController watch(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CartScope>();
    assert(scope != null, 'CartScope not found in widget tree');
    return scope!.notifier!;
  }

  static CartController read(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<CartScope>();
    final scope = element?.widget as CartScope?;
    assert(scope != null, 'CartScope not found in widget tree');
    return scope!.notifier!;
  }
}
