 public record TlsTestResultDto(boolean connected, String protocol, String cipher,
            boolean certValid, String error) {}
