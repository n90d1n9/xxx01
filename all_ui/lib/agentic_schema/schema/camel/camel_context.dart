import '../exception/error_handler_factory.dart';
import '../common/global_options.dart';
import '../common/thread_pool_profile.dart';

class CamelContext {
  final String? name;
  final Map<String, dynamic>? properties;
  final GlobalOptions? globalOptions;
  final ThreadPoolProfile? threadPoolProfile;
  final ErrorHandlerFactory? errorHandlerFactory;

  CamelContext({
    this.name,
    this.properties,
    this.globalOptions,
    this.threadPoolProfile,
    this.errorHandlerFactory,
  });

  factory CamelContext.fromJson(Map<String, dynamic> json) {
    return CamelContext(
      name: json['name'] as String?,
      properties: json['properties'] != null
          ? Map<String, dynamic>.from(json['properties'] as Map)
          : null,
      globalOptions: json['globalOptions'] != null
          ? GlobalOptions.fromJson(
              json['globalOptions'] as Map<String, dynamic>,
            )
          : null,
      threadPoolProfile: json['threadPoolProfile'] != null
          ? ThreadPoolProfile.fromJson(
              json['threadPoolProfile'] as Map<String, dynamic>,
            )
          : null,
      errorHandlerFactory: json['errorHandlerFactory'] != null
          ? ErrorHandlerFactory.fromJson(
              json['errorHandlerFactory'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (properties != null) 'properties': properties,
      if (globalOptions != null) 'globalOptions': globalOptions!.toJson(),
      if (threadPoolProfile != null)
        'threadPoolProfile': threadPoolProfile!.toJson(),
      if (errorHandlerFactory != null)
        'errorHandlerFactory': errorHandlerFactory!.toJson(),
    };
  }
}
