package tech.kayys.risk.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import tech.kayys.project.domain.ProjectTransaction;

public record TransactionDTO(Long id, Long projectId, 
                             ProjectTransaction.TransactionType type,
                             ProjectTransaction.DomainType domain,
                             BigDecimal amount, Integer quantity, 
                             String description, String createdBy,
                             LocalDateTime transactionDate) {}