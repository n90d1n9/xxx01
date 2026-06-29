import 'dart:convert';

import 'enums.dart';
import 'user.dart';

class Member {
  final MemberType type;
  final User user;

  Member({required this.type, required this.user});

  Member copyWith({MemberType? type, User? user}) {
    return Member(type: type ?? this.type, user: user ?? this.user);
  }

  Map<String, dynamic> toMap() {
    return {'type': type.toString(), 'user': user.toMap()};
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Member(type: $type, user: $user)';
  }
}
