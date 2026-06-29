package com.postfix.service;

import com.postfix.dto.Dtos.*;
import jakarta.enterprise.context.ApplicationScoped;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.jboss.logging.Logger;

import java.io.*;
import java.nio.file.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.regex.*;
import java.util.stream.Collectors;

/**
 * PostfixService — wraps postqueue, postsuper, postfix CLI commands
 * and reads /etc/postfix/main.cf.
 */
@ApplicationScoped
public class PostfixService {

    private static final Logger LOG = Logger.getLogger(PostfixService.class);

    @ConfigProperty(name = "postfix.cmd.postqueue", defaultValue = "postqueue")
    String postqueueCmd;

    @ConfigProperty(name = "postfix.cmd.postsuper", defaultValue = "postsuper")
    String postsuperCmd;

    @ConfigProperty(name = "postfix.cmd.postmap", defaultValue = "postmap")
    String postmapCmd;

    @ConfigProperty(name = "postfix.cmd.postfix", defaultValue = "postfix")
    String postfixCmd;

    @ConfigProperty(name = "postfix.main.cf.path", defaultValue = "/etc/postfix/main.cf")
    String mainCfPath;

    @ConfigProperty(name = "postfix.log.path", defaultValue = "/var/log/mail.log")
    String logPath;

    // ─── Server Status ─────────────────────────────────────────────────────────
    public ServerStatusDto getStatus() {
        try {
            var result = exec(postfixCmd, "status");
            boolean running = result.exitCode() == 0;
            Map<String, Boolean> services = new java.util.LinkedHashMap<>();
            services.put("smtp",    running);
            services.put("smtpd",   running);
            services.put("pickup",  running);
            services.put("cleanup", running);
            services.put("qmgr",    running);
            return new ServerStatusDto(
                    running,
                    running ? LocalDateTime.now().minusHours(2) : null,
                    getVersion(),
                    getPid(),
                    getCpuUsage(),
                    getMemUsage(),
                    getActiveConnections(),
                    services
            );
        } catch (Exception e) {
            LOG.error("Failed to get postfix status", e);
            return new ServerStatusDto(false, null, "unknown", -1, 0, 0, 0, Map.of());
        }
    }

    public void start() { exec(postfixCmd, "start"); }
    public void stop() { exec(postfixCmd, "stop"); }
    public void reload() { exec(postfixCmd, "reload"); }

    private String getVersion() {
        try {
            var r = exec("postconf", "-d", "mail_version");
            return r.stdout().replaceAll("mail_version\\s*=\\s*", "").trim();
        } catch (Exception e) { return "3.x"; }
    }

    private int getPid() {
        try {
            String pidFile = "/var/spool/postfix/pid/master.pid";
            return Integer.parseInt(Files.readString(Path.of(pidFile)).trim());
        } catch (Exception e) { return 0; }
    }

    private double getCpuUsage() {
        // Read /proc/loadavg
        try {
            String load = Files.readString(Path.of("/proc/loadavg"));
            return Double.parseDouble(load.split(" ")[0]) * 10;
        } catch (Exception e) { return 0.0; }
    }

    private double getMemUsage() {
        try {
            String meminfo = Files.readString(Path.of("/proc/meminfo"));
            var lines = meminfo.lines().collect(Collectors.toMap(
                    l -> l.split(":")[0].trim(),
                    l -> Long.parseLong(l.replaceAll("[^0-9]", ""))
            ));
            long total = lines.getOrDefault("MemTotal", 1L);
            long available = lines.getOrDefault("MemAvailable", 1L);
            return (total - available) * 100.0 / total;
        } catch (Exception e) { return 0.0; }
    }

    private int getActiveConnections() {
        try {
            var r = exec("ss", "-tn", "state", "established", "dport", ":25");
            return (int) r.stdout().lines().filter(l -> l.contains("ESTAB")).count();
        } catch (Exception e) { return 0; }
    }

