class SalonEntity {
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

  SalonEntity({
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
}
