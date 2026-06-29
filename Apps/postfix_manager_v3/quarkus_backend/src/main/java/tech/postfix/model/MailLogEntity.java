

@Entity
@Table(name = "mail_logs", indexes = {
    @Index(name = "idx_mail_logs_timestamp", columnList = "timestamp"),
    @Index(name = "idx_mail_logs_level", columnList = "level"),
})
class MailLogEntity extends PanacheEntityBase {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Long id;

    @Column(nullable = false)
    public LocalDateTime timestamp;

    @Column(nullable = false, length = 10)
    public String level;  // INFO, WARN, ERROR

    @Column(nullable = false, length = 64)
    public String process;

    @Column(nullable = false, length = 2000)
    public String message;

    @Column(name = "queue_id", length = 32)
    public String queueId;

    @Column(name = "from_addr", length = 256)
    public String fromAddr;

    @Column(name = "to_addr", length = 256)
    public String toAddr;

    @Column(length = 32)
    public String status;

    public Integer delay;

    public static io.quarkus.panache.common.Page DEFAULT_PAGE = io.quarkus.panache.common.Page.ofSize(100);
}