package tech.kayys.compliance.domain;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;

@Entity
@Table(name = "sni_standards")
public class SNIStandard extends PanacheEntity {
    
    @Column(name = "sni_code", unique = true)
    public String sniCode;
    
    @Column(name = "title")
    public String title;
    
    @Column(name = "scope", length = 2000)
    public String scope;
    
    @Column(name = "publication_year")
    public Integer publicationYear;
    
    @Column(name = "revision_year")
    public Integer revisionYear;
    
    @Column(name = "status")
    @Enumerated(EnumType.STRING)
    public StandardStatus status = StandardStatus.ACTIVE;
    
    @Column(name = "category")
    public String category;
    
    public enum StandardStatus {
        ACTIVE("Active"),
        SUPERSEDED("Superseded"),
        WITHDRAWN("Withdrawn");
        
        private final String label;
        StandardStatus(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
}