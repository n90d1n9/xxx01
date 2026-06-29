package tech.kayys.finance.domain;

import java.time.LocalDate;
import java.util.List;
import java.math.BigDecimal;
import io.quarkus.hibernate.reactive.panache.PanacheEntity;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import tech.kayys.contract.domain.Contract;

@Entity
@Table(name = "progress_payments")
public class ProgressPayment extends PanacheEntity {

    @ManyToOne
    @JoinColumn(name = "contract_id")
    public Contract contract;

    @Column(name = "payment_number")
    public Integer paymentNumber;

    @Column(name = "payment_period_start")
    public LocalDate paymentPeriodStart;

    @Column(name = "payment_period_end")
    public LocalDate paymentPeriodEnd;

    @Column(name = "gross_amount", precision = 15, scale = 2)
    public BigDecimal grossAmount;

    @Column(name = "retention_amount", precision = 15, scale = 2)
    public BigDecimal retentionAmount;

    @Column(name = "previous_payments", precision = 15, scale = 2)
    public BigDecimal previousPayments = BigDecimal.ZERO;

    @Column(name = "net_payment", precision = 15, scale = 2)
    public BigDecimal netPayment;

    @Column(name = "ppn_amount", precision = 15, scale = 2)
    public BigDecimal ppnAmount; // PPN (Value Added Tax)

    @Column(name = "pph_amount", precision = 15, scale = 2)
    public BigDecimal pphAmount; // PPh (Income Tax)

    @Column(name = "total_payment", precision = 15, scale = 2)
    public BigDecimal totalPayment;

    @Enumerated(EnumType.STRING)
    public PaymentStatus status = PaymentStatus.DRAFT;

    @Column(name = "submitted_date")
    public LocalDate submittedDate;

    @Column(name = "approved_date")
    public LocalDate approvedDate;

    @Column(name = "paid_date")
    public LocalDate paidDate;

    @Column(name = "efaktur_number")
    public String eFakturNumber;

    @Column(name = "payment_period")
    public String paymentPeriod;

    @Column(name = "work_progress_percentage", precision = 5, scale = 2)
    public BigDecimal workProgressPercentage;

    @Column(name = "tax_amount", precision = 15, scale = 2)
    public BigDecimal taxAmount;

    @Column(name = "net_amount", precision = 15, scale = 2)
    public BigDecimal netAmount;

    @Column(name = "remarks", length = 1000)
    public String remarks;

    @OneToMany(mappedBy = "progressPayment", cascade = CascadeType.ALL)
    public List<PaymentItem> paymentItems;

    public enum PaymentStatus {
        DRAFT("Draft"),
        SUBMITTED("Submitted"),
        UNDER_REVIEW("Under Review"),
        APPROVED("Approved"),
        PAID("Paid"),
        REJECTED("Rejected"),

        ;

        private final String label;

        PaymentStatus(String label) {
            this.label = label;
        }

        public String getLabel() {
            return label;
        }
    }

    @PrePersist
    @PreUpdate
    public void calculatePayment() {
        if (grossAmount != null && retentionAmount != null && previousPayments != null) {
            netPayment = grossAmount.subtract(retentionAmount).subtract(previousPayments);
        }
        if (netPayment != null) {
            // Calculate PPN (11% in Indonesia)
            ppnAmount = netPayment.multiply(new BigDecimal("0.11"));
            // Calculate PPh (2% for construction services)
            pphAmount = netPayment.multiply(new BigDecimal("0.02"));
            totalPayment = netPayment.add(ppnAmount).subtract(pphAmount);
        }
    }
}
