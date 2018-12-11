#!/bin/sh

if [[ -e /Applications/"Adobe Reader.app" ]] || [[ -e /Applications/"Adobe Reader — \`.app" ]] || [[ -e /Applications/"Adobe Reader — Windows 10 x64.app" ]] || [[ -e /Applications/"Adobe Reader — Windows 7 x64.app" ]] || [[ -e /Applications/"Adobe Reader — Windows 7.app" ]]; then
	echo "Lets Remove Reader"
	rm -rf /Applications/"Adobe Reader"*
fi

if [[ -e /Applications/"Adobe Acrobat Reader DC.app" ]]; then
	echo "Remove Reader DC"
	rm -rf /Applications/"Adobe Acrobat Reader DC.app"
fi

if [[ -e /Applications/"Acrobat Reader.app" ]]; then
	echo "Remove Reader"
	rm -rf /Applications/"Acrobat Reader.app"
fi

#Remove additional Files
echo "Removing Support Files"

rm -rf /Library/Application\ Support/Adobe/Reader/*

rm -rf /Library/Internet\ Plug-Ins/AdobePDFViewer.plugin
rm -rf /Library/Internet\ Plug-Ins/AdobePDFViewerNPAPI.plugin

rm -rf /Library/Preferences/com.adobe.reader.*.WebResource.plist
rm -rf /Library/Preferences/com.adobe.acrobat.pdfviewer.plist

rm -rf /Library/Application\ Support/Adobe/ARMDC/Registered\ Products/com.adobe.reader.*.plist
rm -rf /Library/Application\ Support/Adobe/ARMDC/Registered\ Products/com.adobe.reader.servicesupdater.*.plist

echo "Done"

#Kill all Adobe Products open
echo "Killing Adobe Products if any are open"
ps aux | awk '/Adobe/ {print $2}' | xargs kill


exit 0
