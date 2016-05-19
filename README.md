# JSS_Scripts

This is a collection of Scripts I have created and use in my JSS

<h4>Add.ADPassMon.to.Startup.sh</h4>
This script will add ADPassMon to the Startup Items for a user.

<h4>Alert.New.App.sh</h4>
This will pop up a windwo to a user when a new file is cached on the machine.  

<h4>Auto.Set.Time.Zone.sh</h4>
This will set the computer Time Zone to hardcoded values. 

<h4>Change.Password.Interval.sh</h4>
This will change the Computer Password Change Interval for AD bond machines.

<h4>Check.AppleSetupDone.sh</h4>
This will check to see if the AppleSetupDone file exists.

<h4>Check.for.Install.sh</h4>
This will pop up a message stating whether a new Application was installed successfully or not.  This is meant to be used in conjunction with the completion of an App install via JSS Self Service.

<h4>Create.Hidden.Account.sh</h4>
This script will create a hidden account, make that account an admin and allow it full access for ARD.

<h4>Disable.iCloud.signin.sh</h4>
This will edit the User Template to make it so the iCloud signin window doesn't appear.

<h4>Disable.Password.Prompt.sh</h4>
This will modifiy the com.apple.loginwindow plist file to not show any password prompts when a computer is bond to AD and the users password is going to expire.

<h4>Disable.Proxy.sh</h4>
This script will disable any proxy setup on any installed Network Interfaces.

<h4>FV.Recovery.Key.sh</h4>
This script will allow a user to update the Recovery Key that is stored in the JSS.

<h4>Fix.Admins.sh</h4>
This script will restart the ARD Services and set full access to the users listed.

<h4>Fix.MDM.sh</h4>
This will remove MDM Profile and re-add profiles.

<h4>Fix.jamf.Permissions.sh</h4>
This will reset permissions on jamf binary folders/files.

<h4>FixKeychain.sh</h4>
This script will delete local items keychain and keychain for the logged in user.

<h4>Flush.Policy.Logs.sh</h4>
This will flush policy logs for the machine you are running from.

<h4>Force.HomePage.sh</h4>
This script will force the homepage in Firefox, Safari and Chrome.

<h4>Kill.App</h4>
This will kill a specified Application.

<h4>Kill.Apple.Stuff.sh</h4>
This will kill iTunes, and Safari.

<h4>Migrate.to.New.Domain.sh</h4>
This will unbind and rebind a machine from one domain to another.

<h4>Office.2011.Uninstall.sh</h4>
This will remove all of Office 2011 including User Data Folder.

