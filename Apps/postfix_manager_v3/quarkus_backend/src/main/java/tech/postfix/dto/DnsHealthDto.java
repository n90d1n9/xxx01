  public record DnsHealthDto(
            String spf, String dkim, String dmarc, String mx, String rdns,
            String spfRecord, String dmarcRecord, List<MxRecordDto> mxRecords,
            String rdnsResult, String dkimSelector) {}

  