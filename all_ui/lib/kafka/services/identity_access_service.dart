class IdentityAccessService {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // OpenID Connect Configuration
  static const _issuer = 'https://keycloak.yourcompany.com/auth/realms/kafka-realm';
  static const _clientId = 'kafka-management-app';
  static const _redirectUri = 'com.yourcompany.kafkamanagement:/oauth2redirect';
  static const _discoveryUrl = '$_issuer/.well-known/openid-configuration';

  // Permissions Model
  class UserPermissions {
    final String userId;
    final List<String> roles;
    final Map<String, dynamic> attributes;

    UserPermissions({
      required this.userId,
      required this.roles,
      this.attributes = const {},
    });

    // Granular Permission Checks
    bool hasClusterAccess(String clusterId) {
      return roles.contains('cluster_admin') || 
             attributes['allowed_clusters']?.contains(clusterId) == true;
    }

    bool canCreateTopic(String clusterId) {
      return roles.contains('topic_creator') || 
             hasClusterAccess(clusterId);
    }

    bool canConsumeTopics(List<String> topics) {
      return roles.contains('topic_consumer') || 
             topics.every((topic) => 
               attributes['allowed_topics']?.contains(topic) == true
             );
    }
  }