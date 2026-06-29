package tech.kayys.currency.model;

public enum CurrencyCode {
    IDR("Indonesian Rupiah"),
    USD("US Dollar"),
    EUR("Euro"),
    SGD("Singapore Dollar");

    private final String description;

    CurrencyCode(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}
