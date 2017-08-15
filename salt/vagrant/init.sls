vagrant-user:
  user.present:
    - name: vagrant
    - shell: /bin/bash
    - home: /home/vagrant
    - createHome: True
  file.directory:
    - name: /home/vagrant/.ssh
    - user: vagrant
    - group: vagrant
    - mode: 0700
  cmd.run:
    - name: |
        chmod 600 /etc/sudoers
        echo "vagrant ALL=(ALL) NOPASSWD:ALL" | tee -a /etc/sudoers
        echo "Defaults:vagrant !requiretty" | tee -a /etc/sudoers
        chmod 400 /etc/sudoers
    - runas: root

vagrant-authorized-keys:
  file.managed:
    - name: /home/vagrant/.ssh/authorized_keys
    - source: salt://vagrant/files/authorized_keys
    - user: vagrant
    - group: vagrant
    - mode: 0600

vagrant-hgfs:
  file.directory:
    - name: /mnt/hgfs
    - user: root
    - group: root
    - mode: 0755
