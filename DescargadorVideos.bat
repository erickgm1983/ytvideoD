@echo off
setlocal enabledelayedexpansion

rem Obtener el directorio del script
set "directorio=%~dp0Medios"
set "lista=%~dp0lista.txt"

rem Definir archivos a verificar
set "archivos=ffmpeg.exe ffplay.exe ffprobe.exe tor.exe yt-dlp.exe"

rem Limpiar la lista si ya existe
if exist "%lista%" (
    echo Limpiando lista.txt...
    > "%lista%" rem Limpiar el archivo
    echo lista.txt ha sido limpiado.
)

rem Verificar si la carpeta existe, si no, crearla
if not exist "%directorio%" (
    echo La carpeta %directorio% no existe. Creando la carpeta...
    mkdir "%directorio%"
    echo Carpeta %directorio% creada.
) else (
    echo La carpeta %directorio% ya existe.
)

:menu
echo #######################################
echo ##                                   ##
echo ##            MENU PRINCIPAL         ##
echo ##                                   ##
echo #######################################
echo ##                                   ##
echo ## 1. Agregar un video a la lista    ##
echo ##                                   ##
echo ## 2. Convertir el contenido de la   ##
echo ##    carpeta Medios                 ##
echo ##                                   ##
echo ## 3. Descargar mp3                  ##
echo ##                                   ##
echo ## 4. Descargar videos de la lista   ##
echo ##    usando Tor                     ##
echo ##                                   ##
echo ## 5. Limpiar lista                  ##
echo ##                                   ##
echo ## 0. Salir                          ##
echo ##                                   ##
echo #######################################
echo.
set /p opcion=Selecciona una opcion: 

rem Procesar la opción seleccionada
if "%opcion%"=="1" goto :agregar_video
if "%opcion%"=="2" goto :convertir_contenido
if "%opcion%"=="3" echo Opción 3 seleccionada
if "%opcion%"=="4" echo Opción 4 seleccionada
if "%opcion%"=="5" goto :limpiar_lista
if "%opcion%"=="0" exit /b

goto :menu

:agregar_video
rem Solicitar al usuario el enlace para agregar
set /p enlace=Introduce el enlace del video: 

rem Agregar el enlace al archivo lista.txt, rodeado de comillas
echo "%enlace%" >> "%lista%"

echo Enlace agregado a lista.txt.

rem Verificar formatos disponibles usando yt-dlp
yt-dlp --list-formats "%enlace%" > "%temp%\formats.txt"

rem Definir listas de formatos
set "formats_sd=278 394 160 603 242 395 133 604"
set "formats_hd=243 396 134 18 605 244 397 135 606"
set "formats_fullhd=247 398 136 609 248 399 137 614"
set "formats_2k=271 400 620"
set "formats_4k=313 401 625"
set "formats_best=best"

rem Inicializar variables de selección
set "available_sd="
set "available_hd="
set "available_fullhd="
set "available_2k="
set "available_4k="
set "selected_format="

rem Filtrar disponibles formatos
for %%F in (%formats_sd%) do (
    findstr /c:"%%F" "%temp%\formats.txt" >nul && set "available_sd=SD (480p y menos)" && set "selected_format=bestvideo[height<=480]+bestaudio"
)

for %%F in (%formats_hd%) do (
    findstr /c:"%%F" "%temp%\formats.txt" >nul && set "available_hd=HD (720p)" && set "selected_format=bestvideo[height<=720]+bestaudio"
)

for %%F in (%formats_fullhd%) do (
    findstr /c:"%%F" "%temp%\formats.txt" >nul && set "available_fullhd=Full HD (1080p)" && set "selected_format=bestvideo[height<=1080]+bestaudio"
)

for %%F in (%formats_2k%) do (
    findstr /c:"%%F" "%temp%\formats.txt" >nul && set "available_2k=2K (1440p)" && set "selected_format=bestvideo[height<=1440]+bestaudio"
)

for %%F in (%formats_4k%) do (
    findstr /c:"%%F" "%temp%\formats.txt" >nul && set "available_4k=4K (2160p)" && set "selected_format=bestvideo[height<=2160]+bestaudio"
)

if exist "%temp%\formats.txt" (
    del "%temp%\formats.txt"
)

