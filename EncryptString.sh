#!/bin/bash
# Use 'openssl' to create an encrypted Base64 string for script parameters
# Additional layer of security when passing account credentials from the JSS to a client

# Use GenerateEncryptedString() locally - DO NOT include in the script!
# The 'Encrypted String' will become a parameter for the script in the JSS
# The unique 'Salt' and 'Passphrase' values will be present in your script
function GenerateEncryptedString() {
    # Usage ~$ GenerateEncryptedString "String"
    local STRING="${1}"
    local SALT=$(openssl rand -hex 8)
    local K=$(openssl rand -hex 12)
    local ENCRYPTED=$(echo "${STRING}" | openssl enc -aes256 -a -A -S "${SALT}" -k "${K}")
    echo "Encrypted String: ${ENCRYPTED}"
    echo "Salt: ${SALT} | Passphrase: ${K}"
}

GenerateEncryptedString "password"