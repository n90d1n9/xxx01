import 'dart:io';

class SSLConfig {
  final X509Certificate? clientCertificate;
  final X509Certificate? caCertificate;
  final bool verifyHostname;
  final List<String> enabledProtocols;

  SSLConfig({
    this.clientCertificate,
    this.caCertificate,
    this.verifyHostname = true,
    this.enabledProtocols = const ['TLSv1.2', 'TLSv1.3'],
  });

  // Generate self-signed certificate for mutual TLS
  static Future<X509Certificate> generateSelfSignedCertificate(
    String commonName,
    KeyPair keyPair,
  ) async {
    final now = DateTime.now();
    final validity = ValidityPeriod(
      notBefore: now,
      notAfter: now.add(Duration(days: 365)),
    );

    final x509Builder =
        X509CertificateBuilder()
          ..subject = X509Name.fromString('CN=$commonName')
          ..issuer = X509Name.fromString('CN=$commonName')
          ..validity = validity
          ..publicKey = keyPair.publicKey
          ..serialNumber = BigInt.from(DateTime.now().millisecondsSinceEpoch);

    return x509Builder.build(keyPair.privateKey);
  }
}
