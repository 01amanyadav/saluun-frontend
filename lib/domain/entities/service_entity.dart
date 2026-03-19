/// Service entity for the domain layer
/// Represents a salon service offering (haircut, nail service, etc.)
class ServiceEntity {
  final String id;
  final String salonId;
  final String name;
  final String? description;
  final double price;
  final int? durationMinutes;
  final String? category;
  final int? popularity;

  ServiceEntity({
    required this.id,
    required this.salonId,
    required this.name,
    this.description,
    required this.price,
    this.durationMinutes,
    this.category,
    this.popularity,
  });

  @override
  String toString() =>
      'ServiceEntity(id: $id, name: $name, price: $price, duration: $durationMinutes min)';
}
