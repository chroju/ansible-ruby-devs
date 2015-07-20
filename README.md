# ansible playbooks 

## about
This is my ansible playbooks for private use. if you want to use these files, you should custome some tasks and variables.

## what these playbooks do?

### vps_first.yml
This playbook is for first settings to development environment. It is assumed that you use root user. This is tested in Degital Ocean VPS (CentOS6), so include task which copy default authorized_keys file to not root user.

### vps_second.yml
This playbooks is for second settings to development environment. You should run this playbook after run `vps_first.yml`. In this playbook, `git clone` command would be runned, so public key is needed. `ansible.cfg` file contains command line options for ssh agent forward. You have to setting ssh-agent in your local machine.

### variables
Variables in these playbooks must be defined in `var/external_vars.yml` file.

## author
chroju http://chroju.net

