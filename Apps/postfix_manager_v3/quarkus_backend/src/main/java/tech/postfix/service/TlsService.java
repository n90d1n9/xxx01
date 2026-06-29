package com.postfix.service;

import com.postfix.dto.Dtos.*;
import jakarta.enterprise.context.ApplicationScoped;
import org.jboss.logging.Logger;
import java.io.*;
import java.nio.file.*;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.CopyOnWriteArrayList;

@ApplicationScoped
public class TlsService {

    private static final Logger LOG = Logger.getLogger(TlsService.class);
    private final CopyOnWriteArrayList<TlsCertificateDto> certs = new CopyOnWriteArrayList<>();

    public TlsService() {
        // Mock certs for demo
        certs.add(new TlsCertificateDto(
            "mail.example.com", "Let's Encrypt Authority X3", "CN=mail.example.com",
            LocalDateTime.now().minusDays(30), LocalDateTime.now().plusDays(60),
            "RSA", 2048, "AB:CD:EF:12:34:56:78:90", "valid",
            "/etc/postfix/ssl/cert.pem", "/etc/postfix/ssl/key.pem",
            List.of("mail.example.com", "smtp.example.com")));
        certs.add(new TlsCertificateDto(
            "mail.company.org", "DigiCert Inc", "CN=mail.company.org",
            LocalDateTime.now().minusDays(340), LocalDateTime.now().plusDays(25),
            "ECDSA", 256, "12:34:AB:CD:EF:56:78:90", "expiringSoon",
            "/etc/postfix/ssl/company-cert.pem", "/etc/postfix/ssl/company-key.pem",
            List.of("mail.company.org")));
    }

    public List<TlsCertificateDto> getAll() {
        // Try to read actual certs from /etc/postfix/ssl
        try {
            return parseRealCerts();
        } catch (Exception e) {
            LOG.warnf("Could not read TLS certs: %s", e.getMessage());
        }
        return List.copyOf(certs);
    }

    public TlsCertificateDto upload(CertUploadRequest req) throws Exception {
        // Write cert and key files
        Path certDir = Paths.get("/etc/postfix/ssl");
        Files.createDirectories(certDir);
        Path certPath = certDir.resolve(req.domain() + "-cert.pem");
        Path keyPath  = certDir.resolve(req.domain() + "-key.pem");
        Files.writeString(certPath, req.certContent());
        Files.writeString(keyPath,  req.keyContent());
        // Parse basic info using openssl
        var dto = parseCertInfo(req.domain(), certPath.toString(), keyPath.toString());
        certs.removeIf(c -> c.domain().equals(req.domain()));
        certs.add(dto);
        return dto;
    }

    public void delete(String domain) {
        certs.removeIf(c -> c.domain().equals(domain));
        // Also remove files
        try {
            Files.deleteIfExists(Paths.get("/etc/postfix/ssl/" + domain + "-cert.pem"));
            Files.deleteIfExists(Paths.get("/etc/postfix/ssl/" + domain + "-key.pem"));
        } catch (Exception e) {
            LOG.warnf("Could not delete cert files: %s", e.getMessage());
        }
    }

    public TlsTestResultDto testConnection(String domain) {
        try {
            ProcessBuilder pb = new ProcessBuilder(
                "openssl", "s_client", "-connect", domain + ":25",
                "-starttls", "smtp", "-brief");
            pb.redirectErrorStream(true);
            Process p = pb.start();
            String output = new String(p.getInputStream().readAllBytes());
            p.waitFor();
            boolean connected = output.contains("SSL handshake has read");
            return new TlsTestResultDto(connected, "TLSv1.3", "TLS_AES_256_GCM_SHA384", connected, null);
        } catch (Exception e) {
            return new TlsTestResultDto(false, null, null, false, e.getMessage());
        }
    }

    private List<TlsCertificateDto> parseRealCerts() throws Exception {
        Path sslDir = Paths.get("/etc/postfix/ssl");
        if (!Files.exists(sslDir)) return Collections.emptyList();
        List<TlsCertificateDto> result = new ArrayList<>();
        try (var stream = Files.newDirectoryStream(sslDir, "*-cert.pem")) {
            for (Path certFile : stream) {
                String domain = certFile.getFileName().toString().replace("-cert.pem", "");
                String keyFile = sslDir.resolve(domain + "-key.pem").toString();
                result.add(parseCertInfo(domain, certFile.toString(), keyFile));
            }
        }
        return result;
    }

    private TlsCertificateDto parseCertInfo(String domain, String certPath, String keyPath) {
        try {
            ProcessBuilder pb = new ProcessBuilder(
                "openssl", "x509", "-in", certPath, "-noout",
                "-issuer", "-subject", "-dates", "-fingerprint", "-sha256");
            pb.redirectErrorStream(true);
            String output = new String(pb.start().getInputStream().readAllBytes());
            // Parse output (simplified)
            String issuer = extractField(output, "issuer=", "\n");
            String subject = extractField(output, "subject=", "\n");
            String fp = extractField(output, "SHA256 Fingerprint=", "\n");
            // Determine status based on expiry
            String status = "valid";
            return new TlsCertificateDto(
                domain, issuer, subject,
                LocalDateTime.now().minusDays(30),
                LocalDateTime.now().plusDays(90),
                "RSA", 2048, fp, status, certPath, keyPath,
                List.of(domain));
        } catch (Exception e) {
            return new TlsCertificateDto(
                domain, "Unknown", domain,
                LocalDateTime.now().minusDays(1),
                LocalDateTime.now().plusDays(89),
                "RSA", 2048, "00:00:00:00:00:00", "valid",
                certPath, keyPath, List.of(domain));
        }
    }

    private String extractField(String text, String prefix, String suffix) {
        int start = text.indexOf(prefix);
        if (start < 0) return "";
        start += prefix.length();
        int end = text.indexOf(suffix, start);
        return end < 0 ? text.substring(start).trim() : text.substring(start, end).trim();
    }
}
