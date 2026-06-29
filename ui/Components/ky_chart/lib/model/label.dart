import 'text_style.dart';

class Label {
  bool? show;
  String? position;
  ChartTextStyle? textStyle;

  Label({this.show, this.position, this.textStyle});

  factory Label.fromJson(Map<String, dynamic> json) {
    return Label(
      show: json['show'],
      position: json['position'],
      textStyle: json['textStyle'] != null
          ? ChartTextStyle.fromJson(json['textStyle'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'show': show,
      'position': position,
      'textStyle': textStyle?.toJson(),
    };
  }
}

class ItemStyle {
  String color;
  String? borderColor;

  ItemStyle({this.color = 'black', this.borderColor = 'grey'});

  factory ItemStyle.fromJson(Map<String, dynamic> json) {
    return ItemStyle(
      color: json['color'],
      borderColor: json['borderColor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'color': color,
      'borderColor': borderColor,
    };
  }
}

class Emphasis {
  Label? label;
  ItemStyle? itemStyle;

  Emphasis({this.label, this.itemStyle});

  factory Emphasis.fromJson(Map<String, dynamic> json) {
    return Emphasis(
      label: json['label'] != null ? Label.fromJson(json['label']) : null,
      itemStyle: json['itemStyle'] != null
          ? ItemStyle.fromJson(json['itemStyle'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label?.toJson(),
      'itemStyle': itemStyle?.toJson(),
    };
  }
}
