package com.postfix.resource;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import io.quarkus.scheduler.Scheduled;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.websocket.*;
import jakarta.websocket.server.ServerEndpoint;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.jboss.logging.Logger;

import java.io.*;
import java.nio.file.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.regex.*;

/**
 * WebSocket endpoint for real-time Postfix log streaming.
 *
 * Protocol:
 *   Client → Server:  { "action": "filter", "level": "ERROR", "search": "smtp" }
 *                     { "action": "pause" }
 *                     { "action": "resume" }
 *   Server → Client:  { "type": "log",     ...MailLogDto fields... }
 *                     { "type": "status",  "connected": true, "sessionId": "..." }
 *                     { "type": "error",   "message": "..." }
 *                     { "type": "stats",   "linesPerMin": 42, "errorRate": 3.2 }
 */
@ServerEndpoint("/api/logs/stream")
@ApplicationScoped
public class LogStreamWebSocket {

    private static final Logger LOG = Logger.getLogger(LogStreamWebSocket.class);
    private static final DateTimeFormatter LOG_DATE_FMT =
            DateTimeFormatter.ofPattern("MMM d HH:mm:ss");

    // Compiled regex patterns for Postfix log parsing
    private static final Pattern QUEUE_ID  = Pattern.compile("([A-F0-9]{9,12}):");
    private static final Pattern FROM_ADDR = Pattern.compile("from=<([^>]+)>");
    private static final Pattern TO_ADDR   = Pattern.compile("to=<([^>]+)>");
    private static final Pattern STATUS    = Pattern.compile("status=(\\w+)");
    private static final Pattern DELAY     = Pattern.compile("delay=([\\d.]+)");
    private static final Pattern HOST_IP   = Pattern.compile("from\\s+(\\S+)\\[(\\d+\\.\\d+\\.\\d+\\.\\d+)\\]");
    private static final Pattern REJECT    = Pattern.compile("reject:|NOQUEUE:");

    private final ObjectMapper mapper;
    private final Map<String, SessionState> sessions = new ConcurrentHashMap<>();

    @ConfigProperty(name = "postfix.log.file", defaultValue = "/var/log/mail.log")
    String logPath;

    private long lastFilePosition = 0;
    private int  linesThisMinute  = 0;
    private int  errorsThisMinute = 0;
    private long minuteStart      = System.currentTimeMillis();

    public LogStreamWebSocket() {
        mapper = new ObjectMapper();
        mapper.registerModule(new JavaTimeModule());
        mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
    }

    // ─── Session lifecycle ─────────────────────────────────────────────────────

    @OnOpen
    public void onOpen(Session session) {
        sessions.put(session.getId(), new SessionState(session));
        LOG.infof("Log stream connected: %s (total: %d)", session.getId(), sessions.size());
        sendJson(session, Map.of(
            "type",      "status",
            "connected", true,
            "sessionId", session.getId(),
            "message",   "Connected to log stream"
        ));
    }

    @OnClose
    public void onClose(Session session) {
        sessions.remove(session.getId());
        LOG.infof("Log stream disconnected: %s (total: %d)", session.getId(), sessions.size());
    }

    @OnError
    public void onError(Session session, Throwable t) {
        sessions.remove(session.getId());
        LOG.warnf("Log stream error %s: %s", session.getId(), t.getMessage());
    }

