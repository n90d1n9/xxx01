package tech.kayys.project.repository;

import io.quarkus.hibernate.reactive.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.project.domain.ScheduleActivity;

@ApplicationScoped
public class ScheduleActivityRepository implements PanacheRepository<ScheduleActivity> {
}

