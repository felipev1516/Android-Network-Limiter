@echo on
:: cmd /c start /min "" Powershell -ExecutionPolicy Bypass -WindowStyle Hidden -command "unblock-file network.ps1;.\network.ps1"
Powershell -ExecutionPolicy Bypass -WindowStyle Normal -command "unblock-file network.ps1;.\network.ps1"
pause
exit