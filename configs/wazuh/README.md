# 🟦 Wazuh — SOC (SIEM / XDR)

Configuración e instalación del servidor Wazuh y sus agentes.

## Contenido

| Archivo / Carpeta | Descripción |
|-------------------|-------------|
| `config.md` | Guía paso a paso de instalación del Wazuh Manager, Indexer y Dashboard |
| `dashboard-screenshots/` | Capturas de pantalla del dashboard SOC con alertas reales |

## Infraestructura Wazuh

| Componente | Host | IP |
|------------|------|----|
| Wazuh Manager + Indexer + Dashboard | `wazuh-server` | `192.168.10.10` |
| Wazuh Agent 1 | `client-user1` | `192.168.20.101` |
| Wazuh Agent 2 | `client-user2` | `192.168.20.100` |
| Wazuh Agent 3 | `dmz-host1` | `192.168.30.10` |
| Wazuh Agent 4 | `dmz-host2` | `192.168.30.20` |

## Funcionalidades activas

- 🔐 Detección de fuerza bruta (SSH, login)
- 📁 File Integrity Monitoring (FIM)
- ⚠️ Detección de vulnerabilidades CVE
- 🚨 Alertas de escalada de privilegios
- 🗺️ Mapeo a MITRE ATT&CK
- ⚡ Respuesta activa automatizada
