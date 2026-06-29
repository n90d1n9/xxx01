import 'user.dart';

class AuthResponse {
  final String? token;
  final User? user;

  AuthResponse({this.token, this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}