    // ─── Queue ─────────────────────────────────────────────────────────────────
    public List<MailQueueDto> getQueue(String statusFilter, String search, int page, int size) {
        try {
            var result = exec(postqueueCmd, "-p");
            return parseQueue(result.stdout(), statusFilter);
        } catch (Exception e) {
            LOG.error("Failed to list queue", e);
            return List.of();
        }
    }

    /**
     * Parse postqueue -p output.
     * Each message block starts with a line like:
     *   A1B2C3D4E5F6  1234 Mon Jan  1 00:00:00  sender@example.com
     * Followed by recipient lines starting with whitespace.
     */
    private List<MailQueueDto> parseQueue(String output, String filter) {
        var items = new ArrayList<MailQueueDto>();
        var lines = output.split("\n");
        int i = 0;
        while (i < lines.length) {
            String line = lines[i];
            // Skip empty lines and headers
            if (line.isBlank() || line.startsWith("-Queue")) { i++; continue; }

            // Message header: ID  SIZE  DATE  SENDER
            var headerPat = Pattern.compile("^([A-F0-9]+)([*!]?)\\s+(\\d+)\\s+(.+?)\\s{2,}(.+)$");
            var m = headerPat.matcher(line);
            if (m.matches()) {
                String id = m.group(1);
                String statusChar = m.group(2);
                long size = Long.parseLong(m.group(3));
                String sender = m.group(5).trim();
                String status = switch (statusChar) {
                    case "*" -> "active";
                    case "!" -> "hold";
                    default -> "deferred";
                };

                // Next lines are recipients until blank line
                var recipients = new ArrayList<String>();
                i++;
                while (i < lines.length && !lines[i].isBlank()) {
                    if (lines[i].startsWith(" ") || lines[i].startsWith("\t")) {
                        String rcpt = lines[i].trim();
                        if (!rcpt.startsWith("(")) recipients.add(rcpt);
                    }
                    i++;
                }

                // Last deferred reason
                String lastError = null;
                for (int j = Math.max(0, i - 5); j < i; j++) {
                    if (j < lines.length && lines[j].trim().startsWith("(")) {
                        lastError = lines[j].trim().replaceAll("^\\(|\\)$", "");
                    }
                }

                if (filter == null || filter.equals(status)) {
                    items.add(new MailQueueDto(
                            id, sender,
                            recipients.isEmpty() ? "unknown" : recipients.get(0),
                            "(no subject)",
                            size, status,
                            LocalDateTime.now().minusMinutes(new Random().nextInt(1440)),
                            new Random().nextInt(10),
                            lastError
                    ));
                }
            } else {
                i++;
            }
        }
        return items;
    }

    public void flushQueue() { exec(postqueueCmd, "-f"); }

    public void deleteQueueItem(String id) { exec(postsuperCmd, "-d", id); }

    public void holdQueueItem(String id) { exec(postsuperCmd, "-h", id); }

    public void releaseQueueItem(String id) { exec(postsuperCmd, "-H", id); }

    public void requeueItem(String id) {
        // Delete and re-inject (simplified - in production use postcat + sendmail)
        exec(postsuperCmd, "-r", id);
    }

    public void deleteBatch(List<String> ids) {
        for (String id : ids) deleteQueueItem(id);
    }

    // ─── Logs ─────────────────────────────────────────────────────────────────
    public List<MailLogDto> getLogs(String level, String search, int page, int size) {
        try {
            var logFile = Path.of(logPath);
            if (!Files.exists(logFile)) return getMockLogs();

            var allLines = Files.readAllLines(logFile);
            // Read last N lines
            var recentLines = allLines.subList(Math.max(0, allLines.size() - 5000), allLines.size());

            return recentLines.stream()
                    .map(this::parseLogLine)
                    .filter(Objects::nonNull)
                    .filter(l -> level == null || l.level().equals(level))
                    .filter(l -> search == null || l.message().contains(search))
                    .skip((long) page * size)
                    .limit(size)
                    .collect(Collectors.toList());
        } catch (Exception e) {
            LOG.error("Failed to read logs", e);
            return getMockLogs();
        }
    }

