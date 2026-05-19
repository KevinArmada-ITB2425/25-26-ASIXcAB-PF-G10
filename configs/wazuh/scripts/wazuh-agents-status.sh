#!/bin/bash
# =============================================================
#  wazuh-agents-status.sh
#  Muestra cuántos agentes hay activos, desconectados,
#  pendientes y nunca conectados.
#
#  Uso:   sudo bash /home/isard/scripts/wazuh-agents-status.sh
#  Cron:  0 * * * * root bash /home/isard/scripts/wazuh-agents-status.sh
# =============================================================

# Asegurar que el script tenga acceso a los comandos del sistema en cron
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# ---------- Colores ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ---------- Config ----------
AGENT_CONTROL="/var/ossec/bin/agent_control"
LOG="/home/isard/Escritorio/logs/wazuh-agents-status.log"

# ---------- Comprobar que existe el binario ----------
if [[ ! -f "$AGENT_CONTROL" ]]; then
    echo -e "${RED}[ERROR] No se encuentra $AGENT_CONTROL${NC}"
    echo "Asegurate de ejecutar este script en el Wazuh Manager."
    exit 1
fi

# ---------- Encabezado ----------
FECHA_EJECUCION=$(date '+%Y-%m-%d %H:%M:%S')
echo ""
echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE}   WAZUH AGENT STATUS · $FECHA_EJECUCION${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""
printf "  ${CYAN}%-6s %-22s %-16s %s${NC}\n" "ID" "NOMBRE" "IP" "ESTADO"
printf "  ${CYAN}%-6s %-22s %-16s %s${NC}\n" "------" "----------------------" "----------------" "----------"

# ---------- Contadores ----------
TOTAL=0; ACTIVOS=0; DESCONECTADOS=0; PENDIENTES=0; NUNCA=0

# ---------- Parsear agentes ----------
# Ejecuta el comando y procesa línea por línea
while IFS= read -r LINE; do

    # Filtrar solo las líneas que contienen datos de agentes reales (ej: "   ID: 001, ...")
    if echo "$LINE" | grep -q "ID:"; then

        # Limpiamos las etiquetas "ID:", "Name:", "IP:" y las comas para dejar solo el texto limpio
        CLEAN_LINE=$(echo "$LINE" | sed 's/ID://g' | sed 's/Name://g' | sed 's/IP://g' | sed 's/,//g')

        # Ahora podemos extraer las variables por posición con seguridad
        ID=$(echo "$CLEAN_LINE"     | awk '{print $1}')
        NOMBRE=$(echo "$CLEAN_LINE" | awk '{print $2}')
        IP=$(echo "$CLEAN_LINE"     | awk '{print $3}')
        ESTADO=$(echo "$CLEAN_LINE" | awk '{print $4}')

        # Saltar el manager (agente 000)
        [[ "$ID" == "000" ]] && continue

        TOTAL=$((TOTAL + 1))

        case "$ESTADO" in
            Active*)
                printf "  %-6s %-22s %-16s ${GREEN}● Activo${NC}\n" "$ID" "$NOMBRE" "$IP"
                ACTIVOS=$((ACTIVOS + 1))
                ;;
            Disconnected*)
                printf "  %-6s %-22s %-16s ${RED}● Desconectado${NC}\n" "$ID" "$NOMBRE" "$IP"
                DESCONECTADOS=$((DESCONECTADOS + 1))
                ;;
            Pending*)
                printf "  %-6s %-22s %-16s ${YELLOW}● Pendiente${NC}\n" "$ID" "$NOMBRE" "$IP"
                PENDIENTES=$((PENDIENTES + 1))
                ;;
            Never*)
                printf "  %-6s %-22s %-16s ${YELLOW}● Nunca conectado${NC}\n" "$ID" "$NOMBRE" "$IP"
                NUNCA=$((NUNCA + 1))
                ;;
            *)
                printf "  %-6s %-22s %-16s ${CYAN}● $ESTADO${NC}\n" "$ID" "$NOMBRE" "$IP"
                ;;
        esac
    fi

done < <("$AGENT_CONTROL" -l 2>/dev/null)

# ---------- Resumen ----------
echo ""
echo -e "${BLUE}=================================================${NC}"
echo -e "  Total agentes registrados : ${CYAN}$TOTAL${NC}"
echo -e "  Activos                   : ${GREEN}$ACTIVOS${NC}"
echo -e "  Desconectados             : ${RED}$DESCONECTADOS${NC}"
echo -e "  Pendientes de registro    : ${YELLOW}$PENDIENTES${NC}"
echo -e "  Nunca conectados          : ${YELLOW}$NUNCA${NC}"
echo -e "${BLUE}=================================================${NC}"

# ---------- Alerta si hay desconectados ----------
if [[ $DESCONECTADOS -gt 0 ]]; then
    echo ""
    echo -e "${RED}  ALERTA: $DESCONECTADOS agente(s) desconectado(s)${NC}"
    echo -e "${YELLOW}  En el host afectado ejecuta:${NC}"
    echo -e "    sudo systemctl status wazuh-agent"
    echo -e "    sudo systemctl restart wazuh-agent"
fi

echo ""

# ---------- Guardar resumen en log ----------
echo "[$FECHA_EJECUCION] Total:$TOTAL Activos:$ACTIVOS Desconectados:$DESCONECTADOS Pendientes:$PENDIENTES NuncaConectados:$NUNCA" >> "$LOG"