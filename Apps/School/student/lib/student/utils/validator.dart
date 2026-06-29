// utils/validators.dart
class Validators {
  static String? nisn(String? value) {
    if (value == null || value.isEmpty) {
      return 'NISN is required';
    }
    if (value.length != 10) {
      return 'NISN must be 10 characters';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'NISN must contain only numbers';
    }
    return null;
  }

  static String? required(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (!RegExp(r'^[0-9]{10,13}$').hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }
}
