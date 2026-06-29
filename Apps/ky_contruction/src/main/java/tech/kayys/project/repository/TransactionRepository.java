package tech.kayys.project.repository;

import io.quarkus.hibernate.reactive.panache.PanacheRepository;
import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.project.domain.ProjectTransaction;

@ApplicationScoped
public class TransactionRepository implements PanacheRepository<ProjectTransaction> {}
