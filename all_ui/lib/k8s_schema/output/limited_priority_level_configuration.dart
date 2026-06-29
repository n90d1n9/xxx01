import 'limit_response.dart';

class LimitedPriorityLevelConfiguration {
  final int? assuredConcurrencyShares;
  final LimitResponse? limitResponse;
  LimitedPriorityLevelConfiguration({
    this.assuredConcurrencyShares,
    this.limitResponse,
  });
  factory LimitedPriorityLevelConfiguration.fromJson(
    Map<String, dynamic> json,
  ) {
    return LimitedPriorityLevelConfiguration(
      assuredConcurrencyShares: json['assuredConcurrencyShares'],
      limitResponse:
          json['limitResponse'] != null
              ? LimitResponse.fromJson(json['limitResponse'])
              : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (assuredConcurrencyShares != null)
        'assuredConcurrencyShares': assuredConcurrencyShares,
      if (limitResponse != null) 'limitResponse': limitResponse!.toJson(),
    };
  }
}
