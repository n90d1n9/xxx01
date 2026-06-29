    public record BackupEntryDto(
            String id, String filename, LocalDateTime createdAt,
            int sizeBytes, String type, List<String> includes) {}
