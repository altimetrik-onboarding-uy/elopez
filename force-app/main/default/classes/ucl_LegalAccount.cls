public with sharing class ucl_LegalAccount {
    public String accountNumber;
    public String accountName;
    public String accountStatus;
    public String asOfDate;
    public List<Client> clients;

    public ucl_LegalAccount() {

    }

    public class Client {
        public String firstName;
        public String lastName;
        public String email;
        public String phone;
        public String address;
        public String clientNumber;
    }
}
