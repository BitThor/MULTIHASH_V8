
#!/bin/bash

# MULTIHASH PRO v8 - Hashing + Metadatos + Validación

# Colores
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Archivos de salida
LOG_FILE="multihash_log.txt"
REPORT_TXT="multihash_report.txt"
REPORT_JSON="multihash_report.json"

# Logo
print_logo() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
░▒▓██████████████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░   ░▒▓████████▓▒░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░ ░▒▓███████▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░  
░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░   ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░   ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░       ░▒▓█▓▒▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░   ░▒▓█▓▒░▒▓████████▓▒░▒▓████████▓▒░░▒▓██████▓▒░░▒▓████████▓▒░       ░▒▓█▓▒▒▓█▓▒░ ░▒▓██████▓▒░  
░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░   ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░        ░▒▓█▓▓█▓▒░ ░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░   ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░        ░▒▓█▓▓█▓▒░ ░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░░▒▓████████▓▒░▒▓█▓▒░   ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░░▒▓█▓▒░░▒▓█▓▒░         ░▒▓██▓▒░   ░▒▓██████▓▒░  
EOF
    echo -e "${NC}"
}

# Verificar dependencias
check_dependencies() {
    for cmd in md5sum sha1sum sha256sum sha512sum realpath stat find exiftool identify file; do
        if ! command -v "$cmd" &>/dev/null; then
            echo -e "${RED}❌ Falta la herramienta '$cmd'.${NC}"
            exit 1
        fi
    done
}

# Solicitar ruta
ask_for_path() {
    echo -e "${BLUE}📁 Ingresa la ruta de un archivo o directorio:${NC}"
    read -e -r INPUT
    TARGET=$(realpath "$INPUT" 2>/dev/null)
    if [[ ! -e "$TARGET" ]]; then
        echo -e "${RED}❌ Ruta no válida.${NC}"
        ask_for_path
    fi
}

# Hashes
process_file() {
    local FILE="$1"
    local NAME=$(basename "$FILE")
    local SIZE=$(stat -c%s "$FILE")
    local MD5=$(md5sum "$FILE" | awk '{print $1}')
    local SHA1=$(sha1sum "$FILE" | awk '{print $1}')
    local SHA256=$(sha256sum "$FILE" | awk '{print $1}')
    local SHA512=$(sha512sum "$FILE" | awk '{print $1}')

    echo -e "${YELLOW}┌──── Análisis de Hash ──────────────────────────────────────────────────┐"
    printf "${WHITE}│ Archivo: %-60s │\n" "$NAME"
    printf "│ Ruta: %-63s │\n" "$FILE"
    printf "│ Tamaño: %-60s │\n" "${SIZE} bytes"
    printf "│ MD5: %-64s │\n" "$MD5"
    printf "│ SHA1: %-63s │\n" "$SHA1"
    printf "│ SHA256: %-61s │\n" "$SHA256"
    printf "│ SHA512: %-61s │\n" "$SHA512"
    echo -e "${YELLOW}└────────────────────────────────────────────────────────────────────────┘${NC}"
    echo

    {
        echo "Archivo: $NAME"
        echo "Ruta: $FILE"
        echo "Tamaño: ${SIZE} bytes"
        echo "MD5: $MD5"
        echo "SHA1: $SHA1"
        echo "SHA256: $SHA256"
        echo "SHA512: $SHA512"
        echo "───────────────────────────────────────────────"
    } >> "$REPORT_TXT"

    echo "{" >> "$REPORT_JSON"
    echo "  \"archivo\": \"$NAME\"," >> "$REPORT_JSON"
    echo "  \"ruta\": \"$FILE\"," >> "$REPORT_JSON"
    echo "  \"tamano\": \"$SIZE\"," >> "$REPORT_JSON"
    echo "  \"md5\": \"$MD5\"," >> "$REPORT_JSON"
    echo "  \"sha1\": \"$SHA1\"," >> "$REPORT_JSON"
    echo "  \"sha256\": \"$SHA256\"," >> "$REPORT_JSON"
    echo "  \"sha512\": \"$SHA512\"" >> "$REPORT_JSON"
    echo "}," >> "$REPORT_JSON"

    echo "$(date "+%Y-%m-%d %H:%M:%S") - Analizado: $FILE" >> "$LOG_FILE"
}

# Recorrer y procesar
process_all() {
    echo -e "${BLUE}[+] Calculando Hashes...${NC}"
    > "$REPORT_TXT"
    echo "[" > "$REPORT_JSON"
    > "$LOG_FILE"

    if [[ -f "$TARGET" ]]; then
        process_file "$TARGET"
    elif [[ -d "$TARGET" ]]; then
        mapfile -t FILES < <(find "$TARGET" -type f)
        for FILE in "${FILES[@]}"; do
            process_file "$FILE"
        done
    else
        echo -e "${RED}❌ Tipo de entrada no soportado.${NC}"
        exit 1
    fi

    sed -i '$ s/},/}/' "$REPORT_JSON"
    echo "]" >> "$REPORT_JSON"

    echo -e "${GREEN}✅ Proceso finalizado.${NC}"
    echo -e "${CYAN}📄 Reporte generado: ${WHITE}$REPORT_TXT${NC}"
    echo -e "${CYAN}📦 JSON exportado:   ${WHITE}$REPORT_JSON${NC}"
    echo -e "${CYAN}📚 Log registrado:   ${WHITE}$LOG_FILE${NC}"
}

