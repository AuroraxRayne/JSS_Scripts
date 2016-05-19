#!/bin/sh


/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -users USER1,USER2,casperscreensharing,USER3 -privs -all -restart -agent
