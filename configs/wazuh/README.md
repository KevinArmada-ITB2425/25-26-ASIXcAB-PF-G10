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

Para garantizar la alta disponibilidad de la infraestructura del SOC y mantener un control estricto sobre los endpoints, se han implementado scripts automatizados en Bash dentro de la ruta del usuario: `/home/isard/scripts/.`

### 1. Script de Health Check (wazuh-healthcheck.sh)
Monitoriza de forma persistente los tres servicios esenciales del servidor central para mitigar caídas imprevistas.
**Servicios evaluados:** `wazuh-manager`, `wazuh-indexer` y `wazuh-dashboard.`
**Detección inteligente:** Comprueba el estado de cada servicio mediante `systemctl.`
**Autorecuperación:** Si detecta un servicio caído, realiza hasta **5 intentos de reinicio** automáticos asistidos por intervalos de espera de 10 segundos.
**Auditoría:** Registra cada evento con marcas de tiempo en su log dedicado: `/home/isard/Escritorio/logs/wazuh-healthcheck.log.`

### 2. Script de Estado de Agentes (wazuh-agents-status.sh)
Interroga de forma programada a la utilidad nativa `agent_control` de Wazuh para mapear, formatear y auditar el estado del parque de agentes en la red.
**Métricas cuantitativas:** Clasifica y cuenta los agentes según su estado operativo (Activo, Desconectado, Pendiente o Nunca conectado), discriminando automáticamente al propio manager (ID `000`).

**Alertas operativas:** Si detecta sistemas caídos, imprime una alerta visual en consola indicando los comandos inmediatos de diagnóstico y reinicio del servicio para el administrador.
**Auditoría diferenciada:** Almacena un resumen resumido por hora en un archivo de log aislado: `/home/isard/Escritorio/logs/wazuh-agents-status.log.`

---

### Implementación en tareas programadas (Cron)
Ambos procesos se ejecutan en segundo plano con privilegios de `root` para interactuar correctamente con los servicios del sistema y las herramientas de Wazuh.

Para replicar la configuración en el entorno:

1. Abrir el archivo de configuración global de tareas del sistema:
   
```bash
sudo nano /etc/crontab

# Monitoreo de salud de servicios Wazuh cada 5 minutos
*/5 * * * * root bash /home/isard/scripts/wazuh-healthcheck.sh > /dev/null 2>&1

# Reporte estadístico del estado de los agentes cada hora en punto
0 * * * * root bash /home/isard/scripts/wazuh-agents-status.sh > /dev/null 2>&1