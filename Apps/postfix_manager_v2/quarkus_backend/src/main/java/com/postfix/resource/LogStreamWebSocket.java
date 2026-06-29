package com.postfix.resource;

import io.quarkus.scheduler.Scheduled;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.websocket.*;
import jakarta.websocket.server.ServerEndpoint;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.jboss.logging.Logger;

import java.io.*;
import java.nio.file.*;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

/**
 * WebSocket endpoint for real-time log tailing.
 * Flutter app can connect to ws://localhost:8080/api/logs/stream
 */
@ServerEndpoint("/api/logs/stream")
@ApplicationScoped
public class LogStreamWebSocket {

    private static final Logger LOG = Logger.getLogger(LogStreamWebSocket.class);

    private final Map<String, Session> sessions = new ConcurrentHashMap<>();

    @ConfigProperty(name = "postfix.log.path", defaultValue = "/var/log/mail.log")
    String logPath;

    private long lastFilePosition = 0;

    @OnOpen
    public void onOpen(Session session) {
        sessions.put(session.getId(), session);
        LOG.infof("Log stream client connected: %s", session.getId());
    }

    @OnClose
    public void onClose(Session session) {
        sessions.remove(session.getId());
        LOG.infof("Log stream client disconnected: %s", session.getId());
    }

    @OnError
    public void onError(Session session, Throwable throwable) {
        sessions.remove(session.getId());
        LOG.warnf("Log stream error for %s: %s", session.getId(), throwable.getMessage());
    }

    /**
     * Poll for new log lines every 2 seconds and broadcast to all connected clients.
     */
    @Scheduled(every = "2s")
    public void tailLog() {
        if (sessions.isEmpty()) return;

        try {
            var path = Path.of(logPath);
            if (!Files.exists(path)) return;

            long fileSize = Files.size(path);
            if (fileSize < lastFilePosition) {
                // Log rotated
                lastFilePosition = 0;
            }

            if (fileSize <= lastFilePosition) return;

            try (var raf = new RandomAccessFile(logPath, "r")) {
                raf.seek(lastFilePosition);
                String line;
                while ((line = raf.readLine()) != null) {
                    final String logLine = line;
                    sessions.values().forEach(session -> {
                        try {
                            session.getAsyncRemote().sendText(logLine);
                        } catch (Exception e) {
                            // Ignore send errors
                        }
                    });
                }
                lastFilePosition = raf.getFilePointer();
            }
        } catch (IOException e) {
            LOG.debug("Log tail error: " + e.getMessage());
        }
    }
}
