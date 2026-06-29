package tech.kayys.risk.model;


    
    public enum RegulatoryRequirement {
        SOX("Sarbanes-Oxley Act"),
        GDPR("General Data Protection Regulation"),
        ISO27001("ISO 27001"),
        PCI_DSS("PCI DSS"),
        HIPAA("HIPAA"),
        BASEL_III("Basel III"),
        COSO("COSO Framework"),
        LOCAL_BANKING("Local Banking Regulation"),
        ENVIRONMENTAL_COMPLIANCE("Environmental Compliance");
        
        private final String label;
        RegulatoryRequirement(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
    