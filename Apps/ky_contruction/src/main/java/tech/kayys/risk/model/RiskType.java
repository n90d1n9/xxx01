package tech.kayys.risk.model;

    public enum RiskType {
        INTERNAL("Internal"),
        EXTERNAL("External"),
        PROJECT_SPECIFIC("Project Specific"),
        ENTERPRISE_WIDE("Enterprise Wide"),
        SYSTEMATIC("Systematic"),
        IDIOSYNCRATIC("Idiosyncratic"), 
        THREAT("Threat");
        
        private final String label;
        RiskType(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