rem Generar menú dinámico basado en los formatos disponibles
echo #######################################
echo ##          FORMATO DISPONIBLE        ##
echo #######################################
echo.

set "counter=1"

if not "!available_sd!"=="" (
    echo !counter!. !available_sd!
    set /a counter+=1
)

if not "!available_hd!"=="" (
    echo !counter!. !available_hd!
    set /a counter+=1
)

if not "!available_fullhd!"=="" (
    echo !counter!. !available_fullhd!
    set /a counter+=1
)

if not "!available_2k!"=="" (
    echo !counter!. !available_2k!
    set /a counter+=1
)

if not "!available_4k!"=="" (
    echo !counter!. !available_4k!
    set /a counter+=1
)

echo !counter!. Descargar la mejor calidad disponible
set /a counter+=1

echo 0. Volver al menú principal
echo.
set /p resolucion=Selecciona una opción:

rem Procesar la opción seleccionada
if "%resolucion%"=="0" goto :menu

if "%resolucion%"=="1" (
    echo Descargando SD...
    yt-dlp -f "bestvideo[height<=480]+bestaudio" -o "%directorio%\%%(title)s.%%(ext)s" "%enlace%"
    goto :menu
)

if "%resolucion%"=="2" (
    echo Descargando HD...
    yt-dlp -f "bestvideo[height<=720]+bestaudio" -o "%directorio%\%%(title)s.%%(ext)s" "%enlace%"
    goto :menu
)

if "%resolucion%"=="3" (
    echo Descargando Full HD...
    yt-dlp -f "bestvideo[height<=1080]+bestaudio" -o "%directorio%\%%(title)s.%%(ext)s" "%enlace%"
    goto :menu
)

if "%resolucion%"=="4" (
    echo Descargando 2K...
    yt-dlp -f "bestvideo[height<=1440]+bestaudio" -o "%directorio%\%%(title)s.%%(ext)s" "%enlace%"
    goto :menu
)

if "%resolucion%"=="5" (
    echo Descargando 4K...
    yt-dlp -f "bestvideo[height<=2160]+bestaudio" -o "%directorio%\%%(title)s.%%(ext)s" "%enlace%"
    goto :menu
)

if "%resolucion%"=="6" (
    echo Descargando la mejor calidad disponible...
    yt-dlp -f "bestvideo+bestaudio" -o "%directorio%\%%(title)s.%%(ext)s" "%enlace%"
    goto :menu
)

goto :menu

:convertir_contenido
rem Mostrar opciones de formatos de conversión
echo #######################################
echo ##        FORMATO DE CONVERSIÓN       ##
echo #######################################
echo.
echo 1. Convertir a mp4
echo 2. Convertir a mkv
echo 3. Convertir a avi
echo 4. Convertir a mp3 (solo audio)
echo 0. Volver al menú principal
echo.
set /p formato=Selecciona el formato de conversión: 

if "%formato%"=="0" goto :menu

rem Definir la extensión y opciones de conversión basadas en la selección
if "%formato%"=="1" set "extension=mp4" & set "opciones=-c:v libx264 -c:a aac"
if "%formato%"=="2" set "extension=mkv" & set "opciones=-c:v libx264 -c:a aac"
if "%formato%"=="3" set "extension=avi" & set "opciones=-c:v libxvid -c:a libmp3lame"
if "%formato%"=="4" set "extension=mp3" & set "opciones=-vn -c:a libmp3lame"

rem Verificar si se seleccionó un formato válido
if not defined extension goto :convertir_contenido

rem Crear subcarpeta para el formato si no existe
set "subcarpeta=%directorio%\%extension%"
if not exist "%subcarpeta%" (
    mkdir "%subcarpeta%"
    echo Subcarpeta %subcarpeta% creada.
)

rem Procesar cada archivo en la carpeta Medios
for %%A in ("%directorio%\*.*") do (
    echo Convirtiendo "%%~nxA" a %extension%...
    ffmpeg -i "%%A" %opciones% "%subcarpeta%\%%~nA.%extension%"
)

echo Conversión completada.
goto :menu

:limpiar_lista
rem Limpiar el archivo lista.txt
if exist "%lista%" (
    del "%lista%"
    echo lista.txt ha sido limpiado.
) else (
    echo lista.txt no existe.
)
goto :menu
