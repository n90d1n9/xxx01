package tech.kayys.company.resource;

import java.util.List;

import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.WebApplicationException;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import tech.kayys.company.domain.Company;
import tech.kayys.company.dto.CreateCompanyRequest;
import tech.kayys.company.repository.CompanyRepository;

@Path("/api/companies")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class CompanyResource {
    
    @Inject
    CompanyRepository companyRepo;
    
    @GET
    public List<Company> getAllCompanies() {
        return companyRepo.listAll();
    }
    
    @GET
    @Path("/{id}")
    public Company getCompany(@PathParam("id") Long id) {
        Company company = companyRepo.findById(id);
        if (company == null) {
            throw new WebApplicationException("Company not found", Response.Status.NOT_FOUND);
        }
        return company;
    }
    
    @POST
    @Transactional
    public Response createCompany(@Valid CreateCompanyRequest request) {
        Company company = new Company();
        company.npwp = request.npwp;
        company.name = request.name;
        company.address = request.address;
        company.type = request.type;
        company.establishedDate = request.establishedDate;
        company.authorizedCapital = request.authorizedCapital;
        company.paidUpCapital = request.paidUpCapital;
        company.siup = request.siup;
        company.tdp = request.tdp;
        
        companyRepo.persist(company);
        return Response.status(Response.Status.CREATED).entity(company).build();
    }
}
