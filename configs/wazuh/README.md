# 🟦 Wazuh — SOC (SIEM / XDR)

Configuración e instalación del servidor Wazuh y sus agentes.

## Contenido

| Archivo / Carpeta | Descripción |
|-------------------|-------------|
| `config.md` | Guía paso a paso de instalación del Wazuh Manager, Indexer, Dashboard y Configuración Implementada |
| `dashboard-screenshots/` | Capturas de pantalla del dashboard SOC con alertas reales |

## Infraestructura Wazuh

| Componente | Host | IP |
|------------|------|----|
| Wazuh Manager + Indexer + Dashboard | `wazuh-server` | `192.168.10.10` |
| 001 | `client-user1` | `192.168.20.101` |
| 002 | `client-user2` | `192.168.20.100` |
| 003 | `dmz-host1` | `192.168.30.10` |
| 004 | `dmz-host2` | `192.168.30.20` |
| 005 | `admin-server` | `192.168.10.20` |

## Funcionalidades activas

- 🔐 Detección de fuerza bruta (SSH, login)
- 📁 File Integrity Monitoring (FIM)
- ⚠️ Detección de vulnerabilidades CVE
- 🚨 Alertas de escalada de privilegios
- 🗺️ Mapeo a MITRE ATT&CK
- ⚡ Respuesta activa automatizada

## 🛠️ Automatización y Monitoreo (Scripts)

Para garantizar la alta disponibilidad de la infraestructura del SOC, se ha implementado un sistema de autorecuperación automatizado.

### Script de Health Check (wazuh-healthcheck.sh)
Ubicado en la ruta del usuario: `/home/isard/scripts/wazuh-healthcheck.sh.` 

Este script en Bash monitoriza de forma persistente los tres servicios esenciales del servidor:
1. `wazuh-manager`
2. `wazuh-indexer`
3. `wazuh-dashboard`

**Características principales:**
**Detección inteligente:** Comprueba el estado de cada servicio mediante systemctl.
**Autorecuperación:** Si detecta un servicio caído, realiza hasta **5 intentos de reinicio** con intervalos de espera de 10 segundos.
**Auditoría y Logs:** Registra con marcas de tiempo detalladas cada evento (estados OK, alertas de caída, intentos de recuperación y fallos críticos) en un archivo de log dedicado: `/home/isard/Escritorio/logs/wazuh-healthcheck.log.`

### Implementación en tareas programadas (Cron)
El script se ejecuta de forma automática en segundo plano cada **5 minutos** con privilegios de root. 

Para replicar la configuración en el sistema:

Abriremos el archivo de configuración global:
`sudo nano /etc/crontab`

Y al final del todo añadiremos la siguiente linea:
`*/5 * * * * root bash /home/isard/scripts/wazuh-healthcheck.sh > /dev/null 2>&1`