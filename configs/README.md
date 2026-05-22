# 📁 configs/
 
Esta carpeta centraliza toda la documentación técnica, archivos de configuración y scripts de automatización de cada componente de la infraestructura. Está organizada por máquina/servicio para facilitar la navegación y el mantenimiento.
 

 
## 🖧 ubuntu-router
 
**IP:** `192.168.10.1 / 192.168.20.1 / 192.168.30.1` · **SO:** Ubuntu Server 22.04 LTS
 
Actúa como núcleo de la infraestructura. Gestiona el enrutamiento entre las tres subredes, el acceso a internet y la seguridad perimetral.
 
| Servicio | Descripción |
|----------|-------------|
| **Netplan** | Configuración de las 4 interfaces de red (WAN + 3 subredes internas) |
| **IP Forwarding** | Enrutamiento entre subredes activado vía `sysctl` |
| **isc-dhcp-server** | Asignación dinámica de IPs con reservas MAC para todos los servidores |
| **Technitium DNS** | Resolución de nombres interna (`jankesto.local`) + forwarders a `8.8.8.8` y `1.1.1.1` |
| **nftables** | Firewall con política `deny-all` por defecto y excepciones explícitas por subred |
| **Suricata** | IDS/IPS monitorizando la interfaz WAN con ruleset Emerging Threats |
 
### Scripts de automatización
 
La subcarpeta [`backups-automatizacion/scripts/`](ubuntu-router/backups-automatizacion/scripts/) contiene scripts numerados para reproducir toda la configuración del router desde cero:
 
| Script | Función |
|--------|---------|
| `01-base.sh` | Configuración base: interfaces (Netplan) e IP forwarding |
| `02-dhcp.sh` | Instalación y configuración de `isc-dhcp-server` con todas las reservas |
| `03-dns.sh` | Instalación de Technitium DNS y zona `jankesto.local` |
| `04-nftables.sh` | Aplicación de las reglas de firewall y NAT |
| `05-suricata.sh` | Instalación de Suricata y configuración sobre `enp1s0` |
 
Los backups de los archivos de configuración resultantes se guardan en [`backups-automatizacion/configs/`](ubuntu-router/backups-automatizacion/configs/).
 
---
 
## 🟢 wazuh
 
**IP:** `192.168.10.10` · **SO:** Ubuntu Server 22.04 LTS
 
Servidor central del SOC. Ejecuta el stack completo de Wazuh (Manager + Indexer + Dashboard) y recibe eventos de todos los agentes desplegados en la red.
 
| Agente | Host | IP | Subred |
|--------|------|----|--------|
| Agent 1 | `client-user1` | `192.168.20.101` | Usuaris |
| Agent 2 | `client-user2` | `192.168.20.100` | Usuaris |
| Agent 3 | `dmz-host1` | `192.168.30.10` | DMZ |
| Agent 4 | `dmz-host2` | `192.168.30.20` | DMZ |
 
Consulta [`wazuh/config.md`](wazuh/config.md) para la guía de instalación completa y [`wazuh/dashboard-screenshots/`](wazuh/dashboard-screenshots/) para las evidencias del SOC en funcionamiento.
 
---
 
## 🔴 dmz
 
**Subred:** `192.168.30.0/24` · Aislada del resto mediante reglas `nftables`
 
Aloja los servicios expuestos de la organización. Ambos hosts tienen el agente Wazuh instalado para monitorización activa desde el SOC.
 
### dmz-host1 — Servidor Web (`192.168.30.10`)
 
Stack **Nginx + PHP-FPM** sirviendo la web corporativa. Configurado para comunicarse con el backend de base de datos en `dmz-host2`.
 
| Aspecto | Detalle |
|---------|---------|
| Servicio web | Nginx + PHP-FPM |
| Wazuh Agent | v4.11.2 (compatible con el Manager) |
| Logs monitorizados | `/var/log/nginx/access.log` |
 
### dmz-host2 — Servidor de Base de Datos (`192.168.30.20`)
 
**MariaDB** configurado con acceso restringido exclusivamente desde `dmz-host1` (`192.168.30.10`), siguiendo el principio de mínimo privilegio.
 
| Aspecto | Detalle |
|---------|---------|
| Motor de base de datos | MariaDB |
| Base de datos | `jankesto_db` |
| Usuario de aplicación | `webuser@192.168.30.10` |
| Wazuh Agent | v4.11.2 (compatible con el Manager) |
| Logs monitorizados | `/var/log/mysql/error.log` |
 
Consulta [`dmz/Documentacio dmz-host1.md`](dmz/Documentacio%20dmz-host1.md) y [`dmz/Documentacio dmz-host2.md`](dmz/Documentacio%20dmz-host2.md) para las guías completas de cada host, incluyendo troubleshooting documentado.
 
---
 
> 📌 Para la guía de instalación global y el orden de despliegue recomendado, consulta el [README principal](../README.md) del repositorio.