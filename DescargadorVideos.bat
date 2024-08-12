@echo off
title Descarga y Conversión de Videos
setlocal enabledelayedexpansion

REM Verificar la existencia de los archivos ejecutables
if not exist "yt-dlp.exe" (
    echo ERROR: yt-dlp no encontrado.
    echo Descarga yt-dlp desde: https://github.com/yt-dlp/yt-dlp
    pause
    exit /b
)

if not exist "ffmpeg.exe" (
    echo ERROR: ffmpeg no encontrado.
    echo Descarga ffmpeg desde: https://www.ffmpeg.org
    pause
    exit /b
)

if not exist "tor.exe" (
    echo ERROR: tor no encontrado.
    echo Descarga Tor desde: https://www.torproject.org/download/tor/
    pause
    exit /b
)

REM Comprobar si existen las carpetas necesarias
if not exist "Mp4" mkdir Mp4
if not exist "mp3" mkdir mp3
if not exist "mkv" mkdir mkv

:MENU
cls
echo #######################################
echo                MENU
echo #######################################
echo 1. Descargar un video
echo 2. Convertir un video
echo 3. Descargar un video usando Tor
echo 4. Descargar una lista de videos
echo 0. Salir
echo #######################################
set /p choice="Selecciona una opción: "

if "%choice%"=="1" goto DescargarVideo
if "%choice%"=="2" goto ConvertirVideo
if "%choice%"=="3" goto DescargarConTor
if "%choice%"=="4" goto DescargarLista
if "%choice%"=="0" exit
goto MENU

:DescargarVideo
cls
echo ######################################
echo           Descargar un video
echo ######################################
set /p url="Presione (Control + V) para pegar el enlace para la descarga del video y presione Enter: "

REM Obtener la lista de formatos disponibles
yt-dlp -F "%url%" > formats.txt

REM Verificar las calidades disponibles
set SD_AVAILABLE=0
set HD_AVAILABLE=0
set FULLHD_AVAILABLE=0
set _2K_AVAILABLE=0
set _4K_AVAILABLE=0

for /f "tokens=1,2" %%a in (formats.txt) do (
    set FORMAT_ID=%%a
    if "!FORMAT_ID!"=="397" set SD_AVAILABLE=1
    if "!FORMAT_ID!"=="398" set HD_AVAILABLE=1
    if "!FORMAT_ID!"=="399" set FULLHD_AVAILABLE=1
    if "!FORMAT_ID!"=="400" set _2K_AVAILABLE=1
    if "!FORMAT_ID!"=="401" set _4K_AVAILABLE=1
)

del formats.txt

REM Generar el menú de formatos disponibles
echo 0. Best
set index=1
set FORMAT_LIST=bestvideo+bestaudio/

if %SD_AVAILABLE%==1 (
    echo !index!. SD
    set FORMAT_LIST=!FORMAT_LIST!397/
    set /a index+=1
)
if %HD_AVAILABLE%==1 (
    echo !index!. HD
    set FORMAT_LIST=!FORMAT_LIST!398/
    set /a index+=1
)
if %FULLHD_AVAILABLE%==1 (
    echo !index!. Full-HD
    set FORMAT_LIST=!FORMAT_LIST!399/
    set /a index+=1
)
if %_2K_AVAILABLE%==1 (
    echo !index!. 2K
    set FORMAT_LIST=!FORMAT_LIST!400/
    set /a index+=1
)
if %_4K_AVAILABLE%==1 (
    echo !index!. 4K
    set FORMAT_LIST=!FORMAT_LIST!401/
    set /a index+=1
)

set /p quality="Ingrese el número de la calidad para descargar: "
if "%quality%"=="0" set "FORMAT_TO_DOWNLOAD=bestvideo+bestaudio"
if not "%quality%"=="0" set "FORMAT_TO_DOWNLOAD=!FORMAT_LIST:~0,-1!"

REM Descargar el video con la calidad seleccionada, mejor audio, subtítulos, thumbnails y todos los idiomas
yt-dlp -f "%FORMAT_TO_DOWNLOAD%" --write-sub --write-auto-sub --embed-subs --sub-lang en,es --write-thumbnail --embed-thumbnail --add-metadata --merge-output-format mkv "%url%" -o "mkv\%%(title)s.%%(ext)s" --audio-multistreams

echo.
echo ¡Descarga completada exitosamente!
pause
goto MENU

:ConvertirVideo
cls
echo ######################
echo     Convertir un video
echo ######################
echo Por favor ingrese su video dentro del folder Mkv
echo y seleccione el formato al cual desea convertir
echo 0. Salir al menu principal
echo 1. mp4
echo 2. mov
echo 3. mp3

set /p format_choice="Seleccione un formato: "
if "%format_choice%"=="0" goto MENU

REM Realizar la conversión según la selección
for %%i in ("mkv\*.mkv") do (
    if "%format_choice%"=="1" ffmpeg -i "%%i" -c copy "Mp4\%%~ni.mp4"
    if "%format_choice%"=="2" ffmpeg -i "%%i" -c copy "Mp4\%%~ni.mov"
    if "%format_choice%"=="3" ffmpeg -i "%%i" -vn -acodec copy "mp3\%%~ni.mp3"
)

echo.
echo ¡Conversión completada exitosamente!
pause
goto MENU

:DescargarConTor
cls
echo ######################################
echo  Descargar un video usando Tor
echo ######################################
echo Activando Tor...
tor.exe

REM Descargar el video a través de Tor
set /p url="Presione (Control + V) para pegar el enlace para la descarga del video y presione Enter: "
yt-dlp --proxy socks5://127.0.0.1:9050 -f bestvideo+bestaudio --write-sub --write-auto-sub --embed-subs --sub-lang en,es --write-thumbnail --embed-thumbnail --add-metadata --merge-output-format mkv "%url%" -o "mkv\%%(title)s.%%(ext)s" --audio-multistreams

echo.
echo ¡Descarga completada usando Tor!
pause
goto MENU

:DescargarLista
cls
echo ######################################
echo    Descargar una lista de videos
echo ######################################
set /p url="Presione (Control + V) para pegar el enlace de la lista de videos y presione Enter: "

REM Descargar la lista completa en la mejor calidad de video y audio, incluyendo subtítulos y thumbnails
yt-dlp -f bestvideo+bestaudio --yes-playlist --write-sub --write-auto-sub --embed-subs --sub-lang en,es --write-thumbnail --embed-thumbnail --add-metadata --merge-output-format mkv "%url%" -o "mkv\%%(playlist)s/%%(title)s.%%(ext)s" --audio-multistreams --min-sleep-interval 10 --max-sleep-interval 30

echo.
echo ¡Lista de videos descargada exitosamente!
pause
goto MENU
