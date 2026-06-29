package tech.kayys.risk.model;

public enum RiskImpact {
        VERY_LOW(1, "Sangat Rendah"),
        LOW(2, "Rendah"),
        MEDIUM(3, "Sedang"),
        HIGH(4, "Tinggi"),
        VERY_HIGH(5, "Sangat Tinggi");

        private final int score;
        private final String label;
        RiskImpact(int score, String label) { this.score = score; this.label = label; }
        public int getScore() { return score; }
        public String getLabel() { return label; }
    }