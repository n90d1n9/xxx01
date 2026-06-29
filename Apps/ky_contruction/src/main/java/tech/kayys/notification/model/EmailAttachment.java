package tech.kayys.notification.model;

public record EmailAttachment(
        byte[] content,
        String fileName,
        String contentType,
        boolean inline,
        String contentId
) {}
