#!/bin/bash

set -e -o pipefail

usage() {
cat<<EOF


Usage: $0 SSH_PUBLIC_KEY FILE

EOF
}

PUBLIC_KEY=$1
FILE=$2


test -n "${PUBLIC_KEY:?"$(usage)"}"
test -n "${FILE:?"$(usage)"}"

SECRET=$(openssl rand 32 -base64)
ENCRYPTED_SECRET=$(openssl rsautl -encrypt -oaep -pubin -inkey <(ssh-keygen -e -f ${PUBLIC_KEY} -m PKCS8) -in <(echo ${SECRET}|(base64 -D 2>/dev/null||base64 -d))|base64)
test -n "${ENCRYPTED_SECRET}"


instructions=$(cat<<EOF

    SSH_PRIVATE_KEY=~/.ssh/id_rsa    # the ssh private key corresponding to the public key used to encrypt this file
    ENCRYPTED_FILE="./${FILE}.enc"   # this file

    openssl aes-256-cbc -d -in <(cat "\${ENCRYPTED_FILE:?}"|tr -d "\n"|cut -f3|(base64 -D 2>/dev/null||base64 -d)) -pass pass:"\$( printf "ssh private key passphrase (enter for no passphrase): " >&2; read -s pw; openssl rsautl -decrypt -oaep -passin pass:"\${pw}" -inkey \${SSH_PRIVATE_KEY:?} -in <(cat "\${ENCRYPTED_FILE:?}"|tr -d "\n"|cut -f2|(base64 -D 2>/dev/null||base64 -d)))" -out "${FILE}"

EOF
)

printf "\nDecrypt this file as follows (granted you have the correct private ssh key):\n\n%s\n\n\n\n\n\t%s\t%s" "${instructions}" "${ENCRYPTED_SECRET}" "$(openssl aes-256-cbc -in "${FILE}" -pass file:<(echo ${SECRET} | (base64 -D 2>/dev/null||base64 -d))|base64)" > "${FILE}.enc"

cat<<EOF
Send this text to the receiving party:

------------------------------------------------------------------------------------------------------
Save "${FILE}.enc" in a directory, copy/paste the following block (adjust SSH_PUBLIC_KEY
and/or ENCRYPTED_FILE if necessary) and execute it in bash or zsh:

${instructions}

EOF
