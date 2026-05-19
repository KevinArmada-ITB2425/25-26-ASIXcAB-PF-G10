# 🟦 Wazuh — Guía de Instalación y Configuración

> **Host:** `wazuh-server` · **IP:** `192.168.10.10` · **Subred:** Gestió `192.168.10.0/24`

---

## Requisitos previos

- Ubuntu Server 22.04 LTS
- RAM: mínimo **4 GB** (Wazuh Indexer es exigente)
- Almacenamiento: mínimo 20 GB libres
- Conectividad con todas las subredes (a través del router)

---

## 1. Instalación del Wazuh Manager (All-in-One)

```bash
# Descargar el script de instalación oficial
curl -sO https://packages.wazuh.com/4.11/wazuh-install.sh
curl -sO https://packages.wazuh.com/4.11/config.yml
```

Editar `config.yml` con la IP del servidor:

```yaml
nodes:
  indexer:
    - name: node-1
      ip: "192.168.10.10"
  server:
    - name: wazuh-1
      ip: "192.168.10.10"
  dashboard:
    - name: dashboard
      ip: "192.168.10.10"
```

```bash
# Generar certificados y ejecutar instalación
bash wazuh-install.sh --generate-config-files
bash wazuh-install.sh --wazuh-indexer node-1
bash wazuh-install.sh --start-cluster
bash wazuh-install.sh --wazuh-server wazuh-1
bash wazuh-install.sh --wazuh-dashboard dashboard
```

---

## 2. Acceso al Dashboard

```
URL:      https://192.168.10.10
Usuario:  admin
Password: (generada durante la instalación, guardar el output)
```

---

## 3. Instalación de Agentes

### En cada endpoint (client-user1, client-user2, dmz-host1, dmz-host2):


![Comando wazuh-agents](./dashboard-screenshots/comando_wazuh-agent_clientes.png)

```bash
# Habilitar e iniciar el agente
systemctl enable wazuh-agent
systemctl start wazuh-agent
```

---

## 4. Verificación

```bash
# En el servidor, comprobar agentes conectados
/var/ossec/bin/agent_control -l

# Ver logs en tiempo real
tail -f /var/ossec/logs/ossec.log
```
---

## 5. Monitorización y Mantenimiento Avanzado (Scripts)

Para garantizar la resiliencia del servidor y automatizar el control de los agentes, se han desplegado herramientas personalizadas. Puedes revisar el directorio completo de utilidades en la carpeta [`scripts/`](scripts/).

Ambos scripts se ejecutan de forma automatizada mediante tareas programadas de sistema (`cron`).

---

### 🛠️ Autorecuperación de Servicios (`wazuh-healthcheck.sh`)

Este script comprueba cada 5 minutos si los tres pilares del servidor central están levantados. Si detecta alguno caído, fuerza su reinicio secuencialmente para evitar cortes en el servicio SOC.

- **Ver código fuente:** [`scripts/wazuh-healthcheck.sh`](scripts/wazuh-healthcheck.sh)
- **Log dedicado:** `/home/isard/Escritorio/logs/wazuh-healthcheck.log`
- **Servicios evaluados:** `wazuh-manager`, `wazuh-indexer` y `wazuh-dashboard`
- **Lógica:** Realiza un máximo de 5 intentos de recuperación con 10 segundos de espera entre reintentos.

---

### 📊 Reporte del Estado de Agentes (`wazuh-agents-status.sh`)

Formatea la salida nativa del comando de Wazuh para ofrecer un recuento limpio por terminal, omitiendo la ID local del manager (`000`), y alertando al administrador en caso de detectar endpoints desconectados.

- **Ver código fuente:** [`scripts/wazuh-agents-status.sh`](scripts/wazuh-agents-status.sh)
- **Log dedicado:** `/home/isard/Escritorio/logs/wazuh-agents-status.log`
- **Métricas del reporte:** Contabiliza agentes Activos, Desconectados, Pendientes y Nunca conectados.

---

### ⏰ Automatización en Crontab del Sistema

Para que estas herramientas trabajen en segundo plano sin intervención manual, edita el archivo general de tareas del sistema:

```bash
sudo nano /etc/crontab
```

E inserta las siguientes directrices al final del documento (redirigiendo los flujos a `/dev/null` para silenciar las salidas de consola y delegar todo el control de auditoría a tus logs del Escritorio):

```
# Monitoreo de salud de servicios Wazuh cada 5 minutos
*/5 * * * * root bash /home/isard/scripts/wazuh-healthcheck.sh > /dev/null 2>&1

# Reporte estadístico del estado de los agentes cada hora en punto
0 * * * * root bash /home/isard/scripts/wazuh-agents-status.sh > /dev/null 2>&1
```
---

## Capturas

Ver carpeta [`dashboard-screenshots/`](dashboard-screenshots/) para evidencias visuales del SOC funcionando.
