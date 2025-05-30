enum PaymentMethod { cash, mpesa, credit }
enum PaymentStatus { paid, partiallyPaid, unpaid }

class SaleItem {
  final int productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double discount;

  SaleItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    this.discount = 0.0,
  });

  double get total => (unitPrice * quantity) - discount;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'discount': discount,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      productId: map['productId'],
      productName: map['productName'],
      unitPrice: map['unitPrice'],
      quantity: map['quantity'],
      discount: map['discount'],
    );
  }
}

class Sale {
  final int? id;
  final int? customerId;
  final String? customerName;
  final List<SaleItem> items;
  final DateTime saleDate;
  final double totalAmount;
  final double paidAmount;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final String? transactionId;
  final String? notes;
  final int userId;
  final String userFullName;

  Sale({
    this.id,
    this.customerId,
    this.customerName,
    required this.items,
    required this.saleDate,
    required this.totalAmount,
    required this.paidAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    this.transactionId,
    this.notes,
    required this.userId,
    required this.userFullName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'items': items.map((item) => item.toMap()).toList(),
      'saleDate': saleDate.toIso8601String(),
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'paymentMethod': paymentMethod.toString().split('.').last,
      'paymentStatus': paymentStatus.toString().split('.').last,
      'transactionId': transactionId,
      'notes': notes,
      'userId': userId,
      'userFullName': userFullName,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      customerId: map['customerId'],
      customerName: map['customerName'],
      items: (map['items'] as List)
          .map((item) => SaleItem.fromMap(item))
          .toList(),
      saleDate: DateTime.parse(map['saleDate']),
      totalAmount: map['totalAmount'],
      paidAmount: map['paidAmount'],
      paymentMethod: PaymentMethod.values.firstWhere(
        (method) => method.toString().split('.').last == map['paymentMethod'],
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (status) => status.toString().split('.').last == map['paymentStatus'],
      ),
      transactionId: map['transactionId'],
      notes: map['notes'],
      userId: map['userId'],
      userFullName: map['userFullName'],
    );
  }

  double get remainingAmount => totalAmount - paidAmount;
  bool get isFullyPaid => paidAmount >= totalAmount;
  int get itemCount => items.length;
  
  void updatePaymentStatus() {
    if (paidAmount >= totalAmount) {
      paymentStatus = PaymentStatus.paid;
    } else if (paidAmount > 0) {
      paymentStatus = PaymentStatus.partiallyPaid;
    } else {
      paymentStatus = PaymentStatus.unpaid;
    }
  }
}
