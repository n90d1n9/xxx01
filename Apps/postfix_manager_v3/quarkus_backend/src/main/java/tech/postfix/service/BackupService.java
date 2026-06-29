package com.postfix.service;

import com.postfix.dto.Dtos.*;
import jakarta.enterprise.context.ApplicationScoped;
import io.quarkus.scheduler.Scheduled;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.jboss.logging.Logger;
import java.io.*;
import java.nio.file.*;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.zip.*;

@ApplicationScoped
public class BackupService {

    private static final Logger LOG = Logger.getLogger(BackupService.class);
    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd-HHmm");

    @ConfigProperty(name = "postfix.backup.dir", defaultValue = "/var/backups/postfix")
    String backupDir;

    private final CopyOnWriteArrayList<BackupEntryDto> entries = new CopyOnWriteArrayList<>();

    public BackupService() {
        // Seed demo entries
        entries.add(new BackupEntryDto("bk1", "postfix-backup-2026-02-24-0200.tar.gz",
            LocalDateTime.now().minusHours(2), 46700, "manual",
            List.of("main.cf", "master.cf", "virtual_domains", "virtual_mailboxes")));
        entries.add(new BackupEntryDto("bk2", "postfix-backup-2026-02-23-0200.tar.gz",
            LocalDateTime.now().minusDays(1), 45231, "scheduled",
            List.of("main.cf", "master.cf", "virtual_domains")));
        entries.add(new BackupEntryDto("bk3", "postfix-backup-2026-02-22-0200.tar.gz",
            LocalDateTime.now().minusDays(2), 44890, "scheduled",
            List.of("main.cf", "master.cf")));
    }

    public List<BackupEntryDto> getAll() {
        try {
            return scanBackupDir();
        } catch (Exception e) {
            LOG.warnf("Cannot scan backup dir: %s", e.getMessage());
        }
        return List.copyOf(entries);
    }

    public BackupEntryDto create(List<String> includes) throws Exception {
        Path dir = Paths.get(backupDir);
        Files.createDirectories(dir);
        String ts = LocalDateTime.now().format(FMT);
        String filename = "postfix-backup-" + ts + ".tar.gz";
        Path archivePath = dir.resolve(filename);

        // Build archive
        try (FileOutputStream fos = new FileOutputStream(archivePath.toFile());
             GZIPOutputStream gzip = new GZIPOutputStream(fos)) {
            writeArchiveEntry(gzip, includes);
        }

        long size = Files.size(archivePath);
        String id = "bk" + System.currentTimeMillis();
        var entry = new BackupEntryDto(id, filename, LocalDateTime.now(), (int) size, "manual", includes);
        entries.add(0, entry);
        return entry;
    }

    public void restore(String id) throws Exception {
        // Find backup entry
        var entry = entries.stream().filter(e -> e.id().equals(id)).findFirst()
                .orElseThrow(() -> new IllegalArgumentException("Backup not found: " + id));
        Path archivePath = Paths.get(backupDir, entry.filename());
        if (!Files.exists(archivePath)) {
            LOG.warnf("Archive file not found: %s (demo mode)", archivePath);
            return; // Demo: just log
        }
        // Extract and apply
        LOG.infof("Restoring from %s...", entry.filename());
        // In real impl: extract tar.gz and copy files, then reload postfix
        new ProcessBuilder("sh", "-c", "postfix reload")
                .redirectErrorStream(true).start().waitFor();
    }

    public void delete(String id) throws Exception {
        var entry = entries.stream().filter(e -> e.id().equals(id)).findFirst();
        entry.ifPresent(e -> {
            entries.remove(e);
            try { Files.deleteIfExists(Paths.get(backupDir, e.filename())); }
            catch (Exception ex) { LOG.warnf("Could not delete backup file: %s", ex.getMessage()); }
        });
    }

    @Scheduled(cron = "0 0 2 * * ?") // daily at 2am
    void scheduledBackup() {
        try {
            create(List.of("main.cf", "master.cf", "virtual_domains", "virtual_mailboxes", "virtual_aliases"));
            LOG.info("Scheduled backup completed");
        } catch (Exception e) {
            LOG.errorf("Scheduled backup failed: %s", e.getMessage());
        }
    }

    private List<BackupEntryDto> scanBackupDir() throws IOException {
        Path dir = Paths.get(backupDir);
        if (!Files.exists(dir)) return Collections.emptyList();
        List<BackupEntryDto> result = new ArrayList<>();
        try (var stream = Files.newDirectoryStream(dir, "postfix-backup-*.tar.gz")) {
            for (Path p : stream) {
                String name = p.getFileName().toString();
                result.add(new BackupEntryDto(
                    name, name, Files.getLastModifiedTime(p).toInstant()
                        .atZone(ZoneId.systemDefault()).toLocalDateTime(),
                    (int) Files.size(p), "scheduled", List.of("main.cf")));
            }
        }
        result.sort(Comparator.comparing(BackupEntryDto::createdAt).reversed());
        return result;
    }

    private void writeArchiveEntry(OutputStream out, List<String> includes) throws IOException {
        Map<String, String> sourcePaths = Map.of(
            "main.cf",            "/etc/postfix/main.cf",
            "master.cf",          "/etc/postfix/master.cf",
            "transport",          "/etc/postfix/transport",
            "access",             "/etc/postfix/access",
            "virtual_domains",    "/etc/postfix/virtual_domains",
            "virtual_mailboxes",  "/etc/postfix/virtual_mailboxes",
            "virtual_aliases",    "/etc/postfix/virtual_aliases"
        );
        for (String inc : includes) {
            String srcPath = sourcePaths.getOrDefault(inc, "/etc/postfix/" + inc);
            Path src = Paths.get(srcPath);
            if (Files.exists(src)) {
                out.write(Files.readAllBytes(src));
            } else {
                // Write placeholder
                out.write(("# " + inc + " - not found\n").getBytes());
            }
        }
    }
}
