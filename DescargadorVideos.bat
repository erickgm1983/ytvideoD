@echo off
setlocal enabledelayedexpansion

:: Archivos ejecutables necesarios
set FFMPEG=ffmpeg.exe
set YTDLP=yt-dlp.exe
set TOR=tor.exe

:: Folders para almacenar los videos descargados y convertidos
set MP4_FOLDER=Mp4
set MKV_FOLDER=mkv
set MP3_FOLDER=Mp3
set CONVERT_FOLDER=Convertir

:: Crear las carpetas si no existen
if not exist "%MP4_FOLDER%" mkdir "%MP4_FOLDER%"
if not exist "%MKV_FOLDER%" mkdir "%MKV_FOLDER%"
if not exist "%MP3_FOLDER%" mkdir "%MP3_FOLDER%"
if not exist "%CONVERT_FOLDER%" mkdir "%CONVERT_FOLDER%"

:: Menu de opciones
:MENU
cls
echo creado por erickgm1983@gmail.com
echo #######################################
echo MENU 
echo #######################################
echo 1 Descargar un video
echo 2 Descargar un video con Tor
echo 3 Convertir todos los videos dentro de la carpeta Convertir
echo 4 Salir
echo.
set /p OPTION=Seleccione una opcion:

if "%OPTION%"=="1" goto DOWNLOAD
if "%OPTION%"=="2" goto DOWNLOAD_TOR
if "%OPTION%"=="3" goto CONVERT_ALL
if "%OPTION%"=="4" exit /b

:: Opción para descargar video
:DOWNLOAD
cls
echo ######################################
echo Descargar un video
echo ######################################
set /p URL=Pegue aquí el enlace para la descarga del video y presione enter:

:: Obtener las calidades disponibles
for /f "tokens=1-2" %%i in ('%YTDLP% -F %URL%') do (
    set FORMAT_ID=%%i
    set RESOLUTION=%%j

    :: Verificar las calidades disponibles basadas en los IDs
    if "!FORMAT_ID!"=="397" set SD_AVAILABLE=1
    if "!FORMAT_ID!"=="398" set HD_AVAILABLE=1
    if "!FORMAT_ID!"=="399" set FULLHD_AVAILABLE=1
    if "!FORMAT_ID!"=="400" set _2K_AVAILABLE=1
    if "!FORMAT_ID!"=="401" set _4K_AVAILABLE=1
)

cls
echo #######################################
echo Formatos Disponibles
echo #######################################
echo 0 Best

if defined SD_AVAILABLE echo 2 SD (480p)
if defined HD_AVAILABLE echo 3 HD (720p)
if defined FULLHD_AVAILABLE echo 4 Full-HD (1080p)
if defined _2K_AVAILABLE echo 5 2K (1440p)
if defined _4K_AVAILABLE echo 6 4K (2160p)
echo.

set /p FORMAT_OPTION=Ingrese el número de la calidad para descargar:

:: Asignar el ID correspondiente según la selección
if "%FORMAT_OPTION%"=="0" set FORMAT_ID=best
if "%FORMAT_OPTION%"=="2" set FORMAT_ID=397
if "%FORMAT_OPTION%"=="3" set FORMAT_ID=398
if "%FORMAT_OPTION%"=="4" set FORMAT_ID=399
if "%FORMAT_OPTION%"=="5" set FORMAT_ID=400
if "%FORMAT_OPTION%"=="6" set FORMAT_ID=401

:: Descargar el video con la calidad seleccionada, incluyendo subtítulos y miniatura
%YTDLP% -f %FORMAT_ID%+bestaudio --embed-subs --embed-thumbnail %URL% -o "%MP4_FOLDER%/%%(title)s.%%(ext)s"

goto CONVERT_TO_MKV

:: Opción para descargar video con Tor
:DOWNLOAD_TOR
cls
echo ######################################
echo Descargar un video con Tor
echo ######################################
set /p URL=Pegue aquí el enlace para la descarga del video y presione enter:

:: Iniciar Tor y esperar a que se conecte al proxy
start %TOR%
timeout /t 20 >nul

