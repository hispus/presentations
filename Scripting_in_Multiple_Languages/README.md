# Scripting in Multiple Languages

In order to set up your DHIS2 installation to run the code in this repository, you must set up the DHIS2 Datastore namespace and key.

*Instructions:*
1. open your DHIS2 installation
2. open the app *Datastore Manager*
3. click the New button
4. for Namespace, write `assignments`
5. for Key name, write `organisationUnitLevels` (note the British spelling)
6. click on `organisationUnitLevels`
7. click on `Tree` and change it to `Code`
8. delete the `{}` that is currently present
9. copy [the code from datastore.json](https://github.com/hispus/presentations/tree/master/Scripting_in_Multiple_Languages/datastore.json) and paste it in
10. click the disk icon, which saves the code
11. if you see, `Value saved` at the bottom of the screen, it probably worked

In order to run any of the code, you must fill in `yourname`.

Note that the code present does not work with DHIS 2.31 and higher.  Jira ticket forthcoming.