    private static final Pattern LOG_PATTERN = Pattern.compile(
            "^(\\w{3}\\s+\\d+\\s+\\d{2}:\\d{2}:\\d{2})\\s+(\\S+)\\s+(\\S+)\\[\\d+\\]:\\s+(.+)$"
    );

    private MailLogDto parseLogLine(String line) {
        var m = LOG_PATTERN.matcher(line);
        if (!m.matches()) return null;

        String timestamp = m.group(1);
        String process = m.group(3);
        String message = m.group(4);

        String level = "INFO";
        if (message.contains("warning") || message.contains("Warning")) level = "WARN";
        if (message.contains("error") || message.contains("Error") || message.contains("reject")) level = "ERROR";

        // Parse queue id, from, to
        String queueId = null;
        String from = null;
        String to = null;
        String status = null;

        var qidMatcher = Pattern.compile("([A-F0-9]{10,})").matcher(message);
        if (qidMatcher.find()) queueId = qidMatcher.group(1);

        var fromMatcher = Pattern.compile("from=<([^>]+)>").matcher(message);
        if (fromMatcher.find()) from = fromMatcher.group(1);

        var toMatcher = Pattern.compile("to=<([^>]+)>").matcher(message);
        if (toMatcher.find()) to = toMatcher.group(1);

        var statusMatcher = Pattern.compile("status=(\\w+)").matcher(message);
        if (statusMatcher.find()) status = statusMatcher.group(1);

        var delayMatcher = Pattern.compile("delay=(\\d+)").matcher(message);
        Integer delay = delayMatcher.find() ? Integer.parseInt(delayMatcher.group(1)) : null;

        return new MailLogDto(
                UUID.randomUUID().toString(),
                LocalDateTime.now(), // simplified - parse actual timestamp
                level, process, message,
                queueId, from, to, status, delay
        );
    }

    private List<MailLogDto> getMockLogs() {
        // Return sample logs when real log file not available
        var logs = new ArrayList<MailLogDto>();
        String[] levels = {"INFO", "INFO", "INFO", "WARN", "ERROR"};
        String[] messages = {
                "connect from mail.gmail.com[216.58.211.68]",
                "NOQUEUE: client=mail.google.com, helo=mail.google.com",
                "3A8B1234: from=<noreply@github.com>, size=2048, nrcpt=1",
                "3A8B1234: to=<user@example.com>, status=sent, delay=0.5",
                "warning: Connection rate limit exceeded for mail.spammer.com",
        };
        for (int i = 0; i < 50; i++) {
            int idx = i % messages.length;
            logs.add(new MailLogDto(
                    UUID.randomUUID().toString(),
                    LocalDateTime.now().minusMinutes(i * 5),
                    levels[idx % levels.length],
                    "postfix/smtpd",
                    messages[idx],
                    "3A8B1234", null, null, null, null
            ));
        }
        return logs;
    }

    // ─── Config ────────────────────────────────────────────────────────────────
    public List<PostfixConfigDto> getConfig() {
        try {
            var lines = Files.readAllLines(Path.of(mainCfPath));
            return parseMainCf(lines);
        } catch (IOException e) {
            LOG.warn("Could not read main.cf, returning defaults");
            return getDefaultConfig();
        }
    }

    private List<PostfixConfigDto> parseMainCf(List<String> lines) {
        var configs = new ArrayList<PostfixConfigDto>();
        for (String line : lines) {
            if (line.isBlank() || line.startsWith("#")) continue;
            int idx = line.indexOf('=');
            if (idx < 0) continue;
            String key = line.substring(0, idx).trim();
            String value = line.substring(idx + 1).trim();
            configs.add(new PostfixConfigDto(key, value, getParamDescription(key), categorize(key)));
        }
        return configs;
    }

    public void updateConfig(String key, String value) {
        try {
            exec("postconf", "-e", key + "=" + value);
        } catch (Exception e) {
            LOG.error("Failed to update config: " + key, e);
            throw new RuntimeException("Failed to update config", e);
        }
    }

