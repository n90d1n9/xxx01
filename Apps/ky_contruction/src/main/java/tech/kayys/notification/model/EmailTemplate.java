package tech.kayys.notification.model;

import java.util.Map;

@FunctionalInterface
public interface EmailTemplate {
    String apply(Map<String, Object> variables);
}