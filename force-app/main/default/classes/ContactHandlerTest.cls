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

        // Initialiser RestContext pour la requête HTTP
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
        ContactHandler.createOrUpdateContact(email, firstName, lastName);
        Test.stopTest();
        
        // Vérifier que le contact a été créé
        Contact createdContact = [SELECT Id, FirstName, LastName, Email, IsActive__c FROM Contact WHERE Email = :email];
        System.assertEquals(firstName, createdContact.FirstName);
        System.assertEquals(lastName, createdContact.LastName);
        System.assertEquals(email, createdContact.Email);
        System.assertEquals(true, createdContact.IsActive__c, 'Le contact devrait être actif.');
    }

    @isTest
    static void testUpdateExistingContact() {
        // Cas 2: Mise à jour d'un contact existant
        String email = 'testuser@example.com';
        String newFirstName = 'Updated';
        String lastName = 'User';
        
        // Initialiser RestContext pour la requête HTTP
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CreateContacts';
        req.httpMethod = 'POST';
        req.addParameter('email', email);
        req.addParameter('firstName', newFirstName);
        req.addParameter('lastName', lastName);
        
        Test.startTest();
        RestContext.request = req;
        RestContext.response = res;
        ContactHandler.createOrUpdateContact(email, newFirstName, lastName);
        Test.stopTest();
        
        // Vérifier que le contact a été mis à jour
        Contact existingContact = [SELECT Id, FirstName, LastName, Email, IsActive__c FROM Contact WHERE Email = :email];
        System.assertEquals(newFirstName, existingContact.FirstName, 'Le prénom devrait être mis à jour.');
        System.assertEquals(lastName, existingContact.LastName, 'Le nom ne devrait pas être modifié.');
        System.assertEquals(true, existingContact.IsActive__c, 'Le contact devrait être actif.');
    }

    @isTest
    static void testReactivateContact() {
        // Cas 3: Réactivation d'un contact désactivé
        String email = 'testuser@example.com';

        // Désactiver un contact existant
        Contact existingContact = [SELECT Id, FirstName, LastName, Email, IsActive__c FROM Contact WHERE Email = :email];
        existingContact.IsActive__c = false;
        update existingContact;

        // Initialiser RestContext pour la requête HTTP
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CreateContacts';
        req.httpMethod = 'POST';
        req.addParameter('email', email);
        req.addParameter('firstName', existingContact.FirstName);
        req.addParameter('lastName', existingContact.LastName);
        
        Test.startTest();
        RestContext.request = req;
        RestContext.response = res;
        ContactHandler.createOrUpdateContact(email, existingContact.FirstName, existingContact.LastName);
        Test.stopTest();
        
        // Vérifier que le contact a été réactivé
        Contact reactivatedContact = [SELECT Id, FirstName, LastName, Email, IsActive__c FROM Contact WHERE Email = :email];
        System.assertEquals(true, reactivatedContact.IsActive__c, 'Le contact devrait être réactivé.');
    }
}
