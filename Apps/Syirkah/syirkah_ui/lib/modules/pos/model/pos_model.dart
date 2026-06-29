class PosModel {
  bool usingBarcode;
  bool showCustomer;
  ScreenType screenType;
  bool showSavedOrder;

  PosModel(
      {this.screenType = ScreenType.grocery,
      this.usingBarcode = false,
      this.showSavedOrder = false,
      this.showCustomer = false});
}

enum ScreenType { retail, grocery, resto, custom}
