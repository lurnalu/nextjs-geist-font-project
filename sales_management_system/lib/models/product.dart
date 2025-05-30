enum ProductCategory {
  medicine,
  service,
  equipment,
  consultation,
  other
}

class Product {
  final int? id;
  final String name;
  final String description;
  final double price;
  final ProductCategory category;
  final String? barcode;
  int stockLevel;
  final bool isService;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.barcode,
    required this.stockLevel,
    this.isService = false,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category.toString().split('.').last,
      'barcode': barcode,
      'stockLevel': stockLevel,
      'isService': isService ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      category: ProductCategory.values.firstWhere(
        (category) => category.toString().split('.').last == map['category'],
      ),
      barcode: map['barcode'],
      stockLevel: map['stockLevel'],
      isService: map['isService'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    ProductCategory? category,
    String? barcode,
    int? stockLevel,
    bool? isService,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      barcode: barcode ?? this.barcode,
      stockLevel: stockLevel ?? this.stockLevel,
      isService: isService ?? this.isService,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  void decreaseStock(int quantity) {
    if (!isService && quantity > 0 && stockLevel >= quantity) {
      stockLevel -= quantity;
    }
  }

  void increaseStock(int quantity) {
    if (!isService && quantity > 0) {
      stockLevel += quantity;
    }
  }

  bool get isLowStock => !isService && stockLevel <= 10;
}
