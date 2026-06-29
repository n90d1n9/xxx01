package com.postfix.dto;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

public class Dtos {

    // ─── Auth ──────────────────────────────────────────────────────────────────
    public record LoginRequest(String username, String password) {}
    public record RefreshRequest(String refreshToken) {}
    public record TokenResponse(String token, String refreshToken,
            LocalDateTime expiresAt, String username, String role) {}
    public record ErrorResponse(String message) {}

    // ─── Server Status ─────────────────────────────────────────────────────────
    public record ServerStatusDto(
            boolean isRunning, LocalDateTime startedAt, String version, int pid,
            double cpuUsage, double memoryUsage, int connectionsActive,
            Map<String, Boolean> services) {}

    // ─── Stats ─────────────────────────────────────────────────────────────────
    public record PostfixStatsDto(
            int totalMessages, int deliveredMessages, int bouncedMessages,
            int deferredMessages, int rejectedMessages, int queueSize,
            double avgDeliveryTime, double deliveryRate,
            Map<String, Integer> hourlyVolume,
            List<TopSenderDto> topSenders,
            List<TopDomainDto> topDomains,
            List<DeliveryDataPointDto> deliveryTimeline) {}

    public record TopSenderDto(String email, int count) {}
    public record TopDomainDto(String domain, int count, String type) {}
    public record DeliveryDataPointDto(LocalDateTime time, int delivered, int deferred, int bounced) {}

    // ─── Queue ─────────────────────────────────────────────────────────────────
    public record MailQueueDto(
            String id, String sender, String recipient, String subject,
            long size, String status, LocalDateTime arrivedAt,
            int deliveryAttempts, String lastError,
            List<String> allRecipients, String nextDelivery) {}

    public record BatchDeleteRequest(List<String> ids) {}

    // ─── Logs ──────────────────────────────────────────────────────────────────
    public record MailLogDto(
            String id, LocalDateTime timestamp, String level, String process,
            String message, String queueId, String from, String to,
            String status, Integer delay, String host, String ip) {}

    // ─── Config ────────────────────────────────────────────────────────────────
    public record PostfixConfigDto(
            String key, String value, String description,
            String category, String defaultValue, boolean isModified) {}

    public record UpdateConfigRequest(String value) {}
    public record ImportConfigRequest(String content) {}

    // ─── Transport Maps ────────────────────────────────────────────────────────
    public record TransportMapDto(
            String pattern, String transport, String nexthop,
            boolean isActive, String comment) {}

    // ─── Access Control ────────────────────────────────────────────────────────
    public record AccessRuleDto(
            String pattern, String action, String listType, String matchType,
            String reason, LocalDateTime createdAt, LocalDateTime expiresAt,
            boolean isActive) {}

    public record ToggleRequest(boolean isActive) {}

    // ─── TLS Certificates ──────────────────────────────────────────────────────
    public record TlsCertificateDto(
            String domain, String issuer, String subject,
            LocalDateTime validFrom, LocalDateTime validUntil,
            String algorithm, int keyBits, String fingerprint, String status,
            String certPath, String keyPath, List<String> sans) {}

    public record CertUploadRequest(String certContent, String keyContent, String domain) {}
    public record TlsTestRequest(String domain) {}
    public record TlsTestResultDto(boolean connected, String protocol, String cipher,
            boolean certValid, String error) {}

    // ─── DNS Health ────────────────────────────────────────────────────────────
    public record DnsHealthDto(
            String spf, String dkim, String dmarc, String mx, String rdns,
            String spfRecord, String dmarcRecord, List<MxRecordDto> mxRecords,
            String rdnsResult, String dkimSelector) {}

    public record MxRecordDto(int priority, String hostname, String ip) {}

    // ─── Alerts ────────────────────────────────────────────────────────────────
    public record AlertDto(
            String id, String title, String message, String severity,
            LocalDateTime createdAt, boolean isRead,
            String actionLabel, String actionRoute) {}

    // ─── Backup ────────────────────────────────────────────────────────────────
    public record BackupEntryDto(
            String id, String filename, LocalDateTime createdAt,
            int sizeBytes, String type, List<String> includes) {}

    public record BackupRequest(List<String> includes) {}

    // ─── Virtual Domains ───────────────────────────────────────────────────────
    public record VirtualDomainDto(
            String domain, boolean isActive, int mailboxCount,
            int aliasCount, LocalDateTime createdAt) {}

    public record CreateDomainRequest(String domain) {}
    public record ToggleDomainRequest(boolean isActive) {}

    // ─── Virtual Mailboxes ─────────────────────────────────────────────────────
    public record VirtualMailboxDto(
            String email, String domain, String localPart,
            boolean isActive, int quotaMb, int usedMb,
            LocalDateTime createdAt, LocalDateTime lastLogin, String forwardTo) {}

    public record CreateMailboxRequest(String email, String password,
            int quotaMb, String forwardTo) {}
    public record UpdatePasswordRequest(String password) {}
    public record UpdateQuotaRequest(int quotaMb) {}
    public record ToggleMailboxRequest(boolean isActive) {}

    // ─── Aliases ───────────────────────────────────────────────────────────────
    public record MailAliasDto(String source, String destination,
            boolean isActive, String comment) {}
    public record CreateAliasRequest(String source, String destination, String comment) {}
    public record ToggleAliasRequest(boolean isActive) {}
}
