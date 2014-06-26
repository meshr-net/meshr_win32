for /f "tokens=*" %%a in ('dir /b /od %~dp0..\tmp\backup*') do set newest=%%a
cd %~dp0..
bin\tar xf tmp/%newest%  -C . --overwrite --ignore-failed-read  --ignore-command-error