package tech.kayys.construction.service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import tech.kayys.construction.domain.ConstructionPhase;
import tech.kayys.construction.domain.PhaseActivity;

@ApplicationScoped
public class ConstructionPhaseService {
    
    @Inject
    ConstructionPhaseRepository phaseRepository;
    
    @Inject
    PhaseActivityRepository activityRepository;
    
    @Transactional
    public ConstructionPhase createPhase(ConstructionPhase phase) {
        validatePhaseSequence(phase);
        generatePhaseCode(phase);
        
        phaseRepository.persist(phase);
        
        // Create standard activities based on phase type
        createStandardActivities(phase);
        
        return phase;
    }
    
    @Transactional
    public void updatePhaseProgress(Long phaseId) {
        ConstructionPhase phase = phaseRepository.findById(phaseId);
        if (phase == null) return;
        
        List<PhaseActivity> activities = activityRepository.findByPhase(phase);
        
        if (!activities.isEmpty()) {
            // Calculate physical progress as weighted average
            BigDecimal totalBudget = activities.stream()
                    .map(a -> a.activityBudget != null ? a.activityBudget : BigDecimal.ZERO)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            
            if (totalBudget.compareTo(BigDecimal.ZERO) > 0) {
                BigDecimal weightedProgress = activities.stream()
                    .map(a -> {
                        BigDecimal weight = a.activityBudget != null ? 
                            a.activityBudget.divide(totalBudget, 6, java.math.RoundingMode.HALF_UP) : 
                            BigDecimal.ZERO;
                        BigDecimal progress = a.progressPercentage != null ? a.progressPercentage : BigDecimal.ZERO;
                        return weight.multiply(progress);
                    })
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
                
                phase.physicalProgressPercentage = weightedProgress;
            }
            
            // Calculate financial progress
            BigDecimal actualCostSum = activities.stream()
                    .map(a -> a.actualCost != null ? a.actualCost : BigDecimal.ZERO)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            
            if (phase.phaseBudget != null && phase.phaseBudget.compareTo(BigDecimal.ZERO) > 0) {
                phase.financialProgressPercentage = actualCostSum
                        .divide(phase.phaseBudget, 4, java.math.RoundingMode.HALF_UP)
                        .multiply(new BigDecimal("100"))
                        .min(new BigDecimal("100"));
            }
            
            phase.actualCost = actualCostSum;
            
            // Update phase status based on progress
            updatePhaseStatus(phase);
        }
        
        phaseRepository.persist(phase);
    }
    
    @Transactional
    public CriticalPathAnalysis calculateCriticalPath(Long projectId) {
        List<ConstructionPhase> phases = phaseRepository.findByProject(projectId);
        CriticalPathAnalysis analysis = new CriticalPathAnalysis();
        
        // Simple critical path calculation based on dependencies and duration
        LocalDate projectStart = phases.stream()
                .filter(p -> p.plannedStartDate != null)
                .map(p -> p.plannedStartDate)
                .min(LocalDate::compareTo)
                .orElse(LocalDate.now());
        
        LocalDate projectEnd = phases.stream()
                .filter(p -> p.plannedEndDate != null)
                .map(p -> p.plannedEndDate)
                .max(LocalDate::compareTo)
                .orElse(LocalDate.now().plusDays(365));
        
        // Identify critical phases (those with no float)
        List<ConstructionPhase> criticalPhases = phases.stream()
                .filter(p -> p.criticalPath != null && p.criticalPath)
                .collect(Collectors.toList());
        
        analysis.totalProjectDuration = projectStart.until(projectEnd).getDays();
        analysis.criticalPhases = criticalPhases;
        analysis.projectStartDate = projectStart;
        analysis.projectEndDate = projectEnd;
        analysis.calculationDate = LocalDateTime.now();
        
        // Calculate schedule risk
        long delayedPhases = phases.stream()
                .mapToLong(p -> p.isDelayed() ? 1 : 0)
                .sum();
        
        analysis.scheduleRiskScore = criticalPhases.isEmpty() ? 0.0 : 
                (double) delayedPhases / phases.size() * 100;
        
        return analysis;
    }
    
