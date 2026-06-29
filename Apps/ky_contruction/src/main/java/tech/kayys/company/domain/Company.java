package tech.kayys.company.domain;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import tech.kayys.company.model.CompanyType;
import tech.kayys.profile.domain.User;
import tech.kayys.project.domain.Project;

@Entity
@Table(name = "companies")
public class Company extends PanacheEntity {
    
    @Column(name = "company_code", unique = true)
    public String companyCode;
    
    @Column(name = "company_name")
    public String companyName;
    
    @Column(name = "legal_entity_type")
    public String legalEntityType; // PT, CV, UD, etc.
    
  
    
    @Column(name = "address", length = 500)
    public String address;
    
    @Column(name = "phone")
    public String phone;
    
    @Column(name = "email")
    public String email;
    
    @Column(name = "website")
    public String website;
    
    @Column(name = "business_license")
    public String businessLicense;
    
    @Column(name = "sbu_grade")
    public String sbuGrade; // Construction Business Entity Grade
    
    @Column(name = "is_active")
    public Boolean isActive = true;
    
    @OneToMany(mappedBy = "company", cascade = CascadeType.ALL)
    public List<Project> projects;
    
    @OneToMany(mappedBy = "company", cascade = CascadeType.ALL)
    public List<User> users;

     @NotBlank
    @Column(unique = true)
    public String npwp; // Nomor Pokok Wajib Pajak
    
    @NotBlank
    public String name;
    
    
    @Enumerated(EnumType.STRING)
    public CompanyType type; // PT, CV, UD, etc.
    
    @NotNull
    public LocalDate establishedDate;
    
    @NotNull
    public BigDecimal authorizedCapital;
    
    @NotNull
    public BigDecimal paidUpCapital;
    
    public String siup; // Surat Izin Usaha Perdagangan
    public String tdp; // Tanda Daftar Perusahaan
    
    @OneToMany(mappedBy = "company", cascade = CascadeType.ALL)
    public List<FinancialTransaction> transactions = new ArrayList<>();
    
    @OneToMany(mappedBy = "company", cascade = CascadeType.ALL)
    public List<TaxRecord> taxRecords = new ArrayList<>();
}
