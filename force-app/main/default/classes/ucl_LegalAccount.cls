public with sharing class ucl_LegalAccount {
    public String AccountNumber;
    public String AccountName;
    public String AccountStatus;
    public String AsOfDate;
    public List<Client> Clients;

    public ucl_LegalAccount() {

    }

    public class Client {
        public String FirstName;
        public String LastName;
        public String Email;
        public String Phone;
        public String Address;
        public String ClientNumber;
    }
}
