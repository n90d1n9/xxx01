package tech.kayys.risk.model;

    public enum MitigationStrategy {
        AVOID("Menghindari"),
        MITIGATE("Memitigasi"),
        TRANSFER("Mentransfer"),
        ACCEPT("Menerima"),
        MONITOR("Memantau");
        
        private final String label;
        MitigationStrategy(String label) { this.label = label; }
        public String getLabel() { return label; }
    }