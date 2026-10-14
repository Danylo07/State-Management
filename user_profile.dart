/// Незмінні дані профілю користувача.
class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.bio,
  });

  final String name;
  final String email;
  final String bio;

  UserProfile copyWith({String? name, String? bio}) {
    return UserProfile(
      name: name ?? this.name,
      email: email,
      bio: bio ?? this.bio,
    );
  }
}
