

@Entity
@Table(name = "virtual_mailboxes")
class VirtualMailboxEntity extends PanacheEntityBase {

    @Id
    public String email;

    @Column(nullable = false)
    public String domain;

    @Column(name = "local_part", nullable = false)
    public String localPart;

    @Column(nullable = false)
    public String password;  // stored as SHA-512-CRYPT hash

    @Column(name = "is_active", nullable = false)
    public boolean isActive = true;

    @Column(name = "quota_mb", nullable = false)
    public int quotaMb = 1024;

    @Column(name = "used_mb", nullable = false)
    public int usedMb = 0;

    @Column(name = "created_at", nullable = false)
    public LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "last_login")
    public LocalDateTime lastLogin;

    public static java.util.List<VirtualMailboxEntity> findByDomain(String domain) {
        return list("domain", domain);
    }
}