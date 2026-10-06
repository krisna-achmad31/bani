// ─────────────────────────────────────────────────────────────────────────────
//  AppUser — Domain Entity
// ─────────────────────────────────────────────────────────────────────────────

class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;

  String get initials {
    if (displayName == null || displayName!.isEmpty) return '?';
    final parts = displayName!.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  String toString() => 'AppUser(uid: $uid, email: $email)';
}
