class UserEntity {
  final String id;
  final String email;
  final String displayName;
  final String? profilePictureUrl;
  final String? phoneNumber;
  final bool isEmailVerified;
  final DateTime createdAt;

  UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.profilePictureUrl,
    this.phoneNumber,
    required this.isEmailVerified,
    required this.createdAt,
  });
}
