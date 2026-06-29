import 'dart:convert';

/// User entity
class User {
  final int? id;
  final String? login;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? password;
  final String? email;
  final String? phone;
  final String? imageUrl;
  final String? provider;
  final bool? activated;
  final String? langKey;
  final List<dynamic>? authorities;
  final String? createdBy;
  final DateTime? createdDate;
  final String? lastModifiedBy;
  final DateTime? lastModifiedDate;

  const User(
      {this.id,
      this.login,
      this.username,
      this.firstName,
      this.lastName,
      this.password,
      this.email,
      this.phone,
      this.imageUrl,
      this.activated,
      this.langKey,
      this.provider,
      this.authorities,
      this.createdBy,
      this.createdDate,
      this.lastModifiedBy,
      this.lastModifiedDate})
      : super();

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'],
        login: json['login'],
        username: json['username'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        password: json['password'],
        email: json['email'],
        phone: json['phone'],
        imageUrl: json['imageUrl'],
        activated: json['activated'],
        provider: json['provider'],
        langKey: json['langKey'],
        authorities: json['authorities'],
        createdBy: json['createdBy'],
        createdDate: (json['createdDate'] != null)
            ? DateTime.parse(json['createdDate'])
            : null,
        lastModifiedBy: json['lastModifiedBy'],
        lastModifiedDate: (json['lastModifiedDate'] != null)
            ? DateTime.parse(json['lastModifiedDate'])
            : null);
  }

  Map<String, dynamic> toJson() => {
        '"id"': '"$id"',
        '"login"': '"$login"',
        '"username"': '"$username"',
        '"firstName"': '"$firstName"',
        '"password"': '"$password"',
        '"lastName"': '"$lastName"',
        '"phone"': '"$phone"',
        '"email"': '"$email"',
        '"imageUrl"': '"$imageUrl"',
        '"activated"': '"$activated"',
        '"langKey"': '"$langKey"',
        '"provider"': '"$provider"',
        '"authorities"': '$authorities',
        '"createdBy"': '"$createdBy"',
        '"createdDate"': '"${createdDate!.toIso8601String()}Z"',
        '"lastModifiedBy"': '"$lastModifiedBy"',
        '"lastModifiedDate"': '"${lastModifiedDate!.toIso8601String()}Z"'
      };

  static List<User> listFromString(String str) =>
      List<User>.from(json.decode(str).map((x) => User.fromJson(x)));

  static List<User> listFromJson(List<dynamic> data) {
    return data.map((post) => User.fromJson(post)).toList();
  }

  static String listUserToJson(List<User> data) =>
      json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

  static const empty = null;

  User copyWith({
    int? id,
    String? login,
    String? username,
    String? firstName,
    String? lastName,
    String? password,
    String? email,
    String? phone,
    String? imageUrl,
    bool? activated,
    String? langKey,
    String? provider,
    List<dynamic>? authorities,
    String? createdBy,
    DateTime? createdDate,
    String? lastModifiedBy,
    DateTime? lastModifiedDate,
  }) {
    return User(
      id: id ?? this.id,
      login: login ?? this.login,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      password: password ?? this.password,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      activated: activated ?? this.activated,
      langKey: langKey ?? this.langKey,
      provider: provider ?? this.provider,
      authorities: authorities ?? this.authorities,
      createdBy: createdBy ?? this.createdBy,
      createdDate: createdDate ?? this.createdDate,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      lastModifiedDate: lastModifiedDate ?? this.lastModifiedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'login': login,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'imageUrl': imageUrl,
      'activated': activated == true ? 1 : 0,
      'langKey': langKey,
      'provider': provider,
      'authorities': authorities?.join(','),
      'createdBy': createdBy,
      'createdDate': createdDate?.toIso8601String(),
      'lastModifiedBy': lastModifiedBy,
      'lastModifiedDate': lastModifiedDate?.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      login: map['login'] as String?,
      username: map['username'] as String?,
      firstName: map['firstName'] as String?,
      lastName: map['lastName'] as String?,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      imageUrl: map['imageUrl'] as String?,
      activated: map['activated'] == 1,
      langKey: map['langKey'] as String?,
      provider: map['provider'] as String?,
      authorities: map['authorities']?.split(','),
      createdBy: map['createdBy'] as String?,
      createdDate: map['createdDate'] != null
          ? DateTime.parse(map['createdDate'])
          : null,
      lastModifiedBy: map['lastModifiedBy'] as String?,
      lastModifiedDate: map['lastModifiedDate'] != null
          ? DateTime.parse(map['lastModifiedDate'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        login,
        username,
        firstName,
        lastName,
        password,
        email,
        phone,
        imageUrl,
        activated,
        langKey,
        authorities,
        createdBy,
        createdDate,
        lastModifiedBy,
        lastModifiedDate,
      ];
}

class UserList {
  final List<User>? users;

  UserList({
    this.users,
  });

  factory UserList.fromJson(List<dynamic> json) {
    List<User> users = <User>[];
    users = json.map((post) => User.fromJson(post)).toList();

    return UserList(
      users: users,
    );
  }
}
