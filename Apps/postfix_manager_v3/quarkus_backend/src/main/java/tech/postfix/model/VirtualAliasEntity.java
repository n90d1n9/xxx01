

@Entity
@Table(name = "virtual_aliases")
class VirtualAliasEntity extends PanacheEntityBase {

    @Id
    public String source;

    @Column(nullable = false)
    public String destination;

    @Column(name = "is_active", nullable = false)
    public boolean isActive = true;

    @Column(nullable = false)
    public String domain;

    public static java.util.List<VirtualAliasEntity> findByDomain(String domain) {
        return list("domain", domain);
    }
}