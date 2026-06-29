   public record MailQueueDto(
            String id, String sender, String recipient, String subject,
            long size, String status, LocalDateTime arrivedAt,
            int deliveryAttempts, String lastError,
            List<String> allRecipients, String nextDelivery) {}