    @Transactional
    public PhaseResourceOptimization optimizeResourceAllocation(Long phaseId) {
        ConstructionPhase phase = phaseRepository.findById(phaseId);
        if (phase == null) return null;
        
        PhaseResourceOptimization optimization = new PhaseResourceOptimization();
        optimization.phase = phase;
        
        List<PhaseActivity> activities = activityRepository.findByPhase(phase);
        
        // Analyze resource conflicts and bottlenecks
        Map<String, List<PhaseActivity>> resourceConflicts = activities.stream()
                .filter(a -> a.responsiblePerson != null)
                .collect(Collectors.groupingBy(a -> a.responsiblePerson));
        
        // Identify overlapping activities for same resource
        for (Map.Entry<String, List<PhaseActivity>> entry : resourceConflicts.entrySet()) {
            List<PhaseActivity> resourceActivities = entry.getValue();
            
            for (int i = 0; i < resourceActivities.size(); i++) {
                for (int j = i + 1; j < resourceActivities.size(); j++) {
                    PhaseActivity activity1 = resourceActivities.get(i);
                    PhaseActivity activity2 = resourceActivities.get(j);
                    
                    if (activitiesOverlap(activity1, activity2)) {
                        ResourceConflict conflict = new ResourceConflict();
                        conflict.resourceName = entry.getKey();
                        conflict.activity1 = activity1;
                        conflict.activity2 = activity2;
                        conflict.conflictType = ResourceConflictType.SCHEDULE_OVERLAP;
                        optimization.resourceConflicts.add(conflict);
                    }
                }
            }
        }
        
        // Generate optimization recommendations
        generateOptimizationRecommendations(optimization);
        
        return optimization;
    }
    
    private void validatePhaseSequence(ConstructionPhase phase) {
        if (phase.project == null || phase.phaseSequence == null) return;
        
        ConstructionPhase existingPhase = phaseRepository.findByProjectAndSequence(
                phase.project, phase.phaseSequence);
        
        if (existingPhase != null && !existingPhase.id.equals(phase.id)) {
            throw new IllegalArgumentException(
                    "Phase sequence " + phase.phaseSequence + " already exists for this project");
        }
    }
    
    private void generatePhaseCode(ConstructionPhase phase) {
        if (phase.phaseCode == null || phase.phaseCode.isEmpty()) {
            String prefix = determinePhasePrefix(phase.phaseName);
            phase.phaseCode = String.format("%s-%s-%02d", 
                    phase.project.projectCode, prefix, phase.phaseSequence);
        }
    }
    
    private String determinePhasePrefix(String phaseName) {
        String lowerName = phaseName.toLowerCase();
        if (lowerName.contains("persiapan") || lowerName.contains("preparation")) return "PREP";
        if (lowerName.contains("pondasi") || lowerName.contains("foundation")) return "FOUND";
        if (lowerName.contains("struktur") || lowerName.contains("structure")) return "STRUCT";
        if (lowerName.contains("arsitektur") || lowerName.contains("architecture")) return "ARCH";
        if (lowerName.contains("mep")) return "MEP";
        if (lowerName.contains("finishing")) return "FINISH";
        return "PHASE";
    }
    
    private void createStandardActivities(ConstructionPhase phase) {
        // Create standard activities based on phase type
        String phaseCode = phase.phaseCode.toLowerCase();
        
        if (phaseCode.contains("prep")) {
            createPreparationActivities(phase);
        } else if (phaseCode.contains("found")) {
            createFoundationActivities(phase);
        } else if (phaseCode.contains("struct")) {
            createStructuralActivities(phase);
        } else if (phaseCode.contains("arch")) {
            createArchitecturalActivities(phase);
        } else if (phaseCode.contains("mep")) {
            createMEPActivities(phase);
        } else if (phaseCode.contains("finish")) {
            createFinishingActivities(phase);
        }
    }
    
