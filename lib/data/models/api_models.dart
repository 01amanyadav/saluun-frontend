/// Base API Response model that wraps all API responses
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? error;

  ApiResponse({required this.success, this.message, this.data, this.error});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      error: json['error'],
    );
  }

  @override
  String toString() =>
      'ApiResponse(success: $success, message: $message, error: $error)';
}

/// User model for auth and profile
class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImage;
  final String? role; // user, owner, admin
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImage,
    this.role,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profileImage: json['profileImage'],
      role: json['role'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'profileImage': profileImage,
    'role': role,
    'createdAt': createdAt.toIso8601String(),
  };

  @override
  String toString() => 'User(id: $id, name: $name, email: $email)';
}

/// Auth response with token
class AuthResponse {
  final String? token;
  final User? user;
  final String? message;

  AuthResponse({this.token, this.user, this.message});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      message: json['message'],
    );
  }

  @override
  String toString() =>
      'AuthResponse(token: ${token != null ? '***' : 'null'}, user: $user)';
}

/// Salon model
class Salon {
  final String id;
  final String name;
  final String location;
  final String? description;
  final String? phone;
  final String? email;
  final String? image;
  final double? rating;
  final int? reviewCount;
  final String? openingTime;
  final String? closingTime;

  Salon({
    required this.id,
    required this.name,
    required this.location,
    this.description,
    this.phone,
    this.email,
    this.image,
    this.rating,
    this.reviewCount,
    this.openingTime,
    this.closingTime,
  });

  factory Salon.fromJson(Map<String, dynamic> json) {
    return Salon(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      description: json['description'],
      phone: json['phone'],
      email: json['email'],
      image: json['image'],
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'],
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
    );
  }

  @override
  String toString() => 'Salon(id: $id, name: $name, location: $location)';
}

/// Booking model
class Booking {
  final String id;
  final String userId;
  final String salonId;
  final String serviceId;
  final DateTime bookingDate;
  final String bookingTime;
  final String status; // pending, confirmed, completed, cancelled
  final double? totalPrice;

  Booking({
    required this.id,
    required this.userId,
    required this.salonId,
    required this.serviceId,
    required this.bookingDate,
    required this.bookingTime,
    required this.status,
    this.totalPrice,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'].toString(),
      userId: json['userId'].toString(),
      salonId: json['salonId'].toString(),
      serviceId: json['serviceId'].toString(),
      bookingDate: DateTime.parse(json['bookingDate']),
      bookingTime: json['bookingTime'] ?? '',
      status: json['status'] ?? 'pending',
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
    );
  }

  @override
  String toString() => 'Booking(id: $id, status: $status, date: $bookingDate)';
}

/// Service model for salon services
class Service {
  final String id;
  final String salonId;
  final String name;
  final String? description;
  final double price;
  final int? durationMinutes;
  final String? category;
  final int? popularity;

  Service({
    required this.id,
    required this.salonId,
    required this.name,
    this.description,
    required this.price,
    this.durationMinutes,
    this.category,
    this.popularity,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'].toString(),
      salonId: json['salonId'].toString(),
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: json['durationMinutes'],
      category: json['category'],
      popularity: json['popularity'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'salonId': salonId,
    'name': name,
    'description': description,
    'price': price,
    'durationMinutes': durationMinutes,
    'category': category,
    'popularity': popularity,
  };

  @override
  String toString() =>
      'Service(id: $id, name: $name, price: $price, duration: $durationMinutes min)';
}
