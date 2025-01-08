#!/bin/bash

# Directorio para guardar los medios
DIRECTORIO="$(pwd)/Medios"
ARCHIVOS=("ffmpeg" "yt-dlp" "tor")

# Crear la carpeta de medios si no existe
if [ ! -d "$DIRECTORIO" ]; then
    echo "La carpeta $DIRECTORIO no existe. Creándola..."
    mkdir -p "$DIRECTORIO"
    echo "Carpeta creada."
else
    echo "La carpeta $DIRECTORIO ya existe."
fi

# Verificar si los programas necesarios están instalados
echo "Verificando requisitos..."
for ARCHIVO in "${ARCHIVOS[@]}"; do
    if ! command -v "$ARCHIVO" &> /dev/null; then
        echo "Error: $ARCHIVO no está instalado."
        read -p "¿Deseas instalar $ARCHIVO ahora? (s/n): " INSTALAR
        if [[ "$INSTALAR" == "s" ]]; then
            if [[ "$ARCHIVO" == "ffmpeg" ]]; then
                sudo apt update && sudo apt install -y ffmpeg
            elif [[ "$ARCHIVO" == "yt-dlp" ]]; then
                sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
                sudo chmod a+rx /usr/local/bin/yt-dlp
            elif [[ "$ARCHIVO" == "tor" ]]; then
                sudo apt update && sudo apt install -y tor
            fi
        else
            echo "Instalación de $ARCHIVO cancelada. El script no funcionará correctamente sin este programa."
            exit 1
        fi
    else
        echo "$ARCHIVO está instalado."
    fi
done

# Asegurar que Tor esté en ejecución
if ! pgrep -x "tor" > /dev/null; then
    echo "Iniciando Tor..."
    tor &
    sleep 5
    echo "Tor iniciado."
else
    echo "Tor ya está en ejecución."
fi

# Función del menú principal
menu() {
    clear
    echo "================== MENU PRINCIPAL =================="
    echo "1. Descargar un video"
    echo "2. Convertir contenido de la carpeta Medios"
    echo "3. Descargar videos usando Tor"
    echo "0. Salir"
    echo "===================================================="
    read -p "Selecciona una opción: " OPCION

    case $OPCION in
        1) descargar_video ;;
        2) convertir_contenido ;;
        3) descargar_tor ;;
        0) exit 0 ;;
        *) echo "Opción no válida."; sleep 2; menu ;;
    esac
}

# Función para descargar un video
descargar_video() {
    clear
    read -p "Introduce el enlace del video: " ENLACE
    echo "================= Selecciona una calidad =================="
    echo "1. SD (480p y menos)"
    echo "2. HD (720p)"
    echo "3. Full HD (1080p)"
    echo "4. 2K (1440p)"
    echo "5. 4K (2160p)"
    echo "6. Solo audio (mp3)"
    echo "0. Volver al menú principal"
    echo "=========================================================="
    read -p "Selecciona una opción: " CALIDAD

    case $CALIDAD in
        1) FORMATO="bestvideo[height<=480]+bestaudio" ;;
        2) FORMATO="bestvideo[height<=720]+bestaudio" ;;
        3) FORMATO="bestvideo[height<=1080]+bestaudio" ;;
        4) FORMATO="bestvideo[height<=1440]+bestaudio" ;;
        5) FORMATO="bestvideo[height<=2160]+bestaudio" ;;
        6) FORMATO="bestaudio" EXTRA_OPCIONES="--extract-audio --audio-format mp3" ;;
        0) menu ;;
        *) echo "Opción no válida."; sleep 2; descargar_video ;;
    esac

    yt-dlp -f "$FORMATO" $EXTRA_OPCIONES -o "$DIRECTORIO/%(title)s.%(ext)s" "$ENLACE"
    echo "Descarga completada."
    read -p "Presiona Enter para continuar..." PAUSA
    menu
}

# Función para convertir contenido
convertir_contenido() {
    clear
    echo "================ Selecciona el formato ==================="
    echo "1. Convertir a mp4"
    echo "2. Convertir a mkv"
    echo "3. Convertir a mp3 (solo audio)"
    echo "0. Volver al menú principal"
    echo "=========================================================="
    read -p "Selecciona el formato de conversión: " FORMATO

    case $FORMATO in
        1) EXTENSION="mp4" OPCIONES="-c:v libx264 -c:a aac" ;;
        2) EXTENSION="mkv" OPCIONES="-c:v libx264 -c:a aac" ;;
        3) EXTENSION="mp3" OPCIONES="-vn -c:a libmp3lame" ;;
        0) menu ;;
        *) echo "Opción no válida."; sleep 2; convertir_contenido ;;
    esac

    for ARCHIVO in "$DIRECTORIO"/*; do
        ffmpeg -i "$ARCHIVO" $OPCIONES "$DIRECTORIO/convertido/$(basename "$ARCHIVO" .${ARCHIVO##*.}).$EXTENSION"
    done
    echo "Conversión completada."
    read -p "Presiona Enter para continuar..." PAUSA
    menu
}

# Función para descargar usando Tor
descargar_tor() {
    clear
    read -p "Introduce el enlace del video: " ENLACE
    yt-dlp --proxy socks5://127.0.0.1:9050 -o "$DIRECTORIO/%(title)s.%(ext)s" "$ENLACE"
    echo "Descarga completada."
    read -p "Presiona Enter para continuar..." PAUSA
    menu
}

# Iniciar el menú
menu
