class LayoutConfig {
  final String fieldId;
  final double defaultPadding;
  final double sideMenuWidth;
  final String iconApp;
  final String imageLogin;
  final String imageIcon;
  final double fontSize;

  const LayoutConfig({
    this.fieldId = 'id',
    this.defaultPadding = 16.0,
    this.sideMenuWidth = 230.0,
    this.iconApp = 'assets/icons/app_icon.png',
    this.imageLogin = 'assets/images/login.png',
    this.imageIcon = 'assets/icons/app_icon.png',
    this.fontSize = 16.0,
  });

  LayoutConfig copyWith({
    String? fieldId,
    double? defaultPadding,
    double? sideMenuWidth,
    String? iconApp,
    String? imageLogin,
    String? imageIcon,
    double? fontSize,
  }) {
    return LayoutConfig(
      fieldId: fieldId ?? this.fieldId,
      defaultPadding: defaultPadding ?? this.defaultPadding,
      sideMenuWidth: sideMenuWidth ?? this.sideMenuWidth,
      iconApp: iconApp ?? this.iconApp,
      imageLogin: imageLogin ?? this.imageLogin,
      imageIcon: imageIcon ?? this.imageIcon,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  @override
  String toString() {
    return '''
fieldId: $fieldId \n
defaultPadding: $defaultPadding \n
sideMenuWidth: $sideMenuWidth \n
iconApp: $iconApp \n
imageLogin: $imageLogin \n
imageIcon: $imageIcon \n
fontSize: $fontSize''';
  }
}
