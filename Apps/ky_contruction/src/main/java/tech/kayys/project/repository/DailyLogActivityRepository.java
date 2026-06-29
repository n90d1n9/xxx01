package tech.kayys.project.repository;


import io.quarkus.hibernate.reactive.panache.PanacheRepository;
import io.smallrye.mutiny.Uni;
import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.finance.domain.DailyLogActivity;

import java.util.List;

@ApplicationScoped
public class DailyLogActivityRepository implements PanacheRepository<DailyLogActivity> {

    public Uni<List<DailyLogActivity>> findByDailyLog(Long dailyLogId) {
        return list("dailyLog.id", dailyLogId);
    }
}
