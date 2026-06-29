    public record PostfixStatsDto(
            int totalMessages, int deliveredMessages, int bouncedMessages,
            int deferredMessages, int rejectedMessages, int queueSize,
            double avgDeliveryTime, double deliveryRate,
            Map<String, Integer> hourlyVolume,
            List<TopSenderDto> topSenders,
            List<TopDomainDto> topDomains,
            List<DeliveryDataPointDto> deliveryTimeline) {}