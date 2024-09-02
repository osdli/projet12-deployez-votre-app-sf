@IsTest
public class ContactHandlerTest {

    @testSetup
    static void setup() {
        // Créer un compte de test
        Account testAccount = TestDataFactory.createAccount();
        
        // Créer un contact de test pour les mises à jour
        TestDataFactory.createContact(testAccount.Id, 'Test', 'User', 'testuser@example.com');
    }

    @isTest
    static void testCreateContact() {
        // Cas 1: Création d'un nouveau contact
        String email = 'newuser@example.com';
        String firstName = 'New';
        String lastName = 'User';
        
        Test.startTest();
        String result = ContactHandler.createOrUpdateContact(email, firstName, lastName);
        Test.stopTest();
        
        // Vérifier que le contact a été créé
        String[] resultParts = result.split(' ');
        String operation = resultParts[0];
        String contactId = resultParts[1];
        
        System.assertEquals('create', operation, 'Le contact devrait être créé.');
        
        Contact createdContact = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id = :contactId];
        System.assertEquals(firstName, createdContact.FirstName);
        System.assertEquals(lastName, createdContact.LastName);
        System.assertEquals(email, createdContact.Email);
    }

    @isTest
    static void testRetrieveExistingContact() {
        // Cas 2: Récupération d'un contact existant
        String email = 'testuser@example.com';
        String firstName = 'Updated';
        String lastName = 'User';
        
        Test.startTest();
        String result = ContactHandler.createOrUpdateContact(email, firstName, lastName);
        Test.stopTest();
        
        // Vérifier que le contact a été récupéré
        String[] resultParts = result.split(' ');
        String operation = resultParts[0];
        String contactId = resultParts[1];
        
        System.assertEquals('retrieve', operation, 'Le contact devrait être récupéré.');
        
        Contact existingContact = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id = :contactId];
        System.assertEquals('Test', existingContact.FirstName); // Le prénom ne devrait pas être mis à jour
        System.assertEquals('User', existingContact.LastName);
        System.assertEquals(email, existingContact.Email);
    }

    @isTest
    static void testCreateContactViaPost() {
        // Cas 3: Création d'un nouveau contact via le service Web
        String email = 'newuser@example.com';
        String firstName = 'New';
        String lastName = 'User';

        // Simuler une requête HTTP POST
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CreateContacts';
        req.httpMethod = 'POST';
        req.addParameter('email', email);
        req.addParameter('firstName', firstName);
        req.addParameter('lastName', lastName);

        Test.startTest();
        RestContext.request = req;
        RestContext.response = res;
        String result = ContactHandler.createOrUpdateContact(email, firstName, lastName);
        Test.stopTest();
        
        // Vérifier que le contact a été créé
        String[] resultParts = result.split(' ');
        String operation = resultParts[0];
        String contactId = resultParts[1];
        
        System.assertEquals('create', operation, 'Le contact devrait être créé.');
        
        Contact createdContact = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id = :contactId];
        System.assertEquals(firstName, createdContact.FirstName);
        System.assertEquals(lastName, createdContact.LastName);
        System.assertEquals(email, createdContact.Email);
    }

    @isTest
    static void testRetrieveExistingContactViaPost() {
        // Cas 4: Récupération d'un contact existant via le service Web
        String email = 'testuser@example.com';
        String firstName = 'Updated';
        String lastName = 'User';

        // Simuler une requête HTTP POST
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CreateContacts';
        req.httpMethod = 'POST';
        req.addParameter('email', email);
        req.addParameter('firstName', firstName);
        req.addParameter('lastName', lastName);

        Test.startTest();
        RestContext.request = req;
        RestContext.response = res;
        String result = ContactHandler.createOrUpdateContact(email, firstName, lastName);
        Test.stopTest();
        
        // Vérifier que le contact a été récupéré
        String[] resultParts = result.split(' ');
        String operation = resultParts[0];
        String contactId = resultParts[1];
        
        System.assertEquals('retrieve', operation, 'Le contact devrait être récupéré.');
        
        Contact existingContact = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id = :contactId];
        System.assertEquals('Test', existingContact.FirstName); // Le prénom ne devrait pas être mis à jour
        System.assertEquals('User', existingContact.LastName);
        System.assertEquals(email, existingContact.Email);
    }
}
