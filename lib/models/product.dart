import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final DateTime? createdAt;
  final String? createdBy;
  final String sku;
  final String name;
  final String? type;
  final String? uom;
  final String? image;
  final String? price;

  const Product({
    required this.id,
    this.createdAt,
    this.createdBy,
    required this.sku,
    required this.name,
    this.type,
    this.uom,
    this.image,
    this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      createdBy: json['created_by'] as String?,
      sku: json['sku'] as String,
      name: json['name'] as String,
      type: json['type'] as String?,
      uom: json['uom'] as String?,
      image: json['image'] as String?,
      price: json['price']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'created_by': createdBy,
      'sku': sku,
      'name': name,
      'type': type,
      'uom': uom,
      'image': image,
      'price': price,
    };
  }

  @override
  List<Object?> get props => [id, createdAt, createdBy, sku, name, type, uom, image, price];
}

