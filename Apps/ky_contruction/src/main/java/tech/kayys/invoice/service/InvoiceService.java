package tech.kayys.invoice.service;


@ApplicationScoped
public class InvoiceService {
    
    @Inject
    InvoiceRepository invoiceRepo;
    
    @Inject
    FinancialTransactionService transactionService;
    
    @Transactional
    public Invoice createInvoice(CreateInvoiceRequest request) {
        Invoice invoice = new Invoice();
        invoice.invoiceNumber = generateInvoiceNumber();
        invoice.invoiceDate = request.invoiceDate;
        invoice.dueDate = request.dueDate;
        invoice.customerName = request.customerName;
        invoice.customerAddress = request.customerAddress;
        invoice.customerNpwp = request.customerNpwp;
        invoice.company = Company.findById(request.companyId);
        invoice.description = request.description;
        invoice.paymentTerms = request.paymentTerms;
        
        // Calculate amounts
        BigDecimal subtotal = request.items.stream()
                .map(item -> item.quantity.multiply(item.unitPrice))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        BigDecimal ppnAmount = subtotal.multiply(new BigDecimal("0.11")); // 11% PPN
        BigDecimal totalAmount = subtotal.add(ppnAmount);
        
        invoice.subtotal = subtotal;
        invoice.ppnAmount = ppnAmount;
        invoice.totalAmount = totalAmount;
        
        invoiceRepo.persist(invoice);
        
        // Create invoice items
        for (CreateInvoiceItemRequest itemRequest : request.items) {
            InvoiceItem item = new InvoiceItem();
            item.description = itemRequest.description;
            item.quantity = itemRequest.quantity;
            item.unit = itemRequest.unit;
            item.unitPrice = itemRequest.unitPrice;
            item.amount = itemRequest.quantity.multiply(itemRequest.unitPrice);
            item.invoice = invoice;
            item.account = ChartOfAccount.findById(itemRequest.accountId);
            
            InvoiceItemRepository.persist(item);
            invoice.items.add(item);
        }
        
        return invoice;
    }
    
    @Transactional
    public Invoice sendInvoice(Long invoiceId) {
        Invoice invoice = invoiceRepo.findById(invoiceId);
        if (invoice == null) {
            throw new EntityNotFoundException("Invoice not found");
        }
        
        invoice.status = InvoiceStatus.SENT;
        invoice.fakturPajakNumber = generateFakturPajakNumber();
        
        // Create journal entry for sales
        CreateTransactionRequest transactionRequest = new CreateTransactionRequest();
        transactionRequest.companyId = invoice.company.id;
        transactionRequest.transactionDate = invoice.invoiceDate;
        transactionRequest.description = "Sales Invoice: " + invoice.invoiceNumber;
        transactionRequest.amount = invoice.totalAmount;
        transactionRequest.transactionType = TransactionType.JOURNAL_ENTRY;
        transactionRequest.reference = invoice.invoiceNumber;
        
        // Find accounts (assuming standard account structure)
        ChartOfAccount accountsReceivable = ChartOfAccount.find("accountCode = ?1 AND company.id = ?2", 
                                                              "1120", invoice.company.id).firstResult();
        ChartOfAccount salesRevenue = ChartOfAccount.find("accountCode = ?1 AND company.id = ?2", 
                                                         "4110", invoice.company.id).firstResult();
        
        if (accountsReceivable != null && salesRevenue != null) {
            transactionRequest.debitAccountId = accountsReceivable.id;
            transactionRequest.creditAccountId = salesRevenue.id;
            transactionService.createTransaction(transactionRequest);
        }
        
        return invoice;
    }
    
    @Transactional
    public Invoice markInvoicePaid(Long invoiceId, BigDecimal paidAmount, LocalDate paidDate) {
        Invoice invoice = invoiceRepo.findById(invoiceId);
        if (invoice == null) {
            throw new EntityNotFoundException("Invoice not found");
        }
        
        if (paidAmount.compareTo(invoice.totalAmount) >= 0) {
            invoice.status = InvoiceStatus.PAID;
        } else {
            invoice.status = InvoiceStatus.PARTIAL_PAID;
        }
        
        invoice.paidDate = paidDate;
        
        // Create payment transaction
        CreateTransactionRequest paymentTransaction = new CreateTransactionRequest();
        paymentTransaction.companyId = invoice.company.id;
        paymentTransaction.transactionDate = paidDate;
        paymentTransaction.description = "Payment received for Invoice: " + invoice.invoiceNumber;
        paymentTransaction.amount = paidAmount;
        paymentTransaction.transactionType = TransactionType.CASH_RECEIPT;
        paymentTransaction.reference = invoice.invoiceNumber;
        
        // Find cash/bank and accounts receivable accounts
        ChartOfAccount cashAccount = ChartOfAccount.find("accountCode = ?1 AND company.id = ?2", 
                                                        "1110", invoice.company.id).firstResult();
        ChartOfAccount accountsReceivable = ChartOfAccount.find("accountCode = ?1 AND company.id = ?2", 
                                                              "1120", invoice.company.id).firstResult();
        
        if (cashAccount != null && accountsReceivable != null) {
            paymentTransaction.debitAccountId = cashAccount.id;
            paymentTransaction.creditAccountId = accountsReceivable.id;
            transactionService.createTransaction(paymentTransaction);
        }
        
        return invoice;
    }
    
    private String generateInvoiceNumber() {
        String yearMonth = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMM"));
        Long count = invoiceRepo.count("invoiceNumber LIKE ?1", "INV" + yearMonth + "%");
        return String.format("INV%s%04d", yearMonth, count + 1);
    }
    
    private String generateFakturPajakNumber() {
        String yearMonth = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMM"));
        Long count = invoiceRepo.count("fakturPajakNumber IS NOT NULL AND fakturPajakNumber LIKE ?1", 
                                      "FP" + yearMonth + "%");
        return String.format("FP%s%06d", yearMonth, count + 1);
    }
}