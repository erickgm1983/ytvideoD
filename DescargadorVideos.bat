@echo off
setlocal enabledelayedexpansion

rem Obtener el directorio del script
set "directorio=%~dp0Medios"

rem Definir archivos a verificar
set "archivos=ffmpeg.exe ffplay.exe ffprobe.exe tor.exe yt-dlp.exe"

rem Verificar si la carpeta existe, si no, crearla
if not exist "%directorio%" (
    echo La carpeta %directorio% no existe. Creando la carpeta...
    mkdir "%directorio%"
    echo Carpeta %directorio% creada.
) else (
    echo La carpeta %directorio% ya existe.
)

:menu
cls
echo .

echo .
echo Paypal: 
echo "https://www.paypal.com/paypalme/eidosred?country.x=HN&locale.x=es_XC"
echo .
echo "================== MENU PRINCIPAL =================="
echo "#                                                   #"
echo "#      1. Descargar un video                        #"
echo "#                                                   #"
echo "#      2. Convertir el contenido de la carpeta      #"
echo "#         Medios                                    #"
echo "#                                                   #"
echo "#      3. Descargar videos usando Tor               #"
echo "#                                                   #"
echo "#      0. Salir                                     #"
echo "#                                                   #"
echo "====================================================="
echo.
set /p opcion=Selecciona una opcion: 

rem Procesar la opcion seleccionada
if "%opcion%"=="1" goto :agregar_video
if "%opcion%"=="2" goto :convertir_contenido
if "%opcion%"=="3" goto :descargar_videos
if "%opcion%"=="0" exit /b

goto :menu

:agregar_video
cls
rem Solicitar al usuario el enlace para descargar
set /p enlace=Introduce el enlace del video: 

rem Definir listas de formatos
set "formats_sd=278 394 160 603 242 395 133 604"
set "formats_hd=243 396 134 18 605 244 397 135 606"
set "formats_fullhd=247 398 136 609 248 399 137 614"
set "formats_2k=271 400 620"
set "formats_4k=313 401 625"
set "formats_best=best"

rem Generar menu dinamico basado en los formatos disponibles
echo .
echo "   erickgm1983@gmail.com   "
echo "###################################################"
echo "## PREFERENCIA DE FORMATO SI ESTA DISPONIBLE      ##"
echo "###################################################"
echo .  En caso de no estar disponible buscara un formato menor
echo "================= Selecciona una opcion =================="
echo "|                                                       |"
echo "| 1. SD 480p                                            |"
echo "| 2. HD 720p                                            |"
echo "| 3. Full HD 1080p                                      |"
echo "| 4. 2K 1440p                                           |"
echo "| 5. 4K 2160p                                           |"
echo "| 6. Audio mp3                                          |"
echo "| 7. Descargar la mejor calidad disponible              |"
echo "| 8. Descargar Predeterminado                           |"
echo "| 0. Volver al menu principal                           |"
echo "========================================================="
echo.
set /p resolucion=Selecciona una opcion:

rem Procesar la opcion seleccionada
if "%resolucion%"=="0" goto :menu

if "%resolucion%"=="1" (
    echo Descargando SD...
    set /a "random_interval=5 + %RANDOM% %% 16"
    yt-dlp -f "bestvideo[height<=480]+bestaudio" --sleep-interval !random_interval! -o "%directorio%\%%(title)s.%%(ext)s" "%enlace%"
    goto :menu
)

if "%resolucion%"=="2" (
    echo Descargando HD...
    set /a "random_interval=5 + %RANDOM% %% 16"
    yt-dlp -f "bestvideo[height<=720]+bestaudio" --sleep-interval !random_interval! -o "%directorio%\%%(title)s.%%(ext)s" "%enlace%"
    goto :menu
)

if "%resolucion%"=="3" (
    echo Descargando Full HD...
    set /a "random_interval=5 + %RANDOM% %% 16"
    yt-dlp -f "bestvideo[height<=1080]+bestaudio" --sleep-interval !random_interval! -o "%directorio%\%%(title)s.%%(ext)s" "%enlace%"
    goto :menu
)