# Validación manual
validate_hash_manual() {
    echo -e "${YELLOW}🔐 Validación manual de hash${NC}"
    echo -ne "${BLUE}Hash a verificar: ${NC}"
    read -r USER_HASH

    echo -e "${CYAN}Elige algoritmo:${NC}"
    echo -e "${GREEN}1)${NC} MD5"
    echo -e "${GREEN}2)${NC} SHA1"
    echo -e "${GREEN}3)${NC} SHA256"
    echo -e "${GREEN}4)${NC} SHA512"
    read -p "Opción: " OPT

    case $OPT in
        1) HASH="$MD5"; NAME="MD5" ;;
        2) HASH="$SHA1"; NAME="SHA1" ;;
        3) HASH="$SHA256"; NAME="SHA256" ;;
        4) HASH="$SHA512"; NAME="SHA512" ;;
        *) echo -e "${RED}❌ Opción inválida.${NC}"; return ;;
    esac

    if [[ "$USER_HASH" == "$HASH" ]]; then
        echo -e "${GREEN}✅ Hash válido. Coincide.${NC}"
    else
        echo -e "${RED}❌ Hash no coincide. Esperado: ${WHITE}$HASH${NC}"
    fi
    read -rp "Presiona [Enter] para continuar..."
}

# Validar desde archivo
validate_from_file() {
    echo -e "${YELLOW}📄 Validación desde archivo .txt${NC}"
    read -e -p "Ruta del archivo: " CHECK_FILE
    if [[ ! -f "$CHECK_FILE" ]]; then
        echo -e "${RED}❌ Archivo no encontrado.${NC}"
        return
    fi

    echo -e "${CYAN}Algoritmo usado:${NC}"
    echo -e "${GREEN}1)${NC} MD5"
    echo -e "${GREEN}2)${NC} SHA1"
    echo -e "${GREEN}3)${NC} SHA256"
    echo -e "${GREEN}4)${NC} SHA512"
    read -p "Opción: " OPT

    case $OPT in
        1) COMMAND="md5sum" ;;
        2) COMMAND="sha1sum" ;;
        3) COMMAND="sha256sum" ;;
        4) COMMAND="sha512sum" ;;
        *) echo -e "${RED}❌ Opción inválida.${NC}"; return ;;
    esac

    $COMMAND -c "$CHECK_FILE"
    read -rp "Presiona [Enter] para continuar..."
}

# 🔍 Análisis de metadatos usando múltiples herramientas
analyze_metadata() {
    echo -e "${BLUE}📁 Ruta del archivo de imagen para metadatos:${NC}"
    read -e -r FILE
    FILE=$(realpath "$FILE" 2>/dev/null)

    if [[ ! -f "$FILE" ]]; then
        echo -e "${RED}❌ El archivo no existe.${NC}"
        return
    fi

    echo -e "${CYAN}Tipo MIME:${NC} $(file --mime-type -b "$FILE")"
    echo -e "${YELLOW}📸 Metadatos con exiftool:${NC}"
    exiftool "$FILE"

    echo -e "${YELLOW}🖼️ Detalles con ImageMagick (identify):${NC}"
    identify -verbose "$FILE"

    echo -e "${YELLOW}🧾 Info básica con file:${NC}"
    file "$FILE"

    echo -e "${GREEN}✅ Análisis de metadatos finalizado.${NC}"
    read -rp "Presiona [Enter] para continuar..."
}

# Menú principal
show_menu() {
    echo -e "${CYAN}¿Qué deseas hacer?${NC}"
    echo -e "${GREEN}1)${NC} Cambiar archivo o directorio"
    echo -e "${GREEN}2)${NC} Calcular hashes"
    echo -e "${GREEN}3)${NC} Validar hash manualmente"
    echo -e "${GREEN}4)${NC} Validar desde archivo .txt"
    echo -e "${GREEN}5)${NC} Exportar resultados"
    echo -e "${GREEN}6)${NC} Analizar metadatos de archivo"
    echo -e "${GREEN}7)${NC} Salir"
    echo -ne "${BLUE}Opción > ${NC}"
    read -r OPTION

    case $OPTION in
        1) ask_for_path; process_all ;;
        2) process_all ;;
        3) validate_hash_manual ;;
        4) validate_from_file ;;
        5) echo -e "${CYAN}Resultados ya están en los archivos exportados.${NC}";;
        6) analyze_metadata ;;
        7) exit 0 ;;
        *) echo -e "${RED}❌ Opción inválida.${NC}" ;;
    esac
}

# Función principal
main() {
    check_dependencies
    print_logo
    ask_for_path
    process_all
    while true; do
        show_menu
    done
}

main