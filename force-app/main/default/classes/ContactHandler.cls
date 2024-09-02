@RestResource(urlMapping='/CreateContacts')
global with sharing class ContactHandler {

    @HttpPost
    global static String createOrUpdateContact(String email, String firstName, String lastName) {
        // Rechercher un contact par email
        List<Contact> contacts = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Email = :email LIMIT 1];
        
        // Si le contact existe, mettre à jour ses informations
        if (contacts.size() > 0) {
            Contact existingContact = contacts[0];
            return 'retrieve '+ existingContact.Id;
        } 
        // Sinon, créer un nouveau contact
        else {
            Contact newContact = new Contact(
                FirstName = firstName,
                LastName = lastName,
                Email = email
            );
            insert newContact;
            return 'create '+newContact.Id;
        }
    }
}