if "%resolucion%"=="4" (
    echo Descargando 2K...
    set /a "random_interval=5 + %RANDOM% %% 16"
    yt-dlp -f "bestvideo[height<=1440]+bestaudio" --sleep-interval !random_interval! -o "%directorio%\%%(title)s.%%(ext)s" "%enlace%"
    goto :menu
)

if "%resolucion%"=="5" (
    echo Descargando 4K...
    set /a "random_interval=5 + %RANDOM% %% 16"
    yt-dlp -f "bestvideo[height<=2160]+bestaudio" --sleep-interval !random_interval! -o "%directorio%\%%(title)s.%%(ext)s" "%enlace%"
    goto :menu
)

if "%resolucion%"=="6" (
    echo Descargando solo audio en formato mp3...
    set /a "random_interval=5 + %RANDOM% %% 16"
    yt-dlp -f "bestaudio" --sleep-interval !random_interval! --extract-audio --audio-format mp3 -o "%directorio%\%%(title)s.%%(ext)s" "%enlace%"
    goto :menu
)

if "%resolucion%"=="7" (
    echo Descargando la mejor calidad disponible...
    set /a "random_interval=5 + %RANDOM% %% 16"
    yt-dlp -f "bestvideo+bestaudio" --sleep-interval !random_interval! -o "%directorio%\%%(title)s.%%(ext)s" "%enlace%"
    goto :menu
)

if "%resolucion%"=="8" (
    echo Descargando la mejor calidad disponible...
    set /a "random_interval=5 + %RANDOM% %% 16"
    yt-dlp --sleep-interval !random_interval! -o "%directorio%\%%(title)s.%%(ext)s" "%enlace%"
    goto :menu
)

goto :menu

:convertir_contenido
cls
rem Mostrar opciones de formatos de conversion
echo .
echo "###################################################"
echo "##            FORMATO DE CONVERSIoN               ##"
echo "###################################################"
echo .
echo "================ Selecciona el formato ==================="
echo "|                                                       |"
echo "| 1. Convertir a mp4                                    |"
echo "| 2. Convertir a mkv                                    |"
echo "| 3. Convertir a avi                                    |"
echo "| 4. Convertir a mp3 (solo audio)                       |"
echo "| 0. Volver al menu principal                           |"
echo "========================================================="
echo.
set /p formato=Selecciona el formato de conversion: 

if "%formato%"=="0" goto :menu

rem Definir la extension y opciones de conversion basadas en la seleccion
if "%formato%"=="1" set "extension=mp4" & set "opciones=-c:v libx264 -c:a aac"
if "%formato%"=="2" set "extension=mkv" & set "opciones=-c:v libx264 -c:a aac"
if "%formato%"=="3" set "extension=avi" & set "opciones=-c:v libxvid -c:a libmp3lame"
if "%formato%"=="4" set "extension=mp3" & set "opciones=-vn -c:a libmp3lame"

rem Verificar si se selecciono un formato valido
if not defined extension goto :convertir_contenido

rem Crear subcarpeta para el formato si no existe
set "subcarpeta=%directorio%\%extension%"
if not exist "%subcarpeta%" (
    echo Creando subcarpeta para %extension%...
    mkdir "%subcarpeta%"
)

rem Procesar todos los archivos en la carpeta "Medios"
for %%f in ("%directorio%\*.*") do (
    ffmpeg -i "%%f" %opciones% "%subcarpeta%\%%~nf.%extension%"
)

echo Conversion completada. Los archivos convertidos se han guardado en %subcarpeta%.
goto :menu

:descargar_videos
cls
rem Descargar un video usando Tor
set /p enlace=Introduce el enlace del video para descargar con Tor: 
echo Descargando video usando Tor...
yt-dlp --proxy socks5://127.0.0.1:9050 -o "%directorio%\%%(title)s.%%(ext)s" "%enlace%"
goto :menu
