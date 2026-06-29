package tech.kayys.asset.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

import io.quarkus.scheduler.Scheduled;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import tech.kayys.accounting.domain.ChartOfAccount;
import tech.kayys.accounting.model.TransactionType;
import tech.kayys.accounting.service.FinancialTransactionService;
import tech.kayys.asset.domain.Asset;
import tech.kayys.asset.dto.CreateAssetRequest;
import tech.kayys.asset.model.AssetCategory;
import tech.kayys.asset.model.AssetStatus;
import tech.kayys.company.domain.Company;
import tech.kayys.company.dto.CreateTransactionRequest;

@ApplicationScoped
public class AssetService {
    
    @Inject
    AssetRepository assetRepo;
    
    @Inject
    FinancialTransactionService transactionService;
    
    @Transactional
    public Asset createAsset(CreateAssetRequest request) {
        Asset asset = new Asset();
        asset.assetCode = generateAssetCode(request.category);
        asset.assetName = request.assetName;
        asset.category = request.category;
        asset.purchasePrice = request.purchasePrice;
        asset.currentValue = request.purchasePrice;
        asset.purchaseDate = request.purchaseDate;
        asset.usefulLife = request.usefulLife;
        asset.depreciationMethod = request.depreciationMethod;
        asset.company = Company.findById(request.companyId);
        asset.account = ChartOfAccount.findById(request.accountId);
        asset.serialNumber = request.serialNumber;
        asset.location = request.location;
        asset.supplier = request.supplier;
        asset.invoiceNumber = request.invoiceNumber;
        
        assetRepo.persist(asset);
        
        // Create purchase transaction
        CreateTransactionRequest purchaseTransaction = new CreateTransactionRequest();
        purchaseTransaction.companyId = request.companyId;
        purchaseTransaction.transactionDate = request.purchaseDate;
        purchaseTransaction.description = "Asset Purchase: " + asset.assetName;
        purchaseTransaction.amount = request.purchasePrice;
        purchaseTransaction.transactionType = TransactionType.JOURNAL_ENTRY;
        purchaseTransaction.reference = asset.assetCode;
        
        // Find cash/accounts payable account
        ChartOfAccount cashAccount = ChartOfAccount.find("accountCode = ?1 AND company.id = ?2", 
                                                        "1110", request.companyId).firstResult();
        
        if (cashAccount != null) {
            purchaseTransaction.debitAccountId = request.accountId; // Asset account
            purchaseTransaction.creditAccountId = cashAccount.id;   // Cash account
            transactionService.createTransaction(purchaseTransaction);
        }
        
        return asset;
    }
    
    @Scheduled(cron = "0 0 1 1 * ?") // Monthly on 1st at 1 AM
    @Transactional
    public void calculateMonthlyDepreciation() {
        List<Asset> activeAssets = assetRepo.find("status = ?1", AssetStatus.ACTIVE).list();
        
        for (Asset asset : activeAssets) {
            BigDecimal monthlyDepreciation = calculateDepreciation(asset);
            
            if (monthlyDepreciation.compareTo(BigDecimal.ZERO) > 0) {
                asset.accumulatedDepreciation = asset.accumulatedDepreciation.add(monthlyDepreciation);
                asset.currentValue = asset.purchasePrice.subtract(asset.accumulatedDepreciation);
                
                // Check if fully depreciated
                if (asset.currentValue.compareTo(BigDecimal.ZERO) <= 0) {
                    asset.status = AssetStatus.FULLY_DEPRECIATED;
                    asset.currentValue = BigDecimal.ZERO;
                }
                
                // Create depreciation transaction
                CreateTransactionRequest depreciationTransaction = new CreateTransactionRequest();
                depreciationTransaction.companyId = asset.company.id;
                depreciationTransaction.transactionDate = LocalDate.now();
                depreciationTransaction.description = "Monthly Depreciation: " + asset.assetName;
                depreciationTransaction.amount = monthlyDepreciation;
                depreciationTransaction.transactionType = TransactionType.JOURNAL_ENTRY;
                depreciationTransaction.reference = asset.assetCode;
                
                // Find depreciation expense and accumulated depreciation accounts
                ChartOfAccount depreciationExpense = ChartOfAccount.find("accountCode = ?1 AND company.id = ?2", 
                                                                        "5210", asset.company.id).firstResult();
                ChartOfAccount accumulatedDepreciation = ChartOfAccount.find("accountCode = ?1 AND company.id = ?2", 
                                                                           "1290", asset.company.id).firstResult();
                
                if (depreciationExpense != null && accumulatedDepreciation != null) {
                    depreciationTransaction.debitAccountId = depreciationExpense.id;
                    depreciationTransaction.creditAccountId = accumulatedDepreciation.id;
                    transactionService.createTransaction(depreciationTransaction);
                }
            }
        }
    }
    
    private BigDecimal calculateDepreciation(Asset asset) {
        switch (asset.depreciationMethod) {
            case STRAIGHT_LINE:
                return asset.purchasePrice.divide(BigDecimal.valueOf(asset.usefulLife * 12), 2, RoundingMode.HALF_UP);
            
            case DECLINING_BALANCE:
                BigDecimal rate = BigDecimal.valueOf(2.0 / asset.usefulLife / 12);
                return asset.currentValue.multiply(rate);
            
            default:
                return BigDecimal.ZERO;
        }
    }
    
    private String generateAssetCode(AssetCategory category) {
        String prefix = category.name().substring(0, 3);
        String yearMonth = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMM"));
        Long count = assetRepo.count("assetCode LIKE ?1", prefix + yearMonth + "%");
        return String.format("%s%s%04d", prefix, yearMonth, count + 1);
    }
}