import 'package:saluun_frontend/domain/entities/salon_entity.dart';
import 'package:saluun_frontend/data/models/api_models.dart';

/// Combined model for salon details with services
/// Used by BookingScreen and SalonDetailsScreen
class SalonDetails {
  final SalonEntity salon;
  final List<Service> services;

  SalonDetails({required this.salon, this.services = const []});
}
