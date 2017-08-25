interface-discovery-default:
  file.managed:
    - name: /etc/default/interface-discovery.sh
    - source: salt://interface-discovery/files/interface-discovery.sh
    - user: root
    - group: root
    - mode: 0750

interface-discovery-network-service-overide-dir:
  file.directory:
    - name: /etc/systemd/system/network.service.d
    - user: root
    - group: root
    - mode: 0755

interface-discovery-networking-service-override:
  file.managed:
    - name: /etc/systemd/system/network.service.d/interface-discovery.conf
    - source: salt://interface-discovery/files/interface-discovery.conf
    - user: root
    - group: root
    - mode: 0644

interface-discovery-service:
  file.managed:
    - name: /etc/systemd/system/interface-discovery.service
    - source: salt://interface-discovery/files/interface-discovery.service
    - user: root
    - group: root
    - mode: 0644

interface-discovery-reload-systemd:
  cmd.run:
    - name: |
        systemctl daemon-reload
        systemctl enable interface-discovery
    - runas: root
