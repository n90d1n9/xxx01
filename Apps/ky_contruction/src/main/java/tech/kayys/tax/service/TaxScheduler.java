package tech.kayys.tax.service;


@ApplicationScoped
public class TaxScheduler {
    
    @Inject
    TaxService taxService;
    
    @Inject
    Mailer mailer;
    
    @Scheduled(cron = "0 0 8 * * ?") // Daily at 8 AM
    public void checkOverdueTaxes() {
        List<TaxRecord> overdueTaxes = taxService.getOverdueTaxes();
        
        if (!overdueTaxes.isEmpty()) {
            // Send notification email
            Mail mail = new Mail();
            mail.setTo("finance@company.com");
            mail.setSubject("Overdue Tax Notifications");
            mail.setText("There are " + overdueTaxes.size() + " overdue tax records that need attention.");
            
            mailer.send(mail);
        }
    }
    
    @Scheduled(cron = "0 0 9 10 * ?") // Monthly on 10th at 9 AM
    public void generateMonthlyTaxReports() {
        // Auto-generate monthly tax calculations
        LocalDate now = LocalDate.now();
        int previousMonth = now.minusMonths(1).getMonthValue();
        int year = now.minusMonths(1).getYear();
        
        List<Company> companies = Company.listAll();
        for (Company company : companies) {
            try {
                taxService.calculatePPN(company.id, year, previousMonth);
            } catch (Exception e) {
                // Log error but continue processing other companies
                System.err.println("Error calculating PPN for company " + company.name + ": " + e.getMessage());
            }
        }
    }
}