if not defined meshr cd %~dp0..
if not defined meshr SET meshr=%CD:\=/%
set wf=%SYSTEMROOT:\=/%
set wf=/%wf::=%
%meshr%/bin/sh.exe -c "export meshr=%meshr%; export PATH=/${meshr/:/}/bin:%wf%:%wf%/System32:%wf%/System32/Wbem:$PATH; %*"
rem > %meshr:/=\%\tmp\sh.log 2>&1
rem pause