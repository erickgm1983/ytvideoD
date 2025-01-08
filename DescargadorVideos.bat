@echo off
setlocal enabledelayedexpansion

rem Obtener el directorio del script
set "directorio=%~dp0Medios"

rem Definir archivos necesarios y sus enlaces de descarga
set "archivos=ffmpeg.exe yt-dlp.exe tor.exe"
set "enlace_ffmpeg=https://ffmpeg.org/download.html"
set "enlace_yt_dlp=https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
set "enlace_tor=https://archive.torproject.org/tor-package-archive/torbrowser/14.0.3/tor-expert-bundle-windows-x86_64-14.0.3.tar.gz"

rem Verificar si la carpeta "Medios" existe, si no, crearla
if not exist "%directorio%" (
    echo La carpeta %directorio% no existe. Creando la carpeta...
    mkdir "%directorio%"
    echo Carpeta %directorio% creada.
) else (
    echo La carpeta %directorio% ya existe.
)

rem Verificar si los archivos necesarios existen
for %%f in (%archivos%) do if not exist "%%f" (
    echo Error: El archivo %%f no se encuentra.
    if "%%f"=="ffmpeg.exe" (
        echo Intentando descargar ffmpeg...
        curl -o ffmpeg.exe "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip" || (
            echo No se pudo descargar ffmpeg automaticamente.
            echo Por favor, descárgalo manualmente desde: %enlace_ffmpeg%
        )
    )
    if "%%f"=="yt-dlp.exe" (
        echo Intentando descargar yt-dlp...
        curl -L -o yt-dlp.exe "%enlace_yt_dlp%" || (
            echo No se pudo descargar yt-dlp automaticamente.
            echo Por favor, descárgalo manualmente desde: %enlace_yt_dlp%
        )
    )
    if "%%f"=="tor.exe" (
        echo Intentando descargar Tor...
        start "" %enlace_tor%
        echo No se pudo descargar Tor automaticamente.
        echo Por favor, descárgalo manualmente desde el enlace abierto en tu navegador.
    )
    pause
)

rem Asegurar que Tor esté corriendo
for /f "tokens=*" %%i in ('tasklist /fi "imagename eq tor.exe" ^| find /i "tor.exe"') do set tor_running=%%i
if not defined tor_running (
    echo Iniciando Tor...
    start /min tor.exe
    timeout /t 5 > nul
    echo Tor iniciado.
) else (
    echo Tor ya está en ejecución.
)

:menu
cls
echo.
echo "================== MENU PRINCIPAL =================="
echo "#                                                   #"
echo "#      1. Descargar un video                        #"
echo "#      2. Convertir contenido de la carpeta Medios  #"
echo "#      3. Descargar videos usando Tor               #"
echo "#      0. Salir                                     #"
echo "====================================================="
echo.
set /p opcion=Selecciona una opcion: 

if "%opcion%"=="1" goto :descargar_video
if "%opcion%"=="2" goto :convertir_contenido
if "%opcion%"=="3" goto :descargar_tor
if "%opcion%"=="0" exit /b

goto :menu

:descargar_video
cls
set /p enlace=Introduce el enlace del video: 
echo.
echo "================= Selecciona una calidad =================="
echo "1. SD (480p y menos)"
echo "2. HD (720p)"
echo "3. Full HD (1080p)"
echo "4. 2K (1440p)"
echo "5. 4K (2160p)"
echo "6. Solo audio (mp3)"
echo "0. Volver al menu principal"
echo "========================================================="
echo.
set /p calidad=Selecciona una opcion: 

if "%calidad%"=="0" goto :menu
if "%calidad%"=="1" set "format=bestvideo[height<=480]+bestaudio"
if "%calidad%"=="2" set "format=bestvideo[height<=720]+bestaudio"
if "%calidad%"=="3" set "format=bestvideo[height<=1080]+bestaudio"
if "%calidad%"=="4" set "format=bestvideo[height<=1440]+bestaudio"
if "%calidad%"=="5" set "format=bestvideo[height<=2160]+bestaudio"
if "%calidad%"=="6" set "format=bestaudio" & set "extra_options=--extract-audio --audio-format mp3"

if not defined format goto :descargar_video

set "output=%directorio%\%%(title)s.%%(ext)s"
yt-dlp -f "%format%" %extra_options% -o "%output%" "%enlace%" --recode mp4
echo Descarga completada.
pause
goto :menu

:convertir_contenido
cls
echo.
echo "================ Selecciona el formato ==================="
echo "1. Convertir a mp4"
echo "2. Convertir a mkv"
echo "3. Convertir a mp3 (solo audio)"
echo "0. Volver al menu principal"
echo "========================================================="
echo.
set /p formato=Selecciona el formato de conversion: 

if "%formato%"=="0" goto :menu
if "%formato%"=="1" set "extension=mp4" & set "opciones=-c:v libx264 -c:a aac"
if "%formato%"=="2" set "extension=mkv" & set "opciones=-c:v libx264 -c:a aac"
if "%formato%"=="3" set "extension=mp3" & set "opciones=-vn -c:a libmp3lame"

if not defined extension goto :convertir_contenido

set "subcarpeta=%directorio%\%extension%"
if not exist "%subcarpeta%" mkdir "%subcarpeta%"

for %%f in ("%directorio%\*.*") do ffmpeg -i "%%f" %opciones% "%subcarpeta%\%%~nf.%extension%"
echo Conversion completada.
pause
goto :menu

:descargar_tor
cls
set /p enlace=Introduce el enlace del video: 
echo Descargando video usando Tor...
yt-dlp --proxy socks5://127.0.0.1:9050 -o "%directorio%\%%(title)s.%%(ext)s" "%enlace%" --recode mp4
echo Descarga completada.
pause
goto :menu
