package tech.kayys.risk.model;

public enum RiskCategory {
        STRATEGIC("Strategic Risk"),
        OPERATIONAL("Operational Risk"),
        FINANCIAL("Financial Risk"),
        COMPLIANCE("Compliance Risk"),
        REPUTATIONAL("Reputational Risk"),
        TECHNOLOGY("Technology Risk"),
        CYBER_SECURITY("Cyber Security Risk"),
        MARKET("Market Risk"),
        CREDIT("Credit Risk"),
        LIQUIDITY("Liquidity Risk"),
        ENVIRONMENTAL("Environmental Risk"),
        LEGAL("Legal Risk"),
        HUMAN_RESOURCES("Human Resources Risk"), 
        IT("IT Risk"), 
        SAFETY("Safety Risk");
        
        private final String label;
        RiskCategory(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
