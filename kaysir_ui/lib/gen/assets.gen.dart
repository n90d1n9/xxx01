// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsFontsGen {
  const $AssetsFontsGen();

  /// File path: assets/fonts/RobotoCondensed-Bold.ttf
  String get robotoCondensedBold => 'assets/fonts/RobotoCondensed-Bold.ttf';

  /// File path: assets/fonts/RobotoCondensed-Italic.ttf
  String get robotoCondensedItalic => 'assets/fonts/RobotoCondensed-Italic.ttf';

  /// File path: assets/fonts/RobotoCondensed-Light.ttf
  String get robotoCondensedLight => 'assets/fonts/RobotoCondensed-Light.ttf';

  /// File path: assets/fonts/RobotoCondensed-Regular.ttf
  String get robotoCondensedRegular =>
      'assets/fonts/RobotoCondensed-Regular.ttf';

  /// File path: assets/fonts/RobotoCondensed-Thin.ttf
  String get robotoCondensedThin => 'assets/fonts/RobotoCondensed-Thin.ttf';

  /// File path: assets/fonts/RobotoFlex-Regular.ttf
  String get robotoFlexRegular => 'assets/fonts/RobotoFlex-Regular.ttf';

  /// List of all assets
  List<String> get values => [
    robotoCondensedBold,
    robotoCondensedItalic,
    robotoCondensedLight,
    robotoCondensedRegular,
    robotoCondensedThin,
    robotoFlexRegular,
  ];
}

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/ic_appicon.png
  AssetGenImage get icAppicon =>
      const AssetGenImage('assets/icons/ic_appicon.png');

  /// File path: assets/icons/ic_launcher.png
  AssetGenImage get icLauncher =>
      const AssetGenImage('assets/icons/ic_launcher.png');

  /// File path: assets/icons/logo-golok.png
  AssetGenImage get logoGolok =>
      const AssetGenImage('assets/icons/logo-golok.png');

  /// List of all assets
  List<AssetGenImage> get values => [icAppicon, icLauncher, logoGolok];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/ic_launcher.png
  AssetGenImage get icLauncher =>
      const AssetGenImage('assets/images/ic_launcher.png');

  /// List of all assets
  List<AssetGenImage> get values => [icLauncher];
}

class Assets {
  const Assets._();

  static const $AssetsFontsGen fonts = $AssetsFontsGen();
  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
