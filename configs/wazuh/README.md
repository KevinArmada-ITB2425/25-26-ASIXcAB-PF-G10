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
