

   public record VirtualMailboxDto(
            String email, String domain, String localPart,
            boolean isActive, int quotaMb, int usedMb,
            LocalDateTime createdAt, LocalDateTime lastLogin, String forwardTo) {}
