package tech.kayys.currency.resource;

import jakarta.annotation.security.RolesAllowed;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import tech.kayys.currency.domain.Currency;
import tech.kayys.currency.service.CurrencyConversionService;
import tech.kayys.currency.service.CurrencyService;
import tech.kayys.finance.domain.ExchangeRate;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import io.smallrye.mutiny.Uni;

@Path("/currencies")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class CurrencyResource {

    @Inject
    CurrencyService currencyService;

    @Inject
    CurrencyConversionService conversionService;

    // ---------------------------
    // Currency Management
    // ---------------------------

    @GET
    public Uni<List<Currency>> listActive() {
        return currencyService.listActive();
    }

    @GET
    @Path("/default")
    public Uni<Currency> getDefaultCurrency() {
        return currencyService.getDefaultCurrency();
    }

    @POST
    @Transactional
    @RolesAllowed({ "ADMIN" })
    public Uni<Response> create(Currency currency, @QueryParam("createdBy") String createdBy) {
        return Currency.persist(currency)
                .replaceWith(Response.status(Response.Status.CREATED).entity(currency).build());
    }

    @PUT
    @Path("/{id}/default")
    @Transactional
    @RolesAllowed({ "ADMIN" })
    public Uni<Response> setDefault(@PathParam("id") Long id, @QueryParam("updatedBy") String updatedBy) {
        return Currency.<Currency>findById(id) // 👈 force type to Currency
                .onItem().ifNull().failWith(() -> new NotFoundException("Currency not found"))
                .flatMap(currency -> currencyService.setDefaultCurrency(currency, updatedBy))
                .replaceWith(Response.ok().build());
    }

    @PUT
    @Path("/{id}/deactivate")
    @Transactional
    @RolesAllowed({ "ADMIN" })
    public Uni<Response> deactivate(@PathParam("id") Long id, @QueryParam("updatedBy") String updatedBy) {
        return currencyService.deactivate(id, updatedBy)
                .replaceWith(Response.ok().build());
    }

    // ---------------------------
    // Exchange Rate Queries
    // ---------------------------

    @GET
    @Path("/{fromCode}/{toCode}/history")
    public Uni<List<ExchangeRate>> getHistory(@PathParam("fromCode") String fromCode,
            @PathParam("toCode") String toCode) {
        return Currency.find("code", fromCode).firstResult()
                .flatMap(from -> Currency.find("code", toCode).firstResult()
                        .flatMap(to -> currencyService.getHistory((Currency) from, (Currency) to)));
    }

    // ---------------------------
    // Currency Conversion
    // ---------------------------

    @GET
    @Path("/convert")
    public Uni<Response> convert(@QueryParam("amount") BigDecimal amount,
            @QueryParam("from") String fromCode,
            @QueryParam("to") String toCode,
            @QueryParam("date") String dateStr) {
        LocalDate date = dateStr != null ? LocalDate.parse(dateStr) : LocalDate.now();

        return Currency.find("code", fromCode).firstResult()
                .flatMap(from -> Currency.find("code", toCode).firstResult()
                        .flatMap(to -> conversionService.convert(amount, (Currency) from, (Currency) to, date)))
                .map(converted -> Response.ok(converted).build());
    }
}
