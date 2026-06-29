  public record CreateMailboxRequest(String email, String password,
            int quotaMb, String forwardTo) {}
   