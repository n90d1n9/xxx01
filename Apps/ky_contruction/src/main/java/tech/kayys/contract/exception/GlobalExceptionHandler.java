package tech.kayys.contract.exception;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

import jakarta.persistence.EntityNotFoundException;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

@Provider
public class GlobalExceptionHandler implements ExceptionMapper<Exception> {
    
    @Override
    public Response toResponse(Exception exception) {
        Map<String, Object> error = new HashMap<>();
        error.put("success", false);
        error.put("message", exception.getMessage());
        error.put("timestamp", LocalDateTime.now());
        
        if (exception instanceof IllegalArgumentException) {
            return Response.status(400).entity(error).build();
        } else if (exception instanceof EntityNotFoundException) {
            error.put("message", "Data tidak ditemukan");
            return Response.status(404).entity(error).build();
        } else {
            error.put("message", "Terjadi kesalahan sistem");
            return Response.status(500).entity(error).build();
        }
    }
}
