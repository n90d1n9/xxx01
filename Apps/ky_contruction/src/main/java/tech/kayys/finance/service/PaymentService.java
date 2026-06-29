package tech.kayys.finance.service;

import java.math.BigDecimal;
import java.time.LocalDate;

import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.finance.domain.ProgressPayment;

@ApplicationScoped
public class PaymentService {
    
    public ProgressPayment createProgressPayment(ProgressPayment payment) {
        // Calculate payment number
        Integer lastPaymentNumber = ProgressPayment
            .find("contract = ?1 ORDER BY paymentNumber DESC", payment.contract)
            .project(Integer.class, "paymentNumber")
            .firstResult();
        
        payment.paymentNumber = (lastPaymentNumber != null ? lastPaymentNumber : 0) + 1;
        payment.submittedDate = LocalDate.now();
        
        // Calculate amounts
        calculatePaymentAmounts(payment);
        
        payment.persist();
        return payment;
    }
    
    public ProgressPayment approvePayment(Long paymentId, String approvedBy) {
        ProgressPayment payment = ProgressPayment.findById(paymentId);
        if (payment != null) {
            payment.status = ProgressPayment.PaymentStatus.APPROVED;
            payment.approvedDate = LocalDate.now();
            payment.persist();
        }
        return payment;
    }
    
    public ProgressPayment markAsPaid(Long paymentId) {
        ProgressPayment payment = ProgressPayment.findById(paymentId);
        if (payment != null) {
            payment.status = ProgressPayment.PaymentStatus.PAID;
            payment.paidDate = LocalDate.now();
            payment.persist();
        }
        return payment;
    }
    
    private void calculatePaymentAmounts(ProgressPayment payment) {
        if (payment.grossAmount != null) {
            // Calculate retention (usually 5-10%)
            BigDecimal retentionRate = payment.contract.retentionPercentage != null ? 
                payment.contract.retentionPercentage.divide(BigDecimal.valueOf(100)) : 
                BigDecimal.valueOf(0.05);
            
            payment.retentionAmount = payment.grossAmount.multiply(retentionRate);
            
            // Calculate tax (PPN 11% in Indonesia)
            BigDecimal taxRate = BigDecimal.valueOf(0.11);
            payment.taxAmount = payment.grossAmount.multiply(taxRate);
            
            // Calculate net amount
            payment.netAmount = payment.grossAmount
                .subtract(payment.retentionAmount)
                .add(payment.taxAmount);
        }
    }
}