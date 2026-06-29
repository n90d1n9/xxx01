package com.postfix.dto;

import java.time.LocalDateTime;

public record VirtualDomainDto(
        String domain, boolean isActive, int mailboxCount,
        int aliasCount, LocalDateTime createdAt) {
}
