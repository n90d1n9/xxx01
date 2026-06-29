package tech.kayys.risk.service;


import io.quarkus.runtime.StartupEvent;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.enterprise.event.Observes;
import jakarta.inject.Inject;
import tech.kayys.risk.domain.RiskTemplate;
import tech.kayys.risk.model.RiskCategory;
import tech.kayys.risk.model.RiskImpact;
import tech.kayys.risk.model.RiskProbability;
import tech.kayys.risk.model.RiskType;
import tech.kayys.risk.repository.RiskTemplateRepository;
import io.smallrye.mutiny.Uni;

import java.util.List;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory;
import java.io.InputStream;

@ApplicationScoped
public class RiskTemplateLoader {

    @Inject
    RiskTemplateRepository templateRepo;

    @Inject
    ObjectMapper mapper; // standard JSON mapper

    private final ObjectMapper yamlMapper = new ObjectMapper(new YAMLFactory());

    public void init(@Observes StartupEvent ev) {
        templateRepo.count()
            .onItem().transformToUni(count -> {
                if (count == 0) {
                    return loadFromFile()
                        .onItem().ifNull().continueWith(this::defaultTemplates)
                        .onFailure().recoverWithItem(this::defaultTemplates)
                        .onItem().transformToUni(list -> templateRepo.persist(list).replaceWithVoid());
                }
                return Uni.createFrom().voidItem();
            })
            .subscribe().with(
                ignored -> System.out.println("✅ Risk templates initialized"),
                failure -> System.err.println("❌ Failed to init risk templates: " + failure.getMessage())
            );
    }

    private Uni<List<RiskTemplate>> loadFromFile() {
        List<RiskTemplate> templates = null;

        // 1. Try YAML
        try (InputStream is = getClass().getResourceAsStream("/config/risk-templates.yaml")) {
            if (is != null) {
                templates = yamlMapper.readValue(is, new TypeReference<>() {});
                System.out.println("📄 Loaded " + templates.size() + " risk templates from YAML.");
                return Uni.createFrom().item(templates);
            }
        } catch (Exception e) {
            System.err.println("⚠️ Error loading YAML: " + e.getMessage());
        }

        // 2. Try JSON
        try (InputStream is = getClass().getResourceAsStream("/config/risk-templates.json")) {
            if (is != null) {
                templates = mapper.readValue(is, new TypeReference<>() {});
                System.out.println("📄 Loaded " + templates.size() + " risk templates from JSON.");
                return Uni.createFrom().item(templates);
            }
        } catch (Exception e) {
            System.err.println("⚠️ Error loading JSON: " + e.getMessage());
        }

        // 3. Neither found → null
        System.err.println("⚠️ No risk-templates.{yaml|json} found. Using defaults.");
        return Uni.createFrom().nullItem();
    }

    private List<RiskTemplate> defaultTemplates() {
        return List.of(
            create("OPS-SUP-001", "Supplier Delay",
                "Critical supplies or materials not delivered on time.",
                RiskCategory.OPERATIONAL, RiskType.THREAT,
                RiskProbability.HIGH, RiskImpact.MEDIUM,
                "Vet suppliers, sign contracts with penalties, diversify vendors.",
                "Use alternative suppliers or buffer stock."
            ),
            create("STR-MKT-001", "Market Demand Shift",
                "Product or service demand decreases due to external factors.",
                RiskCategory.STRATEGIC, RiskType.THREAT,
                RiskProbability.LOW, RiskImpact.HIGH,
                "Conduct market research, maintain flexibility in product strategy.",
                "Pivot to alternative markets or adjust pricing."
            )
        );
    }

    private RiskTemplate create(
        String code,
        String title,
        String description,
        RiskCategory category,
        RiskType type,
        RiskProbability probability,
        RiskImpact impact,
        String mitigation,
        String contingency
    ) {
        RiskTemplate t = new RiskTemplate();
        t.code = code;
        t.title = title;
        t.description = description;
        t.category = category;
        t.type = type;
        t.defaultProbability = probability;
        t.defaultImpact = impact;
        t.mitigationSuggestion = mitigation;
        t.contingencySuggestion = contingency;
        return t;
    }
}


