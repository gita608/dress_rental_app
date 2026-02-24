enum BookingStatus { pending, active, completed }
enum DressStatus { available, cleaning, repair, rented, outOfStock }
enum ViewMode { list, grid }

class Category {
  final String id;
  final String title;
  final String description;

  Category({
    required this.id,
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      title: map['title'],
      description: map['description'],
    );
  }
}

class Dress {
  final String id;
  final String name;
  final double price;
  final String description;
  final List<String> sizes;
  final String? categoryId;
  int stock;
  DressStatus status;

  Dress({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.sizes,
    this.categoryId,
    this.stock = 1,
    this.status = DressStatus.available,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'sizes': sizes,
      'categoryId': categoryId,
      'stock': stock,
      'status': status.name,
    };
  }

  factory Dress.fromMap(Map<String, dynamic> map) {
    return Dress(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      description: map['description'],
      sizes: List<String>.from(map['sizes']),
      categoryId: map['categoryId'],
      stock: map['stock'] ?? 1,
      status: DressStatus.values.byName(map['status']),
    );
  }
}

class Booking {
  final String id;
  final String dressId;
  final String clientName;
  final String clientPhone;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, double> measurements;
  BookingStatus status;

  Booking({
    required this.id,
    required this.dressId,
    required this.clientName,
    required this.clientPhone,
    required this.startDate,
    required this.endDate,
    required this.measurements,
    this.status = BookingStatus.pending,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dressId': dressId,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'measurements': measurements,
      'status': status.name,
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      dressId: map['dressId'],
      clientName: map['clientName'],
      clientPhone: map['clientPhone'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      measurements: Map<String, double>.from(map['measurements']),
      status: BookingStatus.values.byName(map['status']),
    );
  }
}

class User {
  final String email;
  final String name;
  final String? profileImage;

  User({
    required this.email,
    required this.name,
    this.profileImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'profileImage': profileImage,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      email: map['email'],
      name: map['name'],
      profileImage: map['profileImage'],
    );
  }
}
