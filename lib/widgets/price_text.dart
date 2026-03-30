import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PriceText extends StatelessWidget {
  final double price;
  final double? discountedPrice;
  final double fontSize;

  const PriceText({super.key, required this.price, this.discountedPrice, this.fontSize = 14});

  String _format(double v) => NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 2).format(v);

  @override
  Widget build(BuildContext context) {
    if (discountedPrice != null && discountedPrice! < price) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_format(discountedPrice!), style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xFF0EA5E9))),
          Text(_format(price), style: TextStyle(fontSize: fontSize - 2, color: Colors.grey, decoration: TextDecoration.lineThrough)),
        ],
      );
    }
    return Text(_format(price), style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xFF0EA5E9)));
  }
}
