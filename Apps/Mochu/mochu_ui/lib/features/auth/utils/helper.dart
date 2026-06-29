String? validateEmail(String? value) {
  // Regex for email validation
  String pattern = "[a-zA-Z0-9+._%-+]{1,256}\\@"
      "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}"
      "(\\.[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25})+";
  RegExp regExp = RegExp(pattern);

  if (value == null || value.isEmpty) {
    return 'Email is required';
  }
  if (regExp.hasMatch(value)) {
    return 'Please enter a valid email';
  }
  return null;
}

/*   String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  } */

String? validateName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Name is required';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < 8) {
    return 'Password must be at least 8 characters';
  }
  if (!RegExp(r'[A-Z]').hasMatch(value)) {
    return 'Password must contain at least one uppercase letter';
  }
  if (!RegExp(r'[0-9]').hasMatch(value)) {
    return 'Password must contain at least one number';
  }
  return null;
}
