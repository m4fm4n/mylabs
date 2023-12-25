#!/bin/bash
ssh-copy-id adminotel@$(tail -n 1 host)
ansible-playbook -i host jenk_dock.yml -K
