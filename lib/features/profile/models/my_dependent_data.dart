enum DependentType { child, spouse, parent, sibling, other }

/// Represents a relationship link from the current user (guardian) to
/// someone they track — a "dependent" in their circle.
///
/// [dependentUserId] is nullable because the dependent may not have an
/// account in the app yet (e.g. a parent tracking a young child who has
/// no login). Once that person joins, this can be backfilled to link
/// their real profile, enabling the future "relationship circle" view
/// where both sides can see each other.
class MyDependent {
  final String id;              // id of this relationship record
  final String guardianId;      // profile id of the user doing the tracking
  final String? dependentUserId; // profile id of the dependent, if they have an account
  final DependentType dependentType;
  final String name;            // display name (always present, even pre-account)
  final String? relationshipLabel; // optional custom label, e.g. "Grandma"
  final String? dateOfBirth;
  final bool canViewFullProfile; // permission flag for the circle feature

  const MyDependent({
    this.id = '',
    required this.guardianId,
    this.dependentUserId,
    required this.dependentType,
    required this.name,
    this.relationshipLabel,
    this.dateOfBirth,
    this.canViewFullProfile = false,
  });

  MyDependent copyWith({
    String? id,
    String? guardianId,
    String? dependentUserId,
    DependentType? dependentType,
    String? name,
    String? relationshipLabel,
    String? dateOfBirth,
    bool? canViewFullProfile,
  }) {
    return MyDependent(
      id: id ?? this.id,
      guardianId: guardianId ?? this.guardianId,
      dependentUserId: dependentUserId ?? this.dependentUserId,
      dependentType: dependentType ?? this.dependentType,
      name: name ?? this.name,
      relationshipLabel: relationshipLabel ?? this.relationshipLabel,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      canViewFullProfile: canViewFullProfile ?? this.canViewFullProfile,
    );
  }
}