:: Obtener las calidades disponibles a través de Tor
for /f "tokens=1-2" %%i in ('%YTDLP% --proxy socks5://127.0.0.1:9050 -F %URL%') do (
    set FORMAT_ID=%%i
    set RESOLUTION=%%j

    :: Verificar las calidades disponibles basadas en los IDs
    if "!FORMAT_ID!"=="397" set SD_AVAILABLE=1
    if "!FORMAT_ID!"=="398" set HD_AVAILABLE=1
    if "!FORMAT_ID!"=="399" set FULLHD_AVAILABLE=1
    if "!FORMAT_ID!"=="400" set _2K_AVAILABLE=1
    if "!FORMAT_ID!"=="401" set _4K_AVAILABLE=1
)

cls
echo #######################################
echo Formatos Disponibles a través de Tor
echo #######################################
echo 0 Best

if defined SD_AVAILABLE echo 2 SD (480p)
if defined HD_AVAILABLE echo 3 HD (720p)
if defined FULLHD_AVAILABLE echo 4 Full-HD (1080p)
if defined _2K_AVAILABLE echo 5 2K (1440p)
if defined _4K_AVAILABLE echo 6 4K (2160p)
echo.

set /p FORMAT_OPTION=Ingrese el número de la calidad para descargar:

:: Asignar el ID correspondiente según la selección
if "%FORMAT_OPTION%"=="0" set FORMAT_ID=best
if "%FORMAT_OPTION%"=="2" set FORMAT_ID=397
if "%FORMAT_OPTION%"=="3" set FORMAT_ID=398
if "%FORMAT_OPTION%"=="4" set FORMAT_ID=399
if "%FORMAT_OPTION%"=="5" set FORMAT_ID=400
if "%FORMAT_OPTION%"=="6" set FORMAT_ID=401

:: Descargar el video con la calidad seleccionada, incluyendo subtítulos y miniatura, a través de Tor
%YTDLP% --proxy socks5://127.0.0.1:9050 -f %FORMAT_ID%+bestaudio --embed-subs --embed-thumbnail %URL% -o "%MP4_FOLDER%/%%(title)s.%%(ext)s"

goto CONVERT_TO_MKV

:: Convertir a MKV
:CONVERT_TO_MKV
cls
echo ######################################
echo Convertir videos a MKV
echo ######################################

for %%f in ("%MP4_FOLDER%\*.mp4") do (
    %FFMPEG% -i "%%f" -c copy -map 0 "%MKV_FOLDER%\%%~nf.mkv"
)

echo Conversion a MKV completada.
goto MENU

:: Opción para convertir todos los videos en la carpeta "Convertir"
:CONVERT_ALL
cls
echo ######################################
echo Convertir todos los videos en la carpeta Convertir
echo ######################################
echo Asegúrese de que todos los archivos que desea convertir estén dentro de la carpeta "%CONVERT_FOLDER%"
echo.

:: Mostrar opciones de formato
echo 1. Convertir a MP4
echo 2. Convertir a MKV
echo 3. Convertir a MP3
echo.
set /p FORMAT_OPTION=Seleccione el formato de salida:

:: Asignar la carpeta de destino según la selección
if "%FORMAT_OPTION%"=="1" (
    set FORMAT=mp4
    set DEST_FOLDER=%MP4_FOLDER%
) else if "%FORMAT_OPTION%"=="2" (
    set FORMAT=mkv
    set DEST_FOLDER=%MKV_FOLDER%
) else if "%FORMAT_OPTION%"=="3" (
    set FORMAT=mp3
    set DEST_FOLDER=%MP3_FOLDER%
) else (
    echo Opción no válida.
    pause
    goto CONVERT_ALL
)

:: Convertir todos los archivos en la carpeta "Convertir"
for %%f in ("%CONVERT_FOLDER%\*.*") do (
    if not "%%~xf"==".%FORMAT%" (
        if "%FORMAT%"=="mp3" (
            %FFMPEG% -i "%%f" -q:a 0 -map a "%DEST_FOLDER%\%%~nf.%FORMAT%"
        ) else (
            %FFMPEG% -i "%%f" -c:v libx264 -crf 23 -preset medium -c:a aac -strict experimental "%DEST_FOLDER%\%%~nf.%FORMAT%"
        )
    )
)

echo Conversion a %FORMAT% completada.
pause
goto MENU
