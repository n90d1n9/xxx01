package tech.kayys.finance.service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;

@ApplicationScoped
public class FinancialReportingService {
    
    @Inject
    AccountRepository accountRepository;
    
    @Inject
    GeneralLedgerEntryRepository generalLedgerEntryRepository;
    
    @Inject
    FiscalPeriodRepository fiscalPeriodRepository;
    
    /**
     * Generates a trial balance for a fiscal period
     */
    public TrialBalance generateTrialBalance(UUID fiscalPeriodId) {
        FiscalPeriod fiscalPeriod = fiscalPeriodRepository.findById(fiscalPeriodId);
        
        if (fiscalPeriod == null) {
            throw new IllegalArgumentException("Fiscal period not found");
        }
        
        TrialBalance trialBalance = new TrialBalance();
        trialBalance.setFiscalPeriod(fiscalPeriod);
        trialBalance.setGeneratedDate(LocalDateTime.now());
        
        List<Account> accounts = accountRepository.listAll();
        
        for (Account account : accounts) {
            List<GeneralLedgerEntry> entries = generalLedgerEntryRepository
                    .find("account.id = ?1 AND fiscalPeriod.id = ?2", 
                        account.getId(), fiscalPeriodId)
                    .list();
            
            BigDecimal totalDebits = BigDecimal.ZERO;
            BigDecimal totalCredits = BigDecimal.ZERO;
            
            for (GeneralLedgerEntry entry : entries) {
                totalDebits = totalDebits.add(entry.getDebitAmount());
                totalCredits = totalCredits.add(entry.getCreditAmount());
            }
            
            if (totalDebits.compareTo(BigDecimal.ZERO) > 0 || totalCredits.compareTo(BigDecimal.ZERO) > 0) {
                TrialBalanceLine line = new TrialBalanceLine();
                line.setAccount(account);
                line.setDebitAmount(totalDebits);
                line.setCreditAmount(totalCredits);
                
                trialBalance.getTrialBalanceLines().add(line);
            }
        }
        
        return trialBalance;
    }
    
    /**
     * Generates a balance sheet for a fiscal period
     */
    public BalanceSheet generateBalanceSheet(UUID fiscalPeriodId) {
        FiscalPeriod fiscalPeriod = fiscalPeriodRepository.findById(fiscalPeriodId);
        
        if (fiscalPeriod == null) {
            throw new IllegalArgumentException("Fiscal period not found");
        }
        
        BalanceSheet balanceSheet = new BalanceSheet();
        balanceSheet.setFiscalPeriod(fiscalPeriod);
        balanceSheet.setGeneratedDate(LocalDateTime.now());
        
        // Get all asset accounts
        List<Account> assetAccounts = accountRepository.findByType(Account.AccountType.ASSET);
        BigDecimal totalAssets = calculateAccountsTotal(assetAccounts, fiscalPeriodId);
        balanceSheet.setTotalAssets(totalAssets);
        
        // Get all liability accounts
        List<Account> liabilityAccounts = accountRepository.findByType(Account.AccountType.LIABILITY);
        BigDecimal totalLiabilities = calculateAccountsTotal(liabilityAccounts, fiscalPeriodId);
        balanceSheet.setTotalLiabilities(totalLiabilities);
        
        // Get all equity accounts
        List<Account> equityAccounts = accountRepository.findByType(Account.AccountType.EQUITY);
        BigDecimal totalEquity = calculateAccountsTotal(equityAccounts, fiscalPeriodId);
        balanceSheet.setTotalEquity(totalEquity);
        
        // Create balance sheet lines for each account
        populateBalanceSheetSection(balanceSheet, Account.AccountType.ASSET, assetAccounts, fiscalPeriodId);
        populateBalanceSheetSection(balanceSheet, Account.AccountType.LIABILITY, liabilityAccounts, fiscalPeriodId);
        populateBalanceSheetSection(balanceSheet, Account.AccountType.EQUITY, equityAccounts, fiscalPeriodId);
        
        return balanceSheet;
    }
    
