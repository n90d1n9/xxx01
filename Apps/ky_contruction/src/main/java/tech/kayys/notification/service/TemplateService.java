package tech.kayys.notification.service;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;


public class TemplateService {
    private final Map<String, EmailTemplate> templates = new ConcurrentHashMap<>();

    public void registerTemplate(String name, EmailTemplate template) {
        templates.put(name, template);
    }

    public EmailTemplate getTemplate(String name) {
        return templates.getOrDefault(name, templates.get("default"));
    }

    public String render(String templateName, Map<String, Object> variables) {
        EmailTemplate template = getTemplate(templateName);
        return template.apply(variables);
    }
}