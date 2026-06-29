package com.postfix.service;

import com.postfix.dto.Dtos.*;
import jakarta.enterprise.context.ApplicationScoped;
import org.jboss.logging.Logger;
import javax.naming.NamingException;
import javax.naming.directory.*;
import java.net.InetAddress;
import java.util.*;

@ApplicationScoped
public class DnsService {

    private static final Logger LOG = Logger.getLogger(DnsService.class);

    public DnsHealthDto check(String domain) {
        String spf    = checkSpf(domain);
        String dkim   = checkDkim(domain, "default");
        String dmarc  = checkDmarc(domain);
        String mx     = checkMx(domain).isEmpty() ? "fail" : "pass";
        String rdns   = checkRdns(domain);
        List<MxRecordDto> mxRecords = checkMx(domain);
        String spfRecord   = getSpfRecord(domain);
        String dmarcRecord = getDmarcRecord(domain);

        return new DnsHealthDto(spf, dkim, dmarc, mx, rdns,
                spfRecord, dmarcRecord, mxRecords, null, "default");
    }

    private String checkSpf(String domain) {
        try {
            String record = getTxtRecord(domain);
            if (record != null && record.startsWith("v=spf1")) return "pass";
            return "fail";
        } catch (Exception e) { return "unknown"; }
    }

    private String getSpfRecord(String domain) {
        try { return getTxtRecord(domain); } catch (Exception e) { return null; }
    }

    private String checkDkim(String domain, String selector) {
        try {
            String record = getTxtRecord(selector + "._domainkey." + domain);
            return (record != null && record.contains("v=DKIM1")) ? "pass" : "fail";
        } catch (Exception e) { return "none"; }
    }

    private String checkDmarc(String domain) {
        try {
            String record = getTxtRecord("_dmarc." + domain);
            return (record != null && record.startsWith("v=DMARC1")) ? "pass" : "fail";
        } catch (Exception e) { return "none"; }
    }

    private String getDmarcRecord(String domain) {
        try { return getTxtRecord("_dmarc." + domain); } catch (Exception e) { return null; }
    }

    private List<MxRecordDto> checkMx(String domain) {
        try {
            InitialDirContext ctx = new InitialDirContext();
            Attributes attrs = ctx.getAttributes("dns:/" + domain, new String[]{"MX"});
            Attribute mxAttr = attrs.get("MX");
            if (mxAttr == null) return Collections.emptyList();
            List<MxRecordDto> records = new ArrayList<>();
            var en = mxAttr.getAll();
            while (en.hasMore()) {
                String mxEntry = en.next().toString().trim();
                String[] parts = mxEntry.split("\\s+");
                if (parts.length >= 2) {
                    int priority = Integer.parseInt(parts[0]);
                    String host = parts[1].replaceAll("\\.$", "");
                    String ip = resolveIp(host);
                    records.add(new MxRecordDto(priority, host, ip));
                }
            }
            records.sort(Comparator.comparingInt(MxRecordDto::priority));
            return records;
        } catch (Exception e) {
            LOG.debugf("MX lookup failed for %s: %s", domain, e.getMessage());
            return Collections.emptyList();
        }
    }

    private String checkRdns(String domain) {
        try {
            InetAddress addr = InetAddress.getByName("mail." + domain);
            String ptr = addr.getCanonicalHostName();
            return ptr.contains(domain) ? "pass" : "fail";
        } catch (Exception e) { return "unknown"; }
    }

    private String getTxtRecord(String name) throws NamingException {
        InitialDirContext ctx = new InitialDirContext();
        Attributes attrs = ctx.getAttributes("dns:/" + name, new String[]{"TXT"});
        Attribute txt = attrs.get("TXT");
        if (txt == null) return null;
        return txt.get().toString().replaceAll("\"", "");
    }

    private String resolveIp(String host) {
        try { return InetAddress.getByName(host).getHostAddress(); }
        catch (Exception e) { return null; }
    }
}
