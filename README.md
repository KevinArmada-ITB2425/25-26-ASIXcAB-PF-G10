<div align="center">

# 🔐 Arquitectura de Red Corporativa Segura con SOC

**Proyecto Final de Grado Superior ASIX · Curso 2025–2026 · Grupo 5**

---

[![Estado](https://img.shields.io/badge/Estado-En%20Desarrollo-yellow?style=for-the-badge)]()
[![Ubuntu](https://img.shields.io/badge/Router-Ubuntu%20Server%2022.04-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)]()
[![Wazuh](https://img.shields.io/badge/SOC-Wazuh%20SIEM%2FXDR-005571?style=for-the-badge)]()
[![WireGuard](https://img.shields.io/badge/VPN-WireGuard-88171A?style=for-the-badge&logo=wireguard&logoColor=white)]()
[![Suricata](https://img.shields.io/badge/IDS%2FIPS-Suricata-EF5B25?style=for-the-badge)]()
[![License](https://img.shields.io/badge/Licencia-Académica-lightgrey?style=for-the-badge)]()

</div>

---

## 📚 Índice

- [¿De qué trata?](#-de-qué-trata-este-proyecto)
- [¿Qué problema resuelve?](#-qué-problema-resuelve)
- [Arquitectura](#️-arquitectura--tres-capas-de-defensa)
- [Topología de Red](#-topología-de-red)
- [Stack Tecnológico](#️-stack-tecnológico)
- [Máquinas Virtuales](#️-máquinas-virtuales)
- [Sprints y Weekly Logs](#-sprints--weekly-logs)
- [Estructura del Repositorio](#-estructura-del-repositorio)
- [Cómo empezar](#-cómo-empezar)
- [Módulos ASIX cubiertos](#-módulos-asix-cubiertos)
- [Autores](#-autores--grupo-5)

---

## 📌 ¿De qué trata este proyecto?

Este proyecto simula la infraestructura de red completa de una **PYME real**, diseñada desde cero con criterios de seguridad profesional. El objetivo es demostrar cómo una organización puede proteger sus activos digitales frente a amenazas externas e internas aplicando la **tríada CIA** (Confidencialidad, Integridad y Disponibilidad).

Todo el entorno se despliega en máquinas virtuales sobre **IsardVDI**, reproduciendo fielmente un entorno corporativo real con herramientas **open source estándar de la industria**.

Como punto diferenciador, el proyecto integra un **SOC (Security Operations Center)** completo que permite no solo bloquear ataques perimetrales, sino también monitorizar el comportamiento interno de todos los sistemas en tiempo real con mapeo a **MITRE ATT&CK**.

---

## 🎯 ¿Qué problema resuelve?

Una PYME sin medidas de seguridad avanzadas es vulnerable a:

| Amenaza | Descripción | Nuestra solución |
|---------|-------------|-----------------|
| 🔁 **Movimiento lateral** | Un atacante que compromete un equipo de usuario puede saltar a servidores críticos | Subnetting estricto + reglas `nftables` deny-all |
| 💥 **Ataques perimetrales** | Escaneos de puertos, fuerza bruta, exploits conocidos | Suricata IDS/IPS en el router |
| 👁️ **Falta de visibilidad** | Sin monitorización, los incidentes pasan desapercibidos durante días | Wazuh SIEM con agentes en todos los endpoints |
| 🌐 **Acceso remoto inseguro** | Empleados que se conectan desde fuera sin cifrado exponen la red | WireGuard VPN con criptografía moderna |

---

## 🏗️ Arquitectura — Tres Capas de Defensa

### 🔴 Capa 1 — Perímetro
Router/Firewall **Ubuntu Server** con **Suricata IDS/IPS** y `nftables`. Gestiona el enrutamiento entre subredes, aplica NAT hacia internet y bloquea tráfico no autorizado entre segmentos de red.

### 🟡 Capa 2 — Segmentación Interna
Tres subredes completamente aisladas con política **deny-all** por defecto gestionada vía `nftables`. El tráfico solo se permite explícitamente donde sea necesario:

| Subred | Rango | Función | Acceso |
|--------|-------|---------|--------|
| **Gestió** | `192.168.10.0/24` | Servidores críticos y SOC | Solo desde VPN |
| **Usuaris** | `192.168.20.0/24` | Puestos de trabajo | Internet + DNS, sin acceso a Gestió |
| **DMZ/IoT** | `192.168.30.0/24` | Servicios expuestos e IoT | Controlado, aislado del resto |

### 🟢 Capa 3 — SOC (Security Operations Center)
Servidor **Wazuh** en la subred de Gestió. Agentes en todos los endpoints detectan en tiempo real:
- 🔐 Intentos de fuerza bruta y accesos fallidos
- 📁 Modificaciones en archivos críticos (FIM — File Integrity Monitoring)
- ⚠️ Vulnerabilidades CVE activas
- 🚨 Escaladas de privilegios y comportamientos anómalos
- 🗺️ Todos los eventos mapeados a **MITRE ATT&CK**

### 🔵 Acceso Remoto Seguro
**WireGuard VPN** con cifrado **Curve25519 + ChaCha20-Poly1305** instalado en el `admin-server`. Clientes disponibles para Windows, Linux y Android. Todo acceso auditado y registrado en el SOC.

---

## 🗺️ Topología de Red

```
                              INTERNET
                                  │
                       ┌──────────┴──────────┐
                       │    ubuntu-router     │
                       │  nftables + Suricata │
                       │  192.168.X.1 (gw)   │
                       └───┬─────────┬────┬──┘
                           │         │    │
            ┌──────────────┘         │    └────────────────┐
            │                        │                     │
  ┌─────────┴──────────┐  ┌──────────┴─────────┐  ┌───────┴────────────┐
  │  192.168.10.0/24   │  │  192.168.20.0/24   │  │  192.168.30.0/24  │
  │       GESTIÓ       │  │      USUARIS        │  │     DMZ / IoT     │
  │                    │  │                     │  │                   │
  │  ┌──────────────┐  │  │  ┌──────────────┐  │  │  ┌─────────────┐ │
  │  │ wazuh-server │  │  │  │ client-user1 │  │  │  │  dmz-host1  │ │
  │  │ .10.10       │  │  │  │ .20.101      │  │  │  │  .30.10     │ │
  │  │ Wazuh SOC    │  │  │  │ Wazuh Agnt 1 │  │  │  │ Wazuh Agnt3 │ │
  │  └──────────────┘  │  │  └──────────────┘  │  │  └─────────────┘ │
  │  ┌──────────────┐  │  │  ┌──────────────┐  │  │  ┌─────────────┐ │
  │  │ admin-server │  │  │  │ client-user2 │  │  │  │  dmz-host2  │ │
  │  │ .10.20       │  │  │  │ .20.100      │  │  │  │  .30.20     │ │
  │  │ WireGuard VPN│  │  │  │ Wazuh Agnt 2 │  │  │  │ Wazuh Agnt4 │ │
  │  └──────────────┘  │  │  └──────────────┘  │  │  └─────────────┘ │
  └────────────────────┘  └────────────────────┘  └──────────────────┘
```

> 💡 La topología fue diseñada y validada en **Cisco Packet Tracer** antes de su implementación.  
> 📂 Diagrama visual disponible en [`diagrams/diagrama_final.webp`](diagrams/diagrama_final.webp)

---

## 🛠️ Stack Tecnológico

| Componente | Tecnología | Por qué esta elección |
|------------|-----------|----------------------|
| **Hipervisor** | IsardVDI | Disponible en el entorno educativo del ITB |
| **Router / Firewall** | Ubuntu Server 22.04 + nftables | Open source, configurable a bajo nivel, didáctico y representativo |
| **IDS/IPS** | Suricata | Multihilo, integración nativa en Ubuntu, ruleset Emerging Threats |
| **SOC (SIEM/XDR)** | Wazuh | Open source, MITRE ATT&CK, sin límite de agentes, FIM incluido |
| **VPN** | WireGuard | Más rápido que OpenVPN, ~4.000 líneas de código vs ~70.000, kernel nativo |
| **DHCP** | isc-dhcp-server | Estándar, configuración por subred, fácil integración |
| **DNS** | Technitium DNS | Interfaz web, zona local `jankesto.local`, filtrado de dominios maliciosos |

### ¿Por qué Ubuntu Server y no pfSense?

Aunque pfSense o OPNsense serían opciones válidas, elegimos **Ubuntu Server** con `nftables` para:
- Demostrar control total a bajo nivel del enrutamiento y filtrado de paquetes
- Justificar los conocimientos del módulo de Redes del grado ASIX
- Mayor flexibilidad para integrar Suricata, WireGuard y scripts personalizados en un mismo sistema

### ¿Por qué WireGuard y no OpenVPN?

| | WireGuard | OpenVPN |
|--|-----------|---------|
| Líneas de código | ~4.000 | ~70.000 |
| Integración kernel | Nativa (Linux 5.6+) | No |
| Criptografía | ChaCha20, Curve25519, BLAKE2s | OpenSSL (configurable) |
| Rendimiento | ✅ Superior | ⚠️ Menor |
| Configuración | Simple | Compleja |

---

## 🖥️ Máquinas Virtuales

| VM | SO | Subred | IP | RAM | Rol principal |
|----|-----|--------|----|-----|---------------|
| `ubuntu-router` | Ubuntu Server 22.04 | Todas (gateway) | `192.168.X.1` | 2 GB | Router · nftables · Suricata · NAT |
| `wazuh-server` | Ubuntu Server 22.04 | Gestió | `192.168.10.10` | **4 GB** | SOC: Wazuh Manager + Indexer + Dashboard |
| `admin-server` | Ubuntu Server 22.04 | Gestió | `192.168.10.20` | 1 GB | Administración · WireGuard VPN server |
| `client-user1` | Ubuntu Desktop 22.04 | Usuaris | `192.168.20.101` | 1 GB | Endpoint usuario · Wazuh Agent 1 |
| `client-user2` | Ubuntu Desktop 22.04 | Usuaris | `192.168.20.100` | 1 GB | Endpoint usuario · Wazuh Agent 2 |
| `dmz-host1` | Ubuntu Server 22.04 | DMZ | `192.168.30.10` | 1 GB | Servicio DMZ · Wazuh Agent 3 |
| `dmz-host2` | Ubuntu Server 22.04 | DMZ | `192.168.30.20` | 1 GB | Servicio DMZ · Wazuh Agent 4 |

> ⚠️ **RAM mínima del host:** 11 GB · Recomendada: 16 GB+

---

## 📋 Sprints & Weekly Logs

| Sprint | Semanas | Objetivo principal | Estado |
|--------|---------|-------------------|--------|
| **Sprint 1** | S1 – S2 | Hipervisor, creación de VMs, diseño de red, diagrama de topología | ✅ Completado |
| **Sprint 2** | S3 – S4 | Router Ubuntu, subnetting, DHCP, DNS (Technitium), Suricata IDS/IPS | ✅ Completado |
| **Sprint 3** | S5 – S6 | Wazuh Server + agentes en todos los endpoints + scripts de monitorización | ✅ Completado |
| **Sprint 4** | S7 – S8 | WireGuard VPN, hardening de todos los sistemas, pruebas finales | 🔜 En progreso |

> 📌 Gestión de tareas: **ProofHub** · Control de versiones: **este repositorio**

---

## 🗂️ Estructura
 
```
configs/
├── ubuntu-router/
│   ├── README.md                     ← Este documento
│   ├── config.md                     ← Guía completa de configuración
│   ├── backups-automatizacion/
│   │   ├── configs/
│   │   │   ├── dhcp/                 ← Backup configuración DHCP
│   │   │   ├── netplan/              ← Backup configuración de interfaces
│   │   │   ├── nftables/             ← Backup reglas de firewall
│   │   │   └── suricata/             ← Backup configuración IDS
│   │   └── scripts/
│   │       ├── 01-base.sh            ← Configuración base del sistema
│   │       ├── 02-dhcp.sh            ← Automatización instalación DHCP
│   │       ├── 03-dns.sh             ← Automatización instalación DNS
│   │       ├── 04-nftables.sh        ← Automatización reglas firewall
│   │       └── 05-suricata.sh        ← Automatización instalación Suricata
│
├── wazuh/
│   ├── README.md                     ← Overview, tabla de agentes, funcionalidades
│   ├── config.md                     ← Instalación paso a paso (all-in-one + agentes)
│   └── dashboard-screenshots/        ← Evidencias visuales del SOC funcionando
│
└── dmz/
    ├── README.md                     ← Hosts, política de seguridad
    ├── Documentacio dmz-host1.md     ← Servidor web (Nginx + PHP + Wazuh Agent)
    └── Documentacio dmz-host2.md     ← Servidor de base de datos (MariaDB + Wazuh Agent)
```

---

## 🚀 Cómo Empezar

> La guía completa paso a paso para configurar wazuh está en [ configs/wazuh/config.md ](configs/wazuh/config.md)

### Requisitos del host

```
RAM mínima:      11 GB  (recomendado 16 GB+)
Almacenamiento:  50 GB libres
Hipervisor:      IsardVDI (entorno ITB) o VirtualBox 7.0+
SO del host:     Linux / Windows 10+
```

### Orden de despliegue

```bash
# 1️⃣  Crear todas las VMs en IsardVDI con Ubuntu Server 22.04
# 2️⃣  Configurar ubuntu-router (interfaces, nftables, NAT, IP forwarding)
# 3️⃣  Desplegar DHCP (isc-dhcp-server) y DNS (Technitium)
# 4️⃣  Instalar y configurar Suricata en el router
# 5️⃣  Instalar Wazuh Manager + Indexer + Dashboard en wazuh-server
# 6️⃣  Desplegar agentes Wazuh en los 4 endpoints
# 7️⃣  Activar scripts de monitorización y configurar crontab
# 8️⃣  Configurar WireGuard VPN en admin-server
# 9️⃣  Ejecutar pruebas de penetración y verificar alertas en el SOC
```

Consulta la carpeta [`configs/`](configs/) para los archivos de configuración de cada servicio y en cada configuracion se encuentran los scripts para las herramientas de automatización y monitorización.

---

## 🔒 Módulos ASIX cubiertos

| Módulo | Contenido aplicado |
|--------|--------------------|
| **Sistemes Operatius en Xarxa** | Instalación, configuración y hardening de Ubuntu Server |
| **Planificació i Administració de Xarxes** | Subnetting, routing estático, NAT, nftables |
| **Seguretat i Alta Disponibilitat** | Firewall, IDS/IPS, SOC, VPN, principio de mínimo privilegio |
| **Serveis en Xarxa** | DHCP por subred, DNS con zona local `jankesto.local` y filtrado |
| **Gestió d'Incidents** | Detección y respuesta activa con Wazuh + MITRE ATT&CK |

---

## 👥 Autores — Grupo 5

| Nombre | GitHub |
|--------|--------|
| Kevin Armada Carrillo | [@KevinArmada-ITB2425](https://github.com/KevinArmada-ITB2425) |
| Jan Martinez Salas | [@JanMartinez-ITB2425](https://github.com/JanMartinez-ITB2425) |
| Ernesto Martinez Argueta | [@ErnestoMartinez-ITB2425](https://github.com/ErnestoMartinez-ITB2425) |

---

<div align="center">

**Institut de Tecnologia de Barcelona · ASIX · Curs 2025–2026**

</div>
