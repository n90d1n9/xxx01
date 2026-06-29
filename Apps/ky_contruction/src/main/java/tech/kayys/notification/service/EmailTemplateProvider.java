package tech.kayys.notification.service;

import java.util.List;

public class EmailTemplateProvider {

    // very basic, can later be replaced with FreeMarker/Thymeleaf/etc.
    public String renderTemplate(String templateName, List<String> params) {
        if (templateName == null || templateName.isBlank()) {
            return defaultTemplate(params);
        }

        // 🔹 In real-world: load template by name from DB/filesystem
        if ("welcome".equalsIgnoreCase(templateName)) {
            return "<html><body><h1>Welcome!</h1><p>" 
                    + safeParam(params, 0, "User") 
                    + ", thanks for joining us.</p></body></html>";
        }

        if ("reset-password".equalsIgnoreCase(templateName)) {
            return "<html><body><p>Hello " 
                    + safeParam(params, 0, "User") 
                    + ", click <a href='" 
                    + safeParam(params, 1, "#") 
                    + "'>here</a> to reset your password.</p></body></html>";
        }

        // fallback to default
        return defaultTemplate(params);
    }

    private String defaultTemplate(List<String> params) {
        return "<html><body><p>" 
                + safeParam(params, 0, "Hello") 
                + ", this is a default email message.</p>"
                + "<p>Sent at " + java.time.LocalDateTime.now() + "</p></body></html>";
    }

    private String safeParam(List<String> params, int index, String fallback) {
        return (params != null && params.size() > index && params.get(index) != null)
                ? params.get(index)
                : fallback;
    }
}
