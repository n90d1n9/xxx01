package tech.kayys.controller;


//import tech.kayys.kafkamanager.service.KafkaAdminService;
import org.eclipse.microprofile.health.HealthCheck;
import org.eclipse.microprofile.health.HealthCheckResponse;
import org.eclipse.microprofile.health.Readiness;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import tech.kayys.services.KafkaAdminService;

//import javax.enterprise.context.ApplicationScoped;
//import javax.inject.Inject;

@Readiness
@ApplicationScoped
public class KafkaHealthCheck implements HealthCheck {

    @Inject
    KafkaAdminService adminService;

    @Override
    public HealthCheckResponse call() {
        try {
            adminService.listTopics();
            return HealthCheckResponse.up("Kafka connection");
        } catch (Exception e) {
            return HealthCheckResponse.down("Kafka connection");
        }
    }
}
