bootstrap:
    install xcode
    install brew

upgrade:
    ansible-playbook bootstrap/playbook.yaml -t packages
