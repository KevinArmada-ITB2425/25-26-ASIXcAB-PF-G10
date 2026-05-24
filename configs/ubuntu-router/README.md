# 🟦 Ubuntu Router

> **Host:** `ubuntu-router` · **IP:** `192.168.10.1 / 192.168.20.1 / 192.168.30.1` · **Subred:** Todas (gateway central)

---

## Rol en la Arquitectura

El `ubuntu-router` es el núcleo de la infraestructura. Actúa como gateway entre las tres subredes internas y el exterior, aplicando segmentación estricta mediante `nftables` y monitorizando el tráfico perimetral con Suricata.

| Servicio | Descripción |
|----------|-------------|
| **nftables** | Firewall con política `deny-all` por defecto y excepciones explícitas |
| **NAT** | Enmascaramiento de las subredes internas hacia internet |
| **isc-dhcp-server** | Asignación de IPs con reservas MAC por subred |
| **Technitium DNS** | Resolución interna `jankesto.local` + forwarders externos |
| **Suricata** | IDS/IPS monitorizando la interfaz WAN (`enp1s0`) |

---

---

## 📄 Documentación

| Archivo | Descripción |
|---------|-------------|
| [`config.md`](config.md) | Guía completa de configuración: Netplan, IP Forwarding, DHCP, nftables, DNS y Suricata |

---

## 💾 Backups de Configuración

Copias de los archivos de configuración activos del sistema, organizadas por servicio.

| Carpeta | Archivo original en el sistema |
|---------|-------------------------------|
| [`backups-automatizacion/configs/dhcp/`](backups-automatizacion/configs/dhcp/) | `/etc/dhcp/dhcpd.conf` · `/etc/default/isc-dhcp-server` |
| [`backups-automatizacion/configs/netplan/`](backups-automatizacion/configs/netplan/) | `/etc/netplan/00-installer-config.yaml` |
| [`backups-automatizacion/configs/nftables/`](backups-automatizacion/configs/nftables/) | `/etc/nftables.conf` |
| [`backups-automatizacion/configs/suricata/`](backups-automatizacion/configs/suricata/) | `/etc/suricata/suricata.yaml` · `/etc/suricata/threshold.config` |

---

## 🛠️ Scripts de Automatización

Scripts numerados para reproducir la configuración completa del router desde cero, en orden de ejecución.

| Script | Función |
|--------|---------|
| [`01-base.sh`](backups-automatizacion/scripts/01-base.sh) | Configuración de interfaces (Netplan) y activación de IP forwarding |
| [`02-dhcp.sh`](backups-automatizacion/scripts/02-dhcp.sh) | Instalación y configuración de `isc-dhcp-server` con reservas MAC |
| [`03-dns.sh`](backups-automatizacion/scripts/03-dns.sh) | Instalación de Technitium DNS y zona local `jankesto.local` |
| [`04-nftables.sh`](backups-automatizacion/scripts/04-nftables.sh) | Aplicación de reglas de firewall y NAT |
| [`05-suricata.sh`](backups-automatizacion/scripts/05-suricata.sh) | Instalación y configuración de Suricata sobre `enp1s0` |

> ⚠️ Ejecutar los scripts en orden secuencial. Algunos dependen de configuraciones aplicadas en pasos anteriores.

---

> 📌 Para el contexto global de la infraestructura, consulta el [README principal](../../README.md) del repositorio.