    /**
     * Generates an income statement for a fiscal period
     */
    public IncomeStatement generateIncomeStatement(UUID fiscalPeriodId) {
        FiscalPeriod fiscalPeriod = fiscalPeriodRepository.findById(fiscalPeriodId);
        
        if (fiscalPeriod == null) {
            throw new IllegalArgumentException("Fiscal period not found");
        }
        
        IncomeStatement incomeStatement = new IncomeStatement();
        incomeStatement.setFiscalPeriod(fiscalPeriod);
        incomeStatement.setGeneratedDate(LocalDateTime.now());
        
        // Get all revenue accounts
        List<Account> revenueAccounts = accountRepository.findByType(Account.AccountType.REVENUE);
        BigDecimal totalRevenue = calculateAccountsTotal(revenueAccounts, fiscalPeriodId);
        incomeStatement.setTotalRevenue(totalRevenue);
        
        // Get all expense accounts
        List<Account> expenseAccounts = accountRepository.findByType(Account.AccountType.EXPENSE);
        BigDecimal totalExpenses = calculateAccountsTotal(expenseAccounts, fiscalPeriodId);
        incomeStatement.setTotalExpenses(totalExpenses);
        
        // Calculate net income
        BigDecimal netIncome = totalRevenue.subtract(totalExpenses);
        incomeStatement.setNetIncome(netIncome);
        
        // Create income statement lines for each account
        populateIncomeStatementSection(incomeStatement, Account.AccountType.REVENUE, revenueAccounts, fiscalPeriodId);
        populateIncomeStatementSection(incomeStatement, Account.AccountType.EXPENSE, expenseAccounts, fiscalPeriodId);
        
        return incomeStatement;
    }
    
    /**
     * Calculate total balance for a list of accounts
     */
    private BigDecimal calculateAccountsTotal(List<Account> accounts, UUID fiscalPeriodId) {
        BigDecimal total = BigDecimal.ZERO;
        
        for (Account account : accounts) {
            BigDecimal accountBalance = getAccountBalanceForPeriod(account.getId(), fiscalPeriodId);
            total = total.add(accountBalance);
        }
        
        return total;
    }
    
    /**
     * Get account balance for a specific fiscal period
     */
    private BigDecimal getAccountBalanceForPeriod(UUID accountId, UUID fiscalPeriodId) {
        Account account = accountRepository.findById(accountId);
        
        if (account == null) {
            throw new IllegalArgumentException("Account not found");
        }
        
        List<GeneralLedgerEntry> entries = generalLedgerEntryRepository
                .find("account.id = ?1 AND fiscalPeriod.id = ?2", 
                    accountId, fiscalPeriodId)
                .list();
        
        BigDecimal balance = BigDecimal.ZERO;
        boolean isDebitAccount = isDebitAccount(account.getAccountType());
        
        for (GeneralLedgerEntry entry : entries) {
            if (isDebitAccount) {
                balance = balance.add(entry.getDebitAmount()).subtract(entry.getCreditAmount());
            } else {
                balance = balance.add(entry.getCreditAmount()).subtract(entry.getDebitAmount());
            }
        }
        
        return balance;
    }
    
    /**
     * Determines if an account normally has a debit balance
     */
    private boolean isDebitAccount(Account.AccountType accountType) {
        return accountType == Account.AccountType.ASSET || accountType == Account.AccountType.EXPENSE;
    }
    
    /**
     * Populates a balance sheet section with account data
     */
    private void populateBalanceSheetSection(BalanceSheet balanceSheet, Account.AccountType accountType, 
                                           List<Account> accounts, UUID fiscalPeriodId) {
        for (Account account : accounts) {
            BigDecimal balance = getAccountBalanceForPeriod(account.getId(), fiscalPeriodId);
            
            // Only include accounts with non-zero balances
            if (balance.compareTo(BigDecimal.ZERO) != 0) {
                BalanceSheetLine line = new BalanceSheetLine();
                line.setAccount(account);
                line.setBalance(balance);
                line.setAccountType(accountType);
                
                balanceSheet.getBalanceSheetLines().add(line);
            }
        }
    }
    
    /**
     * Populates an income statement section with account data
     */
    private void populateIncomeStatementSection(IncomeStatement incomeStatement, Account.AccountType accountType, 
                                              List<Account> accounts, UUID fiscalPeriodId) {
        for (Account account : accounts) {
            BigDecimal balance = getAccountBalanceForPeriod(account.getId(), fiscalPeriodId);
            
            // Only include accounts with non-zero balances
            if (balance.compareTo(BigDecimal.ZERO) != 0) {
                IncomeStatementLine line = new IncomeStatementLine();
                line.setAccount(account);
                line.setBalance(balance);
                line.setAccountType(accountType);
                
                incomeStatement.getIncomeStatementLines().add(line);
            }
        }
    }
}