package tech.kayys.project.dto;

import io.smallrye.mutiny.Uni;

public record TaskProgressDTO(
        Long projectId,
        int totalTasks,
        int completed,
        double completionRate,
        int inProgress,
        int notStarted
) {

      
    public static Uni<TaskProgressDTO> fromRepoCounts(
            Uni<Long> totalUni,
            Uni<Long> completedUni,
            Uni<Long> inProgressUni,
            Uni<Long> notStartedUni,
            Long projectId
    ) {
        return Uni.combine().all().unis(totalUni, completedUni, inProgressUni, notStartedUni).asTuple()
                .map(t -> new TaskProgressDTO(
                        projectId,
                        t.getItem1().intValue(),
                        t.getItem2().intValue(),
                        t.getItem1() == 0 ? 0.0 : ((double) t.getItem2()) / t.getItem1(),
                        t.getItem3().intValue(),
                        t.getItem4().intValue()
                ));
    }
}