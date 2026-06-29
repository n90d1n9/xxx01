// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get title => 'hello world';

  @override
  String get home => 'Home';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get settings => 'Settings';

  @override
  String get about => 'About Apps';

  @override
  String get please_fill_field => 'Please fill column';

  @override
  String get data_empty => 'Data empty';

  @override
  String get share => 'Share';

  @override
  String get search => 'Search';

  @override
  String get add => 'Add';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get remove => 'Remove';

  @override
  String get email => 'Email';

  @override
  String get users => 'Users';

  @override
  String get user_password => 'User Password';

  @override
  String get password => 'Password';

  @override
  String get remember_me => 'Remember Me';

  @override
  String get dont_have_account => 'Don\'t have account? ';

  @override
  String get sign_in => 'Sign In';

  @override
  String get sign_up => 'Sign Up';

  @override
  String get sign_out => 'Sign Out';

  @override
  String get forgot_password => 'Forgot Password?';

  @override
  String get want_sign_out => 'Are you sure you want to logout?';

  @override
  String get loginEmpty => 'Email can\'t be empty';

  @override
  String get loginValidEmail => 'Please enter a valid email address';

  @override
  String get loginTryEmail =>
      'Email provided isn\'t valid.Try another email address';

  @override
  String get passwordConfirm => 'Confirm password can\'t be empty';

  @override
  String get passwordMatch => 'Password doesn\'t match';

  @override
  String get passwordEmpty => 'Password can\'t be empty';

  @override
  String get passwordLength => 'Password must be at-least 6 characters long';

  @override
  String get errorUsername => 'Username and password doesn\'t match';

  @override
  String get errorUnauthorized => 'Unauthorized';

  @override
  String get errorNetwork =>
      'Something went wrong, please check your network and try again';
}
