package tech.kayys.risk.model;

    public enum RiskLevel {
        CRITICAL("Critical", "#DC2626"),
        HIGH("High", "#EA580C"),
        MEDIUM("Medium", "#D97706"),
        LOW("Low", "#65A30D"),
        VERY_LOW("Very Low", "#16A34A");
        
        private final String label;
        private final String color;
        
        RiskLevel(String label, String color) {
            this.label = label;
            this.color = color;
        }
        
        public String getLabel() { return label; }
        public String getColor() { return color; }
    }