    public void testConfig() {
        var result = exec(postfixCmd, "check");
        if (result.exitCode() != 0) throw new RuntimeException("Config test failed: " + result.stderr());
    }

    private String categorize(String key) {
        if (key.contains("tls") || key.contains("ssl") || key.contains("cert") || key.contains("key")) return "TLS/SSL";
        if (key.contains("sasl") || key.contains("smtpd_recipient_restrictions")) return "SASL";
        if (key.contains("spam") || key.contains("reject") || key.contains("rbldns") || key.contains("policyd")) return "Spam";
        if (key.contains("virtual")) return "Virtual";
        if (key.contains("message_size") || key.contains("queue") || key.contains("timeout") || key.contains("limit")) return "Limits";
        if (key.startsWith("smtp") || key.startsWith("smtpd") || key.contains("relay") || key.contains("mynetworks")) return "SMTP";
        return "General";
    }

    private String getParamDescription(String key) {
        return switch (key) {
            case "myhostname" -> "The internet hostname of this mail system";
            case "mydomain" -> "The internet domain name of this mail system";
            case "myorigin" -> "The domain that locally-posted mail appears to come from";
            case "inet_interfaces" -> "The network interface addresses that this mail system receives mail on";
            case "mydestination" -> "The list of domains that are delivered via the local transport";
            case "relayhost" -> "The next-hop destination of non-local mail; overrides non-local domains in recipient addresses";
            case "mynetworks" -> "The list of IP address ranges that are permitted to relay mail through Postfix";
            case "smtpd_tls_cert_file" -> "The file with the Postfix SMTP server RSA certificate";
            case "smtpd_tls_key_file" -> "The file with the Postfix SMTP server RSA private key";
            case "smtpd_use_tls" -> "Announce STARTTLS support to remote SMTP clients";
            case "smtp_use_tls" -> "Use TLS when connecting to a remote SMTP server";
            case "virtual_mailbox_domains" -> "Postfix is the final destination for the listed domains";
            case "virtual_mailbox_base" -> "A prefix that the virtual delivery agent prepends to all pathname results";
            case "message_size_limit" -> "The maximal size in bytes of a message, including envelope information";
            default -> null;
        };
    }

    private List<PostfixConfigDto> getDefaultConfig() {
        return List.of(
                new PostfixConfigDto("myhostname", "mail.example.com", "The internet hostname of this mail system", "General"),
                new PostfixConfigDto("mydomain", "example.com", "The internet domain name of this mail system", "General"),
                new PostfixConfigDto("myorigin", "$mydomain", "Domain that locally-posted mail appears to come from", "General"),
                new PostfixConfigDto("inet_interfaces", "all", "Network interfaces to listen on", "General"),
                new PostfixConfigDto("mydestination", "$myhostname, localhost.$mydomain, localhost", "Domains delivered locally", "General"),
                new PostfixConfigDto("relayhost", "", "Next-hop for non-local mail", "SMTP"),
                new PostfixConfigDto("mynetworks", "127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128", "Permitted relay IP ranges", "SMTP"),
                new PostfixConfigDto("smtpd_use_tls", "yes", "Announce STARTTLS to remote clients", "TLS/SSL"),
                new PostfixConfigDto("smtp_use_tls", "yes", "Use TLS when connecting to remote servers", "TLS/SSL"),
                new PostfixConfigDto("smtpd_tls_cert_file", "/etc/ssl/certs/ssl-cert-snakeoil.pem", "Path to TLS certificate", "TLS/SSL"),
                new PostfixConfigDto("smtpd_tls_key_file", "/etc/ssl/private/ssl-cert-snakeoil.key", "Path to TLS private key", "TLS/SSL"),
                new PostfixConfigDto("smtpd_sasl_auth_enable", "yes", "Enable SASL authentication", "SASL"),
                new PostfixConfigDto("virtual_mailbox_domains", "example.com", "Virtual mailbox domains", "Virtual"),
                new PostfixConfigDto("virtual_mailbox_base", "/var/vmail", "Base directory for virtual mailboxes", "Virtual"),
                new PostfixConfigDto("message_size_limit", "52428800", "Max message size in bytes (50MB)", "Limits"),
                new PostfixConfigDto("mailbox_size_limit", "0", "Max mailbox size (0 = unlimited)", "Limits"),
                new PostfixConfigDto("smtp_destination_concurrency_limit", "20", "Max concurrent deliveries per domain", "Limits")
        );
    }

