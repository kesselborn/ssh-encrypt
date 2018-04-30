# ssh-encrypt

## what

Small script to encrypt files with a ssh public key that can be decrypted with the according ssh private key

## dependencies

The receiving party needs to have `openssl` and `bash` or `zsh` on Linux or Mac installed.

## usage

    ./encrypt.sh <ssh public key> <file to be encrypted>

this will encrypt the passed in file and print instructions about how to decrypt the data with the private key again ... something like:

    $ ./encrypt.sh ./id_rsa.pub image.png
    Send this text to the receiving party:
    
    ------------------------------------------------------------------------------------------------------
    Save image.png.enc in a directory, copy/paste the following block (adjust SSH_PUBLIC_KEY
    and/or ENCRYPTED_FILE if necessary) and execute it in bash or zsh:
    
    
        SSH_PRIVATE_KEY=~/.ssh/id_rsa  # the ssh private key corresponding to the public key used to encrypt this file
        ENCRYPTED_FILE=./image.png.enc   # this file
    
        openssl aes-256-cbc -d -in <(cat ${ENCRYPTED_FILE:?}|tr -d "\n"|cut -f3|(base64 -D 2>/dev/null||base64 -d)) -pass pass:"$( printf "ssh private key passphrase (enter for no passphrase): " >&2; read -s pw; openssl rsautl -decrypt -oaep -passin pass:"${pw}" -inkey ${SSH_PRIVATE_KEY:?} -in <(cat ${ENCRYPTED_FILE:?}|tr -d "\n"|cut -f2|(base64 -D 2>/dev/null||base64 -d)))" -out image.png

The encrypted file will have instructions on how to decrypt it as well ... best show them by executing:

    head <encrypted-file>
