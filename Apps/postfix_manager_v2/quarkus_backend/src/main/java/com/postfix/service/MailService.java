package com.postfix.service;

import com.postfix.dto.Dtos.*;
import com.postfix.model.*;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;
import org.jboss.logging.Logger;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.*;

/**
 * MailService — manages virtual domains, mailboxes, and aliases
 * stored in PostgreSQL (Dovecot-compatible schema).
 */
@ApplicationScoped
public class MailService {

    private static final Logger LOG = Logger.getLogger(MailService.class);

    // ─── Domains ───────────────────────────────────────────────────────────────
    public List<VirtualDomainDto> getDomains() {
        return VirtualDomainEntity.<VirtualDomainEntity>listAll().stream()
                .map(this::toDto)
                .toList();
    }

    @Transactional
    public VirtualDomainDto createDomain(String domain) {
        var existing = VirtualDomainEntity.findById(domain);
        if (existing != null) throw new IllegalArgumentException("Domain already exists: " + domain);

        var entity = new VirtualDomainEntity();
        entity.domain = domain.toLowerCase().trim();
        entity.isActive = true;
        entity.createdAt = LocalDateTime.now();
        entity.persist();

        LOG.infof("Created virtual domain: %s", domain);
        return toDto(entity);
    }

    @Transactional
    public void deleteDomain(String domain) {
        // Delete aliases and mailboxes first
        VirtualAliasEntity.delete("domain", domain);
        VirtualMailboxEntity.delete("domain", domain);
        VirtualDomainEntity.deleteById(domain);
        LOG.infof("Deleted domain: %s", domain);
    }

    @Transactional
    public void toggleDomain(String domain, boolean active) {
        VirtualDomainEntity entity = VirtualDomainEntity.findById(domain);
        if (entity == null) throw new NoSuchElementException("Domain not found: " + domain);
        entity.isActive = active;
        LOG.infof("Domain %s: active=%b", domain, active);
    }

    private VirtualDomainDto toDto(VirtualDomainEntity e) {
        long mailboxCount = VirtualMailboxEntity.count("domain", e.domain);
        long aliasCount = VirtualAliasEntity.count("domain", e.domain);
        return new VirtualDomainDto(e.domain, e.isActive, (int) mailboxCount, (int) aliasCount, e.createdAt);
    }

    // ─── Mailboxes ─────────────────────────────────────────────────────────────
    public List<VirtualMailboxDto> getMailboxes(String domain) {
        List<VirtualMailboxEntity> entities = domain != null
                ? VirtualMailboxEntity.list("domain", domain)
                : VirtualMailboxEntity.listAll();
        return entities.stream().map(this::toDto).toList();
    }

    @Transactional
    public VirtualMailboxDto createMailbox(String email, String password, int quotaMb, String forwardTo) {
        email = email.toLowerCase().trim();
        if (VirtualMailboxEntity.findById(email) != null) {
            throw new IllegalArgumentException("Mailbox already exists: " + email);
        }

        var parts = email.split("@");
        if (parts.length != 2) throw new IllegalArgumentException("Invalid email: " + email);

        // Ensure domain exists
        if (VirtualDomainEntity.findById(parts[1]) == null) {
            throw new IllegalArgumentException("Domain not found: " + parts[1]);
        }

        var entity = new VirtualMailboxEntity();
        entity.email = email;
        entity.domain = parts[1];
        entity.localPart = parts[0];
        entity.password = hashPassword(password);
        entity.isActive = true;
        entity.quotaMb = quotaMb;
        entity.usedMb = 0;
        entity.createdAt = LocalDateTime.now();
        entity.persist();

        LOG.infof("Created mailbox: %s", email);
        return toDto(entity);
    }

    @Transactional
    public void deleteMailbox(String email) {
        VirtualMailboxEntity.deleteById(email);
        LOG.infof("Deleted mailbox: %s", email);
    }

    @Transactional
    public void updatePassword(String email, String newPassword) {
        VirtualMailboxEntity entity = VirtualMailboxEntity.findById(email);
        if (entity == null) throw new NoSuchElementException("Mailbox not found: " + email);
        entity.password = hashPassword(newPassword);
    }

    @Transactional
    public void toggleMailbox(String email, boolean active) {
        VirtualMailboxEntity entity = VirtualMailboxEntity.findById(email);
        if (entity == null) throw new NoSuchElementException("Mailbox not found: " + email);
        entity.isActive = active;
    }

    private VirtualMailboxDto toDto(VirtualMailboxEntity e) {
        return new VirtualMailboxDto(e.email, e.domain, e.localPart, e.isActive,
                e.quotaMb, e.usedMb, e.createdAt, null, null); //
                e.quotaMb, e.usedMb, e.createdAt, e.lastLogin);
    }

    /**
     * Simple SHA-512-CRYPT compatible hash using Java's built-in
     * (production: use proper dovecot doveadm pw -s SHA512-CRYPT)
     */
    private String hashPassword(String password) {
        try {
            byte[] salt = new byte[16];
            new SecureRandom().nextBytes(salt);
            var digest = java.security.MessageDigest.getInstance("SHA-512");
            digest.update(salt);
            byte[] hash = digest.digest(password.getBytes());
            return "{SHA512}" + Base64.getEncoder().encodeToString(hash);
        } catch (Exception e) {
            throw new RuntimeException("Failed to hash password", e);
        }
    }

    // ─── Aliases ───────────────────────────────────────────────────────────────
    public List<MailAliasDto> getAliases(String domain) {
        List<VirtualAliasEntity> entities = domain != null
                ? VirtualAliasEntity.list("domain", domain)
                : VirtualAliasEntity.listAll();
        return entities.stream()
                .map(e -> new MailAliasDto(e.source, e.destination, e.isActive, null))
                .toList();
    }

    @Transactional
    public MailAliasDto createAlias(String source, String destination, String comment) {
        source = source.toLowerCase().trim();
        if (VirtualAliasEntity.findById(source) != null) {
            throw new IllegalArgumentException("Alias already exists: " + source);
        }

        var parts = source.split("@");
        if (parts.length != 2) throw new IllegalArgumentException("Invalid source: " + source);

        var entity = new VirtualAliasEntity();
        entity.source = source;
        entity.destination = destination.toLowerCase().trim();
        entity.domain = parts[1];
        entity.isActive = true;
        entity.persist();

        LOG.infof("Created alias: %s -> %s", source, destination);
        return new MailAliasDto(entity.source, entity.destination, entity.isActive, comment);
    }

    @Transactional
    public void toggleAlias(String source, boolean active) {
        VirtualAliasEntity e = VirtualAliasEntity.findById(source);
        if (e != null) { e.isActive = active; e.persist(); }
    }

    @Transactional
    public void updateQuota(String email, int quotaMb) {
        VirtualMailboxEntity e = VirtualMailboxEntity.findById(email);
        if (e != null) { e.quotaMb = quotaMb; e.persist(); }
    }

    @Transactional
    public void updatePassword(String email, String newPassword) {
        VirtualMailboxEntity e = VirtualMailboxEntity.findById(email);
        if (e != null) { e.passwordHash = hashPassword(newPassword); e.persist(); }
    }

    @Transactional
    public void toggleMailbox(String email, boolean active) {
        VirtualMailboxEntity e = VirtualMailboxEntity.findById(email);
        if (e != null) { e.isActive = active; e.persist(); }
    }

    @Transactional
    public void deleteAlias(String source) {
        VirtualAliasEntity.deleteById(source);
    }
}
