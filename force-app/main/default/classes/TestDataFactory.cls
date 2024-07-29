public class TestDataFactory {

    public static Account createAccount() {
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;
        return acc;
    }

    public static List<Account> createAccounts(Integer count) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i));
        }
        insert accounts;
        return accounts;
    }

    public static Contact createContact(Id accountId, String firstName, String lastName, String email) {
        Contact contact = new Contact(
            FirstName = firstName,
            LastName = lastName,
            Email = email,
            AccountId = accountId
        );
        insert contact;
        return contact;
    }

    public static List<Contact> createContacts(Integer count, List<Id> accountIds) {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < count; i++) {
            Contact contact = new Contact(
                FirstName = 'FirstName' + i,
                LastName = 'LastName' + i,
                Email = 'email' + i + '@example.com',
                AccountId = accountIds[Math.mod(i, accountIds.size())] 
            );
            contacts.add(contact);
        }
        insert contacts;
        return contacts;
    }

}