package tech.kayys.project.model;

import java.util.List;

public class PagedResponse<T> {
    public List<T> data;
    public long total;
    public int page;
    public int size;

    public PagedResponse(List<T> data, long total, int page, int size) {
        this.data = data;
        this.total = total;
        this.page = page;
        this.size = size;
    }
}
