import 'handler.dart';

class Lifecycle {
  final Handler? postStart;
  final Handler? preStop;
  Lifecycle({this.postStart, this.preStop});
  factory Lifecycle.fromJson(Map<String, dynamic> json) {
    return Lifecycle(
      postStart:
          json['postStart'] != null
              ? Handler.fromJson(json['postStart'])
              : null,
      preStop:
          json['preStop'] != null ? Handler.fromJson(json['preStop']) : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (postStart != null) 'postStart': postStart!.toJson(),
      if (preStop != null) 'preStop': preStop!.toJson(),
    };
  }
}
