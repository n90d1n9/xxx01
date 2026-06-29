

   public record ServerStatusDto(
            boolean isRunning, LocalDateTime startedAt, String version, int pid,
            double cpuUsage, double memoryUsage, int connectionsActive,
            Map<String, Boolean> services) {}