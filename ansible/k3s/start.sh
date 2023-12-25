#!/bin/bash
ssh-copy-id adminotel@$(cat host | grep -o -E '([0-9]{1,3}[\.]){3}[0-9]{1,3}' | head -1)
ssh-copy-id adminotel@$(cat host | grep -o -E '([0-9]{1,3}[\.]){3}[0-9]{1,3}' | tail -1)
ansible-playbook -i host k3s_start.yml -K
