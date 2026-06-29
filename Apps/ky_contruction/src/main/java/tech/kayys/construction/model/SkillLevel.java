package tech.kayys.construction.model;

import java.math.BigDecimal;

public enum SkillLevel {
    UNSKILLED("Tidak Terampil", "No special skills required", new BigDecimal("150000")), // Daily wage in IDR
    SEMI_SKILLED("Semi Terampil", "Basic training required", new BigDecimal("180000")),
    SKILLED("Terampil", "Experienced worker with specific skills", new BigDecimal("220000")),
    HIGHLY_SKILLED("Sangat Terampil", "Advanced skills and experience", new BigDecimal("280000")),
    SPECIALIST("Spesialis", "Specialized expert knowledge", new BigDecimal("350000")),
    SUPERVISOR("Supervisor", "Supervisory and leadership skills", new BigDecimal("400000")),
    FOREMAN("Mandor", "Site leadership and coordination", new BigDecimal("450000")),
    ENGINEER("Insinyur", "Professional engineering qualifications", new BigDecimal("600000"));
    
    private final String indonesianLabel;
    private final String englishDescription;
    private final BigDecimal standardDailyRate; // Standard daily rate in IDR
    
    SkillLevel(String indonesianLabel, String englishDescription, BigDecimal standardDailyRate) {
        this.indonesianLabel = indonesianLabel;
        this.englishDescription = englishDescription;
        this.standardDailyRate = standardDailyRate;
    }
    
    public String getIndonesianLabel() { return indonesianLabel; }
    public String getEnglishDescription() { return englishDescription; }
    public BigDecimal getStandardDailyRate() { return standardDailyRate; }
    
    // Regional adjustment factors for Indonesia
    public BigDecimal getRegionalAdjustedRate(String region) {
        BigDecimal adjustmentFactor = switch (region.toLowerCase()) {
            case "jakarta", "dki jakarta" -> new BigDecimal("1.20");
            case "surabaya", "jawa timur" -> new BigDecimal("1.10");
            case "bandung", "jawa barat" -> new BigDecimal("1.05");
            case "medan", "sumatera utara" -> new BigDecimal("1.08");
            case "makassar", "sulawesi selatan" -> new BigDecimal("0.95");
            case "balikpapan", "kalimantan timur" -> new BigDecimal("1.15");
            case "bali", "denpasar" -> new BigDecimal("1.02");
            default -> new BigDecimal("1.00");
        };
        
        return standardDailyRate.multiply(adjustmentFactor);
    }
}
