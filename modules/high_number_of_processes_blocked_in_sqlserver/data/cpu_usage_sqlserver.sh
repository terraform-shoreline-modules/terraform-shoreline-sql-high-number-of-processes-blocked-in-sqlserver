powershell

# 1. Check the CPU usage of the SQLServer process.

Get-Process -Name ${SQLSERVER} | Select-Object -Property CPU