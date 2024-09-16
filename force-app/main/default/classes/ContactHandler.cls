@RestResource(urlMapping='/CreateContacts')
global with sharing class ContactHandler {

    @HttpPost
    global static void createOrUpdateContact(String email, String firstName, String lastName) {
        // Préparer un objet pour la réponse JSON
        Map<String, Object> response = new Map<String, Object>();
        
        try {
            // Vérification que les paramètres sont non nuls
            if (email == null || firstName == null || lastName == null) {
                // Ajout de message d'erreur dans la réponse JSON
                response.put('status', 'error');
                response.put('message', 'Parameters email, firstName, and lastName must not be null.');
                RestContext.response = new RestResponse();
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(response));
                return; // Arrêt de l'exécution si un paramètre est manquant
            }

            // Rechercher un contact par email
            List<Contact> contacts = [SELECT Id, FirstName, LastName, Email, IsActive__c FROM Contact WHERE Email = :email LIMIT 1];
            
            if (contacts.size() > 0) {
                // Si le contact existe, mettre à jour ses informations uniquement si elles ont changé
                Contact existingContact = contacts[0];
                Boolean isUpdated = false;
                
                if (existingContact.FirstName != firstName) {
                    existingContact.FirstName = firstName;
                    isUpdated = true;
                }
                
                if (existingContact.LastName != lastName) {
                    existingContact.LastName = lastName;
                    isUpdated = true;
                }

                if (!existingContact.IsActive__c) {
                    existingContact.IsActive__c = true; // Réactiver le contact s'il était désactivé
                    isUpdated = true;
                }

                if (isUpdated) {
                    update existingContact;
                    response.put('status', 'success');
                    response.put('message', 'Contact updated successfully.');
                    response.put('operation', 'update');
                } else {
                    response.put('status', 'success');
                    response.put('message', 'No fields updated.');
                    response.put('operation', 'no_update');
                }

                response.put('contactId', existingContact.Id);
            } else {
                // Créer un nouveau contact
                Contact newContact = new Contact(
                    FirstName = firstName,
                    LastName = lastName,
                    Email = email,
                    IsActive__c = true // Assure que le contact est actif par défaut
                );
                insert newContact;

                // Ajouter des informations dans la réponse
                response.put('status', 'success');
                response.put('message', 'Contact created successfully.');
                response.put('contactId', newContact.Id);
                response.put('operation', 'create');
            }
        } catch (Exception e) {
            // En cas d'erreur, ajouter des informations sur l'exception dans la réponse
            response.put('status', 'error');
            response.put('message', 'An error occurred: ' + e.getMessage());
        }
        
        // Configurer la réponse HTTP pour renvoyer du JSON proprement formaté
        if (RestContext.response == null) {
            RestContext.response = new RestResponse(); // Initialisation de RestContext.response si non défini
        }
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(response));
    }
}
