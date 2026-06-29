package tech.kayys.profile.domain;

import java.time.LocalDateTime;
import java.util.List;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import tech.kayys.risk.domain.RiskRegister;

@Entity
@Table(name = "users")
public class User extends PanacheEntity {
    
    @Column(unique = true)
    public String username;
    
    @Column(unique = true)
    public String email;
    
    public String firstName;
    public String lastName;
    public String department;
    public String position;
    
    @Enumerated(EnumType.STRING)
    public UserRole role;
    
    @Column(name = "is_active")
    public Boolean isActive = true;
    
    @Column(name = "created_date")
    public LocalDateTime createdDate = LocalDateTime.now();
    
    @Column(name = "last_login")
    public LocalDateTime lastLogin;
    
    // Relationship with risks as owner/reviewer
    @OneToMany(mappedBy = "owner", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    public List<RiskRegister> ownedRisks;
    
    public enum UserRole {
        RISK_OWNER("Risk Owner"),
        RISK_MANAGER("Risk Manager"),
        RISK_ANALYST("Risk Analyst"),
        EXECUTIVE("Executive"),
        AUDITOR("Auditor"),
        ADMIN("Administrator");
        
        private final String label;
        UserRole(String label) { this.label = label; }
        public String getLabel() { return label; }
    }
    
    public String getFullName() {
        return firstName + " " + lastName;
    }
}
