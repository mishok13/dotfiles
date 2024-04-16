function dauth_acc {
    curl -s -X POST -d "grant_type=password&username=mishk500&password=$(op item get ixp54ndrrk5afvw2jlpairykcy --fields password)&scope=openid profile email groups" -u "277447:" https://d-auth-acceptance.tcloud-acc1.np.aws.kpn.org/openid/token/ | jq '("Bearer " + .access_token)' -r
}

function keepass_auth {
    op read op://KPN/Keepass/password
}

VAULT_ADDRESS_PROD=https://de-vault-production.tcloud-de-prd1.prod.aws.kpn.org/
VAULT_ADDRESS_ACC=https://de-vault-acceptance.tcloud-de-acc1.np.aws.kpn.org/
VAULT_ADDRESS_DEV=https://de-vault-tst.tcloud-de-dev1.np.aws.kpn.org/

function vault_login {
    printf "Logging into vault($1)\n" 1>&2
    case $1 in
        prod)
            export VAULT_ADDR=$VAULT_ADDRESS_PROD
            ;;
        acc)
            export VAULT_ADDR=$VAULT_ADDRESS_ACC
            ;;
        dev)
            export VAULT_ADDR=$VAULT_ADDRESS_DEV
            ;;
        *)
            echo "Unknown environment"
            ;;
    esac
    password=`op item get ixp54ndrrk5afvw2jlpairykcy --fields password`
    export VAULT_TOKEN=`vault login -token-only -address $VAULT_ADDR -method ldap username=mishk500 password=$password`
    unset password
}

function vault_prod {
    vault_login prod
}

function vault_acc {
    vault_login acc
}

function vault_dev {
    vault_login dev
}

export AWS_PAGER="eza -ljson"

if type colima &>/dev/null
then
    export DOCKER_HOST=unix:///Users/andriimishkovskyi/.colima/default/docker.sock
fi

function zipped_creds {
    env=$1
    app=$2
    zip_path=$2-$1.zip
    printf "Zipping credentials for application $app in $env\n" 1>&2
    vault_login $env
    client_id=`vault kv get -field client_id secret/conductor-external-apps/$app-credentials`
    passphrase=`openssl rand -hex 32`
    printf "Client id is ${client_id} Password is: ${passphrase}  \n"
    rm -rf client_secret.txt
    mkfifo client_secret.txt
    vault kv get -field client_secret secret/conductor-external-apps/$app-credentials >client_secret.txt&
    zip -e -FI $zip_path client_secret.txt
    rm -rf client_secret.txt
    printf "File has been written to $zip_path\n"
}
