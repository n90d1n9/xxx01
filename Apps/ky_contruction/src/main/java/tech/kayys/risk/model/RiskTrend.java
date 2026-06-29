package tech.kayys.risk.model;

    public enum RiskTrend {
        INCREASING("Meningkat"),
        DECREASING("Menurun"),
        STABLE("Stabil"),
        VOLATILE("Tidak Stabil");
        
        private final String label;
        RiskTrend(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
