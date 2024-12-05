trigger ContactTrigger on Contact (after update) {
    new ContactTriggerHandler().execute();
}