echo off
SETLOCAL

set argC=0
for %%x in (%*) do Set /A argC+=1
if NOT "1" == "%argC%" (
    echo "Invalidate arguments"
    goto :eof
    )

set url="https://api.powerbi.com/beta/72f988bf-86f1-41af-91ab-2d7cd011db47/datasets/2ff1e8a8-2f6f-4d73-a75d-86829e3f4574/rows?key=8f5xLp1gP8%%2FzSee4vCUBcyjR65I9zZ6nb%%2B%%2F7bbzex%%2FSctLX3ntIlAR0sxWpDdguuYyDtLdHK%%2Fxbxj%%2FrSBkX7eQ%%3D%%3D"

for /f "tokens=2-4 delims=-/., "  %%a in ("%date%") do (
        set MM=%%a
        set DD=%%b
        set YYYY=%%c
    )

rem For yyyy/mm/dd
set YY=%YYYY:~0,2%
if not "%YY%" == "20" (
    for /f "tokens=1-3 delims=-/., "  %%a in ("%date%") do (
            set YYYY=%%a
            set MM=%%b
            set DD=%%c
        )
    )

set datetime=%YYYY%-%MM%-%DD%T%time: =0%0+0800
set devie_info=Win-%USERNAME%

rem ----------------- for GEO info -----------------
set tmpPath=%userprofile%\AppData\Local\Temp\
if not exist "%tmpPath%ip_info.tmp" (
    curl.exe ipinfo.io > %tmpPath%ip_info.tmp
)

if not exist "%tmpPath%ip_country.tmp" (
    findstr.exe country %tmpPath%ip_info.tmp > %tmpPath%ip_country.tmp
    powershell -Command "(gc %tmpPath%ip_country.tmp) -replace '\"country\":', '' | Out-File -encoding ASCII %tmpPath%ip_country.tmp"
    powershell -Command "(gc %tmpPath%ip_country.tmp) -replace '""' , '' | Out-File -encoding ASCII %tmpPath%ip_country.tmp"
    powershell -Command "(gc %tmpPath%ip_country.tmp) -replace ',' , '' | Out-File -encoding ASCII %tmpPath%ip_country.tmp"
)

if not exist "%tmpPath%ip_city.tmp" (
    findstr.exe city %tmpPath%ip_info.tmp > %tmpPath%ip_city.tmp
    powershell -Command "(gc %tmpPath%ip_city.tmp) -replace '\"city\":', '' | Out-File -encoding ASCII %tmpPath%ip_city.tmp"
    powershell -Command "(gc %tmpPath%ip_city.tmp) -replace '""' , '' | Out-File -encoding ASCII %tmpPath%ip_city.tmp"
    powershell -Command "(gc %tmpPath%ip_city.tmp) -replace ',' , '' | Out-File -encoding ASCII %tmpPath%ip_city.tmp"
)

if not exist "%tmpPath%ip_org.tmp" (
    findstr.exe org %tmpPath%ip_info.tmp > %tmpPath%ip_org.tmp
    powershell -Command "(gc %tmpPath%ip_org.tmp) -replace '\"org\":', '' | Out-File -encoding ASCII %tmpPath%ip_org.tmp"
    powershell -Command "(gc %tmpPath%ip_org.tmp) -replace '""' , '' | Out-File -encoding ASCII %tmpPath%ip_org.tmp"
    powershell -Command "(gc %tmpPath%ip_org.tmp) -replace ',' , '' | Out-File -encoding ASCII %tmpPath%ip_org.tmp"
)

set /p country=<%tmpPath%ip_country.tmp
set /p city=<%tmpPath%ip_city.tmp
set /p org=<%tmpPath%ip_org.tmp
set raw_data=[{^
\"device_info\" :\"%devie_info%\",^
\"project_info\" :\"%1\",^
\"time\" :\"%datetime%\",^
\"weight\" : 1,^
\"country\" :\"%country%\",^
\"city\" :\"%city%\",^
\"org\" :\"%org%\"^
}]

curl.exe --include --request POST --header "Content-Type: application/json" --data-binary "%raw_data%" "%url%"

exit /B 0
