import 'package:shop_app/Model/cart.dart';

class Order {
  final double amount;
  final List<Cart> products;
  final DateTime dateTime;

  Order({
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}
