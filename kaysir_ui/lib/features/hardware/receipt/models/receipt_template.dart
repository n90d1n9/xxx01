class ReceiptTemplate {
  final String id;
  final String name;
  final String headerImage;
  final String headerText;
  final bool showLogo;
  final bool showBarcode;
  final String footerText;
  final double fontSize;
  final bool showItemDiscount;
  final List<String> additionalFields;

  ReceiptTemplate({
    required this.id,
    required this.name,
    required this.headerImage,
    required this.headerText,
    required this.showLogo,
    required this.showBarcode,
    required this.footerText,
    required this.fontSize,
    required this.showItemDiscount,
    required this.additionalFields,
  });
}