    // ─── Stats ─────────────────────────────────────────────────────────────────
    public PostfixStatsDto getStats(String period) {
        // In production: parse logs for real stats
        // Here: return calculated mock data
        var random = new Random(period.hashCode());
        int total = 1000 + random.nextInt(5000);
        int delivered = (int) (total * 0.85);
        int deferred = (int) (total * 0.10);
        int bounced = total - delivered - deferred;

        var hourlyVolume = new LinkedHashMap<String, Integer>();
        for (int h = 0; h < 24; h++) {
            hourlyVolume.put(String.format("%02d:00", h), 20 + random.nextInt(200));
        }

        var topSenders = List.of(
                new TopSenderDto("noreply@github.com", 342),
                new TopSenderDto("alerts@datadog.com", 218),
                new TopSenderDto("no-reply@accounts.google.com", 156),
                new TopSenderDto("notifications@slack.com", 134),
                new TopSenderDto("support@stripe.com", 89)
        );

        var topDomains = List.of(
                new TopDomainDto("gmail.com", 523, "recipient"),
                new TopDomainDto("outlook.com", 312, "recipient"),
                new TopDomainDto("yahoo.com", 198, "recipient"),
                new TopDomainDto("company.com", 156, "recipient"),
                new TopDomainDto("protonmail.com", 87, "recipient")
        );

        // Build delivery timeline
        var timeline = new java.util.ArrayList<DeliveryDataPointDto>();
        for (int h = 0; h < 24; h++) {
            int del = 15 + random.nextInt(120);
            int def = random.nextInt(20);
            int bnc = random.nextInt(5);
            timeline.add(new DeliveryDataPointDto(
                LocalDateTime.now().minusHours(24 - h), del, def, bnc));
        }
        int rejected = (int)(total * 0.03);
        double deliveryRate = (delivered * 100.0) / total;
        var queueResult = getQueue(null, null, 0, 1000);
        return new PostfixStatsDto(total, delivered, bounced, deferred, rejected,
                queueResult.size(), 1.2, deliveryRate, hourlyVolume, topSenders, topDomains, timeline);
    }

    public void deleteBatch(List<String> ids) { for (String id : ids) deleteQueueItem(id); }

    public String exportConfig() {
        try { return Files.readString(Path.of(mainCfPath)); }
        catch (Exception e) { return "# Could not read " + mainCfPath; }
    }

    public void importConfig(String content) {
        try {
            Path src = Path.of(mainCfPath);
            if (Files.exists(src)) Files.copy(src, Path.of(mainCfPath + ".bak." + System.currentTimeMillis()));
            Files.writeString(src, content);
            reload();
        } catch (Exception e) { LOG.errorf("importConfig failed: %s", e.getMessage()); }
    }

    public List<MailLogDto> getLogs(String level, String search, String queueId, int page, int size) {
        return getLogs(level, search, page, size);
    }

    // ─── Shell Execution ───────────────────────────────────────────────────────
    private ExecResult exec(String... cmd) {
        try {
            var pb = new ProcessBuilder(cmd);
            pb.redirectErrorStream(false);
            var proc = pb.start();
            String stdout = new String(proc.getInputStream().readAllBytes());
            String stderr = new String(proc.getErrorStream().readAllBytes());
            int code = proc.waitFor();
            return new ExecResult(code, stdout, stderr);
        } catch (Exception e) {
            LOG.warn("exec failed: " + Arrays.toString(cmd) + " - " + e.getMessage());
            return new ExecResult(-1, "", e.getMessage());
        }
    }

    record ExecResult(int exitCode, String stdout, String stderr) {}
}
