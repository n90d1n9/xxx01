package com.postfix.service;

import com.postfix.dto.Dtos.*;
import jakarta.enterprise.context.ApplicationScoped;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.jboss.logging.Logger;
import java.io.*;
import java.nio.file.*;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@ApplicationScoped
public class TransportService {

    private static final Logger LOG = Logger.getLogger(TransportService.class);

    @ConfigProperty(name = "postfix.transport.file", defaultValue = "/etc/postfix/transport")
    String transportFile;

    // In-memory store (syncs to file)
    private final List<TransportMapDto> rules = new ArrayList<>();

    public TransportService() {
        // Seed with mock data for demo
        rules.add(new TransportMapDto(".", "smtp", "", true, "Default route"));
        rules.add(new TransportMapDto("localhost", "local", "", true, "Local delivery"));
        rules.add(new TransportMapDto("example.internal", "relay", "[mailrelay.internal]:25", true, "Internal relay"));
    }

    public List<TransportMapDto> getAll() {
        // Try to parse real transport file if available
        try {
            List<TransportMapDto> parsed = parseTransportFile();
            if (!parsed.isEmpty()) return parsed;
        } catch (Exception e) {
            LOG.warnf("Could not read transport file: %s", e.getMessage());
        }
        return Collections.unmodifiableList(rules);
    }

    public TransportMapDto create(TransportMapDto dto) {
        rules.removeIf(r -> r.pattern().equals(dto.pattern()));
        rules.add(dto);
        writeTransportFile();
        return dto;
    }

    public void update(String pattern, TransportMapDto dto) {
        rules.removeIf(r -> r.pattern().equals(pattern));
        rules.add(dto);
        writeTransportFile();
    }

    public void delete(String pattern) {
        rules.removeIf(r -> r.pattern().equals(pattern));
        writeTransportFile();
    }

    public void reload() {
        try {
            executeCommand("postmap " + transportFile);
            executeCommand("postfix reload");
        } catch (Exception e) {
            LOG.warnf("Could not reload transport maps: %s", e.getMessage());
        }
    }

    private List<TransportMapDto> parseTransportFile() throws IOException {
        Path path = Paths.get(transportFile);
        if (!Files.exists(path)) return Collections.emptyList();
        List<TransportMapDto> result = new ArrayList<>();
        for (String line : Files.readAllLines(path)) {
            line = line.trim();
            if (line.isEmpty() || line.startsWith("#")) continue;
            String[] parts = line.split("\\s+", 2);
            if (parts.length < 2) continue;
            String transport = parts[1].trim();
            String nexthop = "";
            if (transport.contains(":")) {
                int idx = transport.indexOf(':');
                nexthop = transport.substring(idx + 1);
                transport = transport.substring(0, idx);
            }
            result.add(new TransportMapDto(parts[0], transport, nexthop, true, null));
        }
        return result;
    }

    private void writeTransportFile() {
        try {
            StringBuilder sb = new StringBuilder("# Postfix transport map - managed by PostfixMgr\n");
            for (TransportMapDto r : rules) {
                if (!r.isActive()) continue;
                String transport = r.transport();
                if (r.nexthop() != null && !r.nexthop().isEmpty()) {
                    transport += ":" + r.nexthop();
                }
                sb.append(String.format("%-30s %s\n", r.pattern(), transport));
            }
            Files.writeString(Paths.get(transportFile), sb.toString());
        } catch (Exception e) {
            LOG.warnf("Could not write transport file: %s", e.getMessage());
        }
    }

    private void executeCommand(String cmd) throws Exception {
        ProcessBuilder pb = new ProcessBuilder("sh", "-c", cmd);
        pb.redirectErrorStream(true);
        Process p = pb.start();
        p.waitFor();
    }
}
