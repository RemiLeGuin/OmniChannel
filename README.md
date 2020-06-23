# Omni-Channel

## Steps for delivery

1. Install the unlocked package:
   - [Developer Editions (Trailhead Playgrounds...)](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tB0000000cs16IAA "https://login.salesforce.com/packaging/installPackage.apexp?p0=04tB0000000cs16IAA")
   - [Sandboxes](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tB0000000cs16IAA "https://test.salesforce.com/packaging/installPackage.apexp?p0=04tB0000000cs16IAA")
2. Deploy the components from the manifest/package.xml
3. Create a remote site setting to authorize current Salesforce instance to make callouts to itself.
4. Add the chosen profiles to the "Omni-Channel" presence configuration.
5. Create test users with the right profiles and roles.
6. Assign the OC_Agent permission set to these users
7. Assign the OC_SkillManagement to your admin user or any user who need it.

## New package version

```
sfdx force:package:version:create --definitionfile config/project-scratch-def.json --package "Omni-Channel" --path omni-channel --apiversion 49.0 --installationkeybypass --wait 10 --codecoverage --releasenotesurl "https://github.com/RemiLeGuin/OmniChannel"
```