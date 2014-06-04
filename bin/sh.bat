set wf=%SYSTEMROOT:\=/%
set wf=/%wf::=%
%meshr%/bin/sh.exe -c "export meshr=%meshr%; export PATH=/${meshr/:/}/bin:%wf%:%wf%/System32:%wf%/System32/Wbem:$PATH; %*"
rem >> %meshr%/log
rem pause