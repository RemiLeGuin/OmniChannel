# Omni-Channel

## Steps for delivery

1. Install the unlocked package:
   - [Developer Editions (Trailhead Playgrounds...)](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tB0000000crnVIAQ "https://login.salesforce.com/packaging/installPackage.apexp?p0=04tB0000000crnVIAQ")
   - [Sandboxes](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tB0000000crnVIAQ "https://test.salesforce.com/packaging/installPackage.apexp?p0=04tB0000000crnVIAQ")
2. Deploy the components from the manifest/package.xml
3. Create a remote site setting to authorize current Salesforce instance to make callouts to itself.
4. Add the chosen profiles to the "Omni-Channel" presence configuration.
5. Create test users with the right profiles and roles.
6. Assign the OC_Agent permission set to these users
7. Assign the OC_SkillManagement to your admin user or any user who need it.