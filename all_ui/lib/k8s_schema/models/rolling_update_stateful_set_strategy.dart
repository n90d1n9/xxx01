
class RollingUpdateStatefulSetStrategy {final dynamic partition; RollingUpdateStatefulSetStrategy({this.partition}); factory RollingUpdateStatefulSetStrategy.fromJson(Map<String, dynamic> json) {return RollingUpdateStatefulSetStrategy(partition: json['partition']);} Map<String, dynamic> toJson() {return {if (partition != null) 'partition' : partition};}}