    @OnMessage
    public void onMessage(String message, Session session) {
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> cmd = mapper.readValue(message, Map.class);
            String action = (String) cmd.getOrDefault("action", "");
            SessionState state = sessions.get(session.getId());
            if (state == null) return;

            switch (action) {
                case "filter" -> {
                    state.levelFilter  = (String) cmd.get("level");
                    state.searchFilter = (String) cmd.get("search");
                    sendJson(session, Map.of("type", "status",
                        "message", "Filter applied"));
                }
                case "pause"  -> { state.paused = true;  sendJson(session, Map.of("type","status","message","Paused")); }
                case "resume" -> { state.paused = false; sendJson(session, Map.of("type","status","message","Resumed")); }
                case "ping"   ->   sendJson(session, Map.of("type", "pong", "ts", System.currentTimeMillis()));
            }
        } catch (Exception e) {
            LOG.debug("Bad WS message: " + e.getMessage());
        }
    }

    // ─── Scheduled tail ───────────────────────────────────────────────────────

    @Scheduled(every = "2s")
    public void tailLog() {
        if (sessions.isEmpty()) return;

        // Emit stats every minute
        long now = System.currentTimeMillis();
        if (now - minuteStart >= 60_000) {
            final int lpm = linesThisMinute;
            final int epm = errorsThisMinute;
            sessions.values().stream()
                .filter(s -> !s.paused && s.session.isOpen())
                .forEach(s -> sendJson(s.session, Map.of(
                    "type",        "stats",
                    "linesPerMin", lpm,
                    "errorsPerMin", epm,
                    "errorRate",   lpm > 0 ? (double) epm / lpm * 100 : 0.0
                )));
            linesThisMinute  = 0;
            errorsThisMinute = 0;
            minuteStart      = now;
        }

        Path path = Path.of(logPath);
        if (!Files.exists(path)) {
            // Emit synthetic demo logs when no real log file
            emitDemoLogs();
            return;
        }

        try {
            long fileSize = Files.size(path);
            if (fileSize < lastFilePosition) lastFilePosition = 0; // rotated
            if (fileSize <= lastFilePosition) return;

            List<Map<String, Object>> parsed = new ArrayList<>();
            try (RandomAccessFile raf = new RandomAccessFile(logPath, "r")) {
                raf.seek(lastFilePosition);
                String raw;
                while ((raw = raf.readLine()) != null) {
                    Map<String, Object> entry = parseLine(raw);
                    if (entry != null) parsed.add(entry);
                }
                lastFilePosition = raf.getFilePointer();
            }

            for (Map<String, Object> entry : parsed) {
                linesThisMinute++;
                if ("ERROR".equals(entry.get("level"))) errorsThisMinute++;

                for (SessionState ss : sessions.values()) {
                    if (!ss.paused && ss.session.isOpen() && matches(entry, ss)) {
                        sendJson(ss.session, entry);
                    }
                }
            }
        } catch (IOException e) {
            LOG.debug("Log tail error: " + e.getMessage());
        }
    }

    // ─── Parsing ──────────────────────────────────────────────────────────────

    private Map<String, Object> parseLine(String line) {
        if (line == null || line.isBlank()) return null;

        // Standard syslog: "Feb 25 14:23:01 hostname process[pid]: message"
        // We try to parse tokens; fallback gracefully
        try {
            String[] parts = line.split("\\s+", 6);
            if (parts.length < 5) return fallback(line);

            String monthDay = parts[0] + " " + parts[1] + " " + parts[2];
            String process  = parts[4].replaceAll("\\[\\d+\\]:", "").replace(":", "");
            String message  = parts.length > 5 ? parts[5] : "";

            String level = detectLevel(line, message);
            String queueId = extractFirst(QUEUE_ID,  message, 1);
            String from    = extractFirst(FROM_ADDR, message, 1);
            String to      = extractFirst(TO_ADDR,   message, 1);
            String status  = extractFirst(STATUS,    message, 1);
            String delayS  = extractFirst(DELAY,     message, 1);
            Matcher hm     = HOST_IP.matcher(message);
            String host    = hm.find() ? hm.group(1) : null;
            String ip      = hm.find() ? hm.group(2) : null;
            if (host == null) { Matcher hm2 = HOST_IP.matcher(message); if (hm2.find()) { host = hm2.group(1); ip = hm2.group(2); } }

            Map<String, Object> entry = new LinkedHashMap<>();
            entry.put("type",      "log");
            entry.put("id",        UUID.randomUUID().toString());
            entry.put("timestamp", LocalDateTime.now().toString());
            entry.put("level",     level);
            entry.put("process",   process);
            entry.put("message",   message);
            if (queueId != null) entry.put("queueId",  queueId);
            if (from    != null) entry.put("from",     from);
            if (to      != null) entry.put("to",       to);
            if (status  != null) entry.put("status",   status);
            if (delayS  != null) entry.put("delay",    (int) Double.parseDouble(delayS));
            if (host    != null) entry.put("host",     host);
            if (ip      != null) entry.put("ip",       ip);
            return entry;

        } catch (Exception e) {
            return fallback(line);
        }
    }

    private Map<String, Object> fallback(String line) {
        return Map.of(
            "type", "log", "id", UUID.randomUUID().toString(),
            "timestamp", LocalDateTime.now().toString(),
            "level", "INFO", "process", "postfix", "message", line);
    }

    private String detectLevel(String line, String msg) {
        if (line.contains("error") || line.contains("fatal") || REJECT.matcher(line).find()
                || line.contains("panic") || line.contains("fatal")) return "ERROR";
        if (line.contains("warning") || line.contains("warn") || line.contains("deferred")
                || line.contains("bounce")) return "WARN";
        return "INFO";
    }

    private String extractFirst(Pattern p, String s, int group) {
        Matcher m = p.matcher(s);
        return m.find() ? m.group(group) : null;
    }

    // ─── Filter matching ──────────────────────────────────────────────────────

    private boolean matches(Map<String, Object> entry, SessionState ss) {
        if (ss.levelFilter != null && !ss.levelFilter.isEmpty()) {
            String level = (String) entry.getOrDefault("level", "INFO");
            if (!ss.levelFilter.equalsIgnoreCase(level)) return false;
        }
        if (ss.searchFilter != null && !ss.searchFilter.isEmpty()) {
            String msg  = ((String) entry.getOrDefault("message", "")).toLowerCase();
            String proc = ((String) entry.getOrDefault("process", "")).toLowerCase();
            String from = ((String) entry.getOrDefault("from", "")).toLowerCase();
            String to   = ((String) entry.getOrDefault("to", "")).toLowerCase();
            String q    = ((String) entry.getOrDefault("queueId", "")).toLowerCase();
            String term = ss.searchFilter.toLowerCase();
            if (!msg.contains(term) && !proc.contains(term)
                    && !from.contains(term) && !to.contains(term) && !q.contains(term)) {
                return false;
            }
        }
        return true;
    }

    // ─── Demo log generator (when no real log file present) ──────────────────

    private static final String[] DEMO_PROCESSES = {
        "postfix/smtpd", "postfix/qmgr", "postfix/smtp",
        "postfix/cleanup", "postfix/local", "postfix/bounce"
    };
    private static final String[] DEMO_SENDERS = {
        "alice@gmail.com", "bob@company.org", "noreply@sendgrid.net",
        "info@example.com", "mailer@notifications.io"
    };
    private static final String[] DEMO_RECIPIENTS = {
        "admin@example.com", "user@example.com", "support@company.org",
        "postmaster@example.com", "info@company.org"
    };
    private static final String[] DEMO_HOSTS = {
        "mail.google.com[74.125.128.27]", "mail.sendgrid.net[167.89.0.1]",
        "smtp.mailgun.org[198.61.254.1]", "unknown[192.168.1.50]"
    };
    private final Random rng = new Random();

    private void emitDemoLogs() {
        // Emit 1-3 synthetic log lines per 2s tick to simulate real traffic
        int count = rng.nextInt(3) + 1;
        for (int i = 0; i < count; i++) {
            Map<String, Object> entry = generateDemoLine();
            for (SessionState ss : sessions.values()) {
                if (!ss.paused && ss.session.isOpen() && matches(entry, ss)) {
                    sendJson(ss.session, entry);
                }
            }
            linesThisMinute++;
            if ("ERROR".equals(entry.get("level"))) errorsThisMinute++;
        }
    }

    private Map<String, Object> generateDemoLine() {
        int roll   = rng.nextInt(10);
        String qid = String.format("%X", (long)(Math.random() * 0xFFFFFFFFFFL));
        String from = DEMO_SENDERS[rng.nextInt(DEMO_SENDERS.length)];
        String to   = DEMO_RECIPIENTS[rng.nextInt(DEMO_RECIPIENTS.length)];
        String host = DEMO_HOSTS[rng.nextInt(DEMO_HOSTS.length)];
        String proc = DEMO_PROCESSES[rng.nextInt(DEMO_PROCESSES.length)];

        String level, message;
        if (roll <= 5) {
            level = "INFO";
            message = switch (rng.nextInt(4)) {
                case 0 -> String.format("connect from %s", host);
                case 1 -> String.format("%s: from=<%s>, size=%d, nrcpt=1 (queue active)", qid, from, 1024 + rng.nextInt(50000));
                case 2 -> String.format("%s: to=<%s>, relay=localhost[127.0.0.1]:25, delay=%.1f, status=sent (250 2.0.0 OK)", qid, to, rng.nextDouble() * 3);
                default-> String.format("disconnect from %s ehlo=1 mail=1 rcpt=1 data=1 quit=1", host);
            };
        } else if (roll <= 7) {
            level = "WARN";
            message = String.format("%s: to=<%s>, relay=none, delay=%.0f, status=deferred (connect to %s: Connection refused)",
                    qid, to, 10 + rng.nextDouble() * 300, host.split("\\[")[0]);
        } else {
            level = "ERROR";
            message = rng.nextBoolean()
                ? String.format("NOQUEUE: reject: RCPT from %s: 554 5.7.1 Relay access denied; from=<%s> to=<%s>", host, from, to)
                : String.format("%s: to=<%s>, status=bounced (host %s said: 550 5.1.1 User unknown)", qid, to, host.split("\\[")[0]);
        }

        Map<String, Object> entry = new LinkedHashMap<>();
        entry.put("type",      "log");
        entry.put("id",        UUID.randomUUID().toString());
        entry.put("timestamp", LocalDateTime.now().toString());
        entry.put("level",     level);
        entry.put("process",   proc);
        entry.put("message",   message);
        entry.put("queueId",   qid);
        entry.put("from",      from);
        entry.put("to",        to);
        return entry;
    }

    // ─── Helpers ─────────────────────────────────────────────────────────────

    private void sendJson(Session session, Map<String, Object> payload) {
        try {
            String json = mapper.writeValueAsString(payload);
            session.getAsyncRemote().sendText(json);
        } catch (Exception e) {
            LOG.debug("WS send error: " + e.getMessage());
        }
    }

    // ─── Session state per client ─────────────────────────────────────────────

    static class SessionState {
        final Session session;
        volatile String  levelFilter  = null;
        volatile String  searchFilter = null;
        volatile boolean paused       = false;

        SessionState(Session session) { this.session = session; }
    }
}