    private void createPreparationActivities(ConstructionPhase phase) {
        createActivity(phase, "SITE_CLEAR", "Site Clearing", "Pembersihan lahan dan demolisi", 1, 7);
        createActivity(phase, "SURVEY", "Site Survey", "Survey dan setting out", 2, 3);
        createActivity(phase, "ACCESS", "Access Road", "Pembuatan jalan akses", 3, 5);
        createActivity(phase, "FACILITIES", "Site Facilities", "Pembuatan fasilitas sementara", 4, 10);
        createActivity(phase, "MOBILIZATION", "Equipment Mobilization", "Mobilisasi peralatan", 5, 3);
    }
    
    private void createFoundationActivities(ConstructionPhase phase) {
        createActivity(phase, "EXCAVATION", "Excavation", "Galian pondasi", 1, 14);
        createActivity(phase, "DEWATERING", "Dewatering", "Sistem dewatering", 2, 21);
        createActivity(phase, "PILE_WORK", "Pile Work", "Pekerjaan tiang pancang", 3, 21);
        createActivity(phase, "FOUNDATION_CONCRETE", "Foundation Concrete", "Pengecoran pondasi", 4, 10);
        createActivity(phase, "BACKFILLING", "Backfilling", "Urugan kembali", 5, 7);
    }
    
    private void createStructuralActivities(ConstructionPhase phase) {
        createActivity(phase, "COLUMN_WORK", "Column Work", "Pekerjaan kolom", 1, 30);
        createActivity(phase, "BEAM_WORK", "Beam Work", "Pekerjaan balok", 2, 25);
        createActivity(phase, "SLAB_WORK", "Slab Work", "Pekerjaan pelat lantai", 3, 20);
        createActivity(phase, "ROOF_STRUCTURE", "Roof Structure", "Struktur atap", 4, 15);
        createActivity(phase, "STRUCTURAL_TESTING", "Structural Testing", "Testing struktur", 5, 7);
    }
    
    private void createArchitecturalActivities(ConstructionPhase phase) {
        createActivity(phase, "MASONRY", "Masonry Work", "Pekerjaan pasangan", 1, 30);
        createActivity(phase, "DOORS_WINDOWS", "Doors & Windows", "Pintu dan jendela", 2, 20);
        createActivity(phase, "FLOORING", "Flooring", "Pekerjaan lantai", 3, 25);
        createActivity(phase, "CEILING", "Ceiling", "Pekerjaan plafon", 4, 20);
        createActivity(phase, "PAINTING", "Painting", "Pengecatan", 5, 15);
    }
    
    private void createMEPActivities(ConstructionPhase phase) {
        createActivity(phase, "ELECTRICAL", "Electrical Installation", "Instalasi listrik", 1, 25);
        createActivity(phase, "PLUMBING", "Plumbing Installation", "Instalasi plumbing", 2, 20);
        createActivity(phase, "HVAC", "HVAC Installation", "Instalasi HVAC", 3, 30);
        createActivity(phase, "FIRE_PROTECTION", "Fire Protection", "Sistem proteksi kebakaran", 4, 15);
        createActivity(phase, "MEP_TESTING", "MEP Testing", "Testing MEP", 5, 10);
    }
    
    private void createFinishingActivities(ConstructionPhase phase) {
        createActivity(phase, "FINAL_FINISHING", "Final Finishing", "Finishing akhir", 1, 20);
        createActivity(phase, "CLEANING", "Final Cleaning", "Pembersihan akhir", 2, 5);
        createActivity(phase, "LANDSCAPING", "Landscaping", "Pekerjaan landscape", 3, 15);
        createActivity(phase, "FINAL_INSPECTION", "Final Inspection", "Inspeksi akhir", 4, 3);
        createActivity(phase, "HANDOVER_PREP", "Handover Preparation", "Persiapan serah terima", 5, 5);
    }
    
    private void createActivity(ConstructionPhase phase, String code, String name, 
                               String description, int sequence, int duration) {
        PhaseActivity activity = new PhaseActivity();
        activity.phase = phase;
        activity.activityCode = code;
        activity.activityName = name;
        activity.description = description;
        activity.sequenceOrder = sequence;
        activity.estimatedDurationDays = duration;
        activity.skillLevelRequired = SkillLevel.SKILLED;
        activity.crewSizeRequired = 5; // Default crew size
        act
