import 'menu.dart';

class FeaturesServices {
    // singleton object
  static final FeaturesServices _singleton = FeaturesServices._();

  // factory method to return the same object each time its needed
  factory FeaturesServices() => _singleton;

  FeaturesServices._();
  
  static final _pages  = <Menu>[];

  static addPages(Menu newPages){
    _pages.add(newPages);
  }

  static List<Menu> get pages => _pages;
}
