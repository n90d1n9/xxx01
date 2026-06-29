import '../../survey/models/file_option.dart';
import '../../survey/models/matrix.dart';
import '../../survey/models/rating_option.dart';
import '../../survey/models/scale_options.dart';
import 'choice.dart';


class QuestionOptions {
  final List<Choice>? choices;
  final MatrixOptions? matrixOptions;
  final RatingOptions? ratingOptions;
  final ScaleOptions? scaleOptions;
  final FileOptions? fileOptions;
  final Map<String, dynamic>? customOptions;

  

  QuestionOptions({
    this.choices,
    this.matrixOptions,
    this.ratingOptions,
    this.scaleOptions,
    this.fileOptions,
    this.customOptions,
  });

  factory QuestionOptions.fromJson(Map<String, dynamic> json) {
    return QuestionOptions(
      choices: (json['choices'] as List<dynamic>?)
          ?.map((c) => Choice.fromJson(c as Map<String, dynamic>))
          .toList(),
      matrixOptions: json['matrixOptions'] != null
          ? MatrixOptions.fromJson(json['matrixOptions'])
          : null,
      ratingOptions: json['ratingOptions'] != null
          ? RatingOptions.fromJson(json['ratingOptions'])
          : null,
      scaleOptions: json['scaleOptions'] != null
          ? ScaleOptions.fromJson(json['scaleOptions'])
          : null,
      fileOptions: json['fileOptions'] != null
          ? FileOptions.fromJson(json['fileOptions'])
          : null,
      customOptions: json['customOptions'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'choices': choices?.map((c) => c.toJson()).toList(),
      'matrixOptions': matrixOptions?.toJson(),
      'ratingOptions': ratingOptions?.toJson(),
      'scaleOptions': scaleOptions?.toJson(),
      'fileOptions': fileOptions?.toJson(),
      'customOptions': customOptions,
    };
  }
}
