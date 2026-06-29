class MCPSecurityConfig {
  final bool enableTLS;
  final String? tlsVersion;
  final List<String> supportedCiphers;
  final bool requireClientCert;
  final String? certPath;
  final String? keyPath;
  final String? caPath;
  final bool verifyHostname;
  final Duration certExpiry;

  MCPSecurityConfig({
    this.enableTLS = true,
    this.tlsVersion = 'TLS1.3',
    this.supportedCiphers = const [],
    this.requireClientCert = false,
    this.certPath,
    this.keyPath,
    this.caPath,
    this.verifyHostname = true,
    this.certExpiry = const Duration(days: 365),
  });
}
/* 

class MCPSecurityConfig {
  final bool enableTLS;
  final String? tlsVersion;
  final List<String> supportedCiphers;
  final bool requireClientCert;
  final String? certPath;
  final String? keyPath;
  final String? caPath;
  final bool verifyHostname;
  final Duration certExpiry;

  MCPSecurityConfig({
    this.enableTLS = true,
    this.tlsVersion = 'TLS1.3',
    this.supportedCiphers = const [],
    this.requireClientCert = false,
    this.certPath,
    this.keyPath,
    this.caPath,
    this.verifyHostname = true,
    this.certExpiry = const Duration(days: 365),
  });
}
 */