package tech.kayys.notification.model;

public enum EmailPriority {
    HIGH(1),
    NORMAL(3),
    LOW(5);

    private final int level;

    EmailPriority(int level) {
        this.level = level;
    }

    public int getLevel() {
        return level;
    }
}
