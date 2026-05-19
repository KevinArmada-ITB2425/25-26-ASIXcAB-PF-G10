#!/bin/bash
# =============================================================
#  wazuh-healthcheck.sh
#  Verifica que los servicios Wazuh estén activos.
#  Si alguno está caído, lo reinicia hasta que arranque.
#
#  Uso:   sudo bash /home/isard/scripts/wazuh-healthcheck.sh
#  Cron:  */5 * * * * root bash /home/isard/scripts/wazuh-healthcheck.sh
# =============================================================

# Asegurar que el script tenga acceso a los comandos del sistema en cron
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# ---------- Colores ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ---------- Config ----------
MAX_INTENTOS=5
ESPERA=10
LOG="/home/isard/Escritorio/logs/wazuh-healthcheck.log"

SERVICIOS=(
    "wazuh-manager"
    "wazuh-indexer"
    "wazuh-dashboard"
)

# Función de log modificada para que la fecha se actualice en cada línea
log() { 
    local FECHA_ACTUAL=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$FECHA_ACTUAL] $1" >> "$LOG"
}

verificar_servicio() {
    local SVC=$1

    if systemctl is-active --quiet "$SVC"; then
        echo -e "${GREEN}[✔] $SVC — ACTIVO${NC}"
        log "OK - $SVC activo"
        return 0
    fi

    echo -e "${RED}[✘] $SVC — CAIDO${NC}"
    log "ALERTA - $SVC caido, iniciando reintentos"

    for (( i=1; i<=MAX_INTENTOS; i++ )); do
        echo -e "${YELLOW}    Intento $i/$MAX_INTENTOS: reiniciando $SVC...${NC}"
        log "Intento $i/$MAX_INTENTOS - reiniciando $SVC"

        systemctl restart "$SVC"
        sleep "$ESPERA"

        if systemctl is-active --quiet "$SVC"; then
            echo -e "${GREEN}    [✔] $SVC arranco en el intento $i${NC}"
            log "RECUPERADO - $SVC arranco en intento $i"
            return 0
        fi
    done

    echo -e "${RED}    [✘] $SVC no pudo arrancar tras $MAX_INTENTOS intentos${NC}"
    log "CRITICO - $SVC no arranco tras $MAX_INTENTOS intentos — revision manual necesaria"
    return 1
}

# ---------- Main ----------
FECHA_INICIO=$(date '+%Y-%m-%d %H:%M:%S')
echo ""
echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE}   WAZUH HEALTH CHECK · $FECHA_INICIO${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""

FALLOS=0
for SVC in "${SERVICIOS[@]}"; do
    verificar_servicio "$SVC"
    [[ $? -ne 0 ]] && FALLOS=$((FALLOS + 1))
    echo ""
done

echo -e "${BLUE}=================================================${NC}"
if [[ $FALLOS -eq 0 ]]; then
    echo -e "${GREEN}  [✔] Todos los servicios operativos${NC}"
    log "RESUMEN - Todos los servicios OK"
else
    echo -e "${RED}  [✘] $FALLOS servicio(s) con problemas — ver $LOG${NC}"
    log "RESUMEN - $FALLOS servicios con problemas criticos"
fi
echo -e "${BLUE}=================================================${NC}"
echo ""