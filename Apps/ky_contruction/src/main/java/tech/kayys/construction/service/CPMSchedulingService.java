package tech.kayys.construction.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import jakarta.enterprise.context.ApplicationScoped;
import tech.kayys.project.domain.ActivityDependency;
import tech.kayys.project.domain.ProjectSchedule;
import tech.kayys.project.domain.ScheduleActivity;

@ApplicationScoped
public class CPMSchedulingService {
    
    public CriticalPathResult calculateCriticalPath(Long projectId) {
        ProjectSchedule schedule = ProjectSchedule.find("project.id = ?1 and isCurrent = true", projectId)
                .firstResult();
        
        if (schedule == null || schedule.activities.isEmpty()) {
            return new CriticalPathResult();
        }
        
        // Forward Pass - Calculate Early Start and Early Finish
        List<ScheduleActivity> sortedActivities = topologicalSort(schedule.activities);
        
        for (ScheduleActivity activity : sortedActivities) {
            // Early Start = max(Early Finish of all predecessors + lag)
            LocalDate earlyStart = LocalDate.now();
            for (ActivityDependency dep : activity.predecessors) {
                LocalDate predFinish = dep.predecessor.earlyFinish;
                if (predFinish != null) {
                    LocalDate depStart = predFinish.plusDays(dep.lagDuration);
                    if (depStart.isAfter(earlyStart)) {
                        earlyStart = depStart;
                    }
                }
            }
            activity.earlyStart = earlyStart;
            activity.earlyFinish = earlyStart.plusDays(activity.duration);
        }
        
        // Backward Pass - Calculate Late Start and Late Finish
        Collections.reverse(sortedActivities);
        LocalDate projectFinish = sortedActivities.get(0).earlyFinish;
        
        for (ScheduleActivity activity : sortedActivities) {
            // Late Finish = min(Late Start of all successors - lag)
            LocalDate lateFinish = projectFinish;
            for (ActivityDependency dep : activity.successors) {
                LocalDate succStart = dep.successor.lateStart;
                if (succStart != null) {
                    LocalDate depFinish = succStart.minusDays(dep.lagDuration);
                    if (depFinish.isBefore(lateFinish)) {
                        lateFinish = depFinish;
                    }
                }
            }
            activity.lateFinish = lateFinish;
            activity.lateStart = lateFinish.minusDays(activity.duration);
            
            // Calculate Float
            activity.totalFloat = (int) activity.earlyStart.until(activity.lateStart).getDays();
            activity.isCritical = activity.totalFloat == 0;
        }
        
        // Persist changes
        for (ScheduleActivity activity : schedule.activities) {
            activity.persist();
        }
        
        // Build result
        CriticalPathResult result = new CriticalPathResult();
        result.criticalActivities = schedule.activities.stream()
                .filter(a -> a.isCritical)
                .collect(Collectors.toList());
        result.totalDuration = (int) LocalDate.now().until(projectFinish).getDays();
        result.calculationDate = LocalDateTime.now();
        
        return result;
    }
    
    private List<ScheduleActivity> topologicalSort(List<ScheduleActivity> activities) {
        // Simplified topological sort implementation
        List<ScheduleActivity> sorted = new ArrayList<>();
        Set<ScheduleActivity> visited = new HashSet<>();
        
        for (ScheduleActivity activity : activities) {
            if (!visited.contains(activity)) {
                topologicalSortUtil(activity, visited, sorted);
            }
        }
        
        return sorted;
    }
    
    private void topologicalSortUtil(ScheduleActivity activity, Set<ScheduleActivity> visited, 
                                   List<ScheduleActivity> sorted) {
        visited.add(activity);
        
        for (ActivityDependency dep : activity.successors) {
            if (!visited.contains(dep.successor)) {
                topologicalSortUtil(dep.successor, visited, sorted);
            }
        }
        
        sorted.add(0, activity); // Add to beginning for reverse topological order
    }
    
    public static class CriticalPathResult {
        public List<ScheduleActivity> criticalActivities = new ArrayList<>();
        public int totalDuration;
        public LocalDateTime calculationDate;
    }
}
