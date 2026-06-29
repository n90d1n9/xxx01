    public record TlsCertificateDto(
            String domain, String issuer, String subject,
            LocalDateTime validFrom, LocalDateTime validUntil,
            String algorithm, int keyBits, String fingerprint, String status,
            String certPath, String keyPath, List<String> sans) {}
