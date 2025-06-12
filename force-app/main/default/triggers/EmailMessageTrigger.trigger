trigger EmailMessageTrigger on EmailMessage (after insert) {
    if (Trigger.isAfter && Trigger.isInsert) {
        List<EmailMessage> newEmailMessages = Trigger.new;

        // Filter the EmailMessages that meet your criteria (e.g., Parent.Account.toBeDeleted__c = true)
        List<id> filteredEmailMessages = new List<id>();
        for (EmailMessage em : newEmailMessages) {
            if (em.Parent != null && em.Parent.Account != null && em.Parent.Account.toBeDeleted__c) {
                filteredEmailMessages.add(em.id);
            }
        }

        if (!filteredEmailMessages.isEmpty()) {
            try {
                // Instantiate and execute the batch class
                UpdateCaseEmail batchJob = new UpdateCaseEmail(filteredEmailMessages);
                Database.executeBatch(batchJob, 200);
            } catch (Exception e) {
                System.debug('Error in batch execution: ' + e.getMessage());
            }
        }
    }
}