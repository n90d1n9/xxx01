  public record MailLogDto(
            String id, LocalDateTime timestamp, String level, String process,
            String message, String queueId, String from, String to,
            String status, Integer delay, String host, String ip) {}
