package com.postfix.service;

import com.postfix.dto.Dtos.*;
import jakarta.enterprise.context.ApplicationScoped;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.jboss.logging.Logger;
import java.nio.file.*;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.CopyOnWriteArrayList;

@ApplicationScoped
public class AccessService {

    private static final Logger LOG = Logger.getLogger(AccessService.class);

    @ConfigProperty(name = "postfix.access.file", defaultValue = "/etc/postfix/access")
    String accessFile;

    private final CopyOnWriteArrayList<AccessRuleDto> rules = new CopyOnWriteArrayList<>();

    public AccessService() {
        // Seed mock data
        rules.add(new AccessRuleDto("192.168.1.0/24", "PERMIT", "whitelist", "network",
                "Office network", LocalDateTime.now().minusDays(30), null, true));
        rules.add(new AccessRuleDto("10.0.0.0/8", "PERMIT", "whitelist", "network",
                "Internal VPN", LocalDateTime.now().minusDays(20), null, true));
        rules.add(new AccessRuleDto("spam.example.com", "REJECT", "blacklist", "domain",
                "Known spam domain", LocalDateTime.now().minusDays(5), null, true));
        rules.add(new AccessRuleDto("45.89.12.0/24", "REJECT", "blacklist", "network",
                "Botnet IP range", LocalDateTime.now().minusDays(2), null, true));
        rules.add(new AccessRuleDto("spammer@badmail.net", "DISCARD", "blacklist", "email",
                "Serial spammer", LocalDateTime.now().minusDays(1), null, true));
    }

    public List<AccessRuleDto> getAll(String listType) {
        if (listType == null || listType.isBlank()) return List.copyOf(rules);
        return rules.stream().filter(r -> r.listType().equals(listType)).toList();
    }

    public AccessRuleDto create(AccessRuleDto dto) {
        rules.removeIf(r -> r.pattern().equals(dto.pattern()));
        rules.add(dto);
        writeAccessFile();
        return dto;
    }

    public void delete(String pattern) {
        rules.removeIf(r -> r.pattern().equals(pattern));
        writeAccessFile();
    }

    public void toggle(String pattern, boolean active) {
        rules.replaceAll(r -> r.pattern().equals(pattern)
                ? new AccessRuleDto(r.pattern(), r.action(), r.listType(), r.matchType(),
                    r.reason(), r.createdAt(), r.expiresAt(), active)
                : r);
        writeAccessFile();
    }

    private void writeAccessFile() {
        try {
            StringBuilder sb = new StringBuilder("# Postfix access table - managed by PostfixMgr\n");
            for (AccessRuleDto r : rules) {
                if (!r.isActive()) continue;
                sb.append(String.format("%-40s %s\n", r.pattern(), r.action()));
            }
            Files.writeString(Paths.get(accessFile), sb.toString());
            // postmap
            new ProcessBuilder("sh", "-c", "postmap " + accessFile)
                    .redirectErrorStream(true).start().waitFor();
        } catch (Exception e) {
            LOG.warnf("Could not write access file: %s", e.getMessage());
        }
    }
}
