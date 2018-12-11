#!/bin/sh

LOGO_ICNS="/Library/User Pictures/Custom/CoxAuto.tif"

PROMPT_TITLE="Enterprise Connect Connection"

PROMPT_MESSAGE="Enterprise Connect on your Cox Automotive Inc. issued computer has not properly communicated with the corporate network in 30 or more days.  Please connect to VPN (if remote) and open the Application \"Enterprise Connect\".

After successful connection, please stay connected for at least 30 minutes to ensure successful communications.

If you recieve this message after successfully connecting to Enterprise Connect, please open a ticket with your local Destktop Support Group to have them take a look at your machine."

jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"


"$jamfHelper" -windowType "utility" -icon "$LOGO_ICNS" -title "$PROMPT_TITLE" -description "$PROMPT_MESSAGE" -button1 'OK' -defaultButton 1 -timeout 300