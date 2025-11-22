## Getting your laptop ready
Install the following windows software
- VS Code
- One Drive
- Google Drive
- Office 365
- Nord VPN
- WSL2 + Ubuntu
- Configure WSL2 to have 4 core and 16 GB

Install the following WSL softwares:
- git
- configure git access using SSH
- configure WSL to work as git agent server
- nodejs
- python
- docker
- MiniK8s
- Enable Kubeflow on MiniK8s
- Install MLflow and ZenML

  --------------------------------
  wsl.bat
  -----------------------------------------
  @echo off
:: -------------------------------
:: Dynamic Minikube startup script
:: -------------------------------

:: Your WSL distro name
set DISTRO=Ubuntu-22.04

:: Total system CPUs
for /f "tokens=2 delims=:" %%a in ('wmic cpu get NumberOfLogicalProcessors /value') do set CPUS=%%a

:: Leave 2 CPUs for Windows host
set /a MINIKUBE_CPUS=%CPUS%-2
if %MINIKUBE_CPUS% lss 1 set MINIKUBE_CPUS=1

:: Total physical RAM in MB
for /f "tokens=2 delims==" %%a in ('wmic computersystem get TotalPhysicalMemory /value') do set RAM_BYTES=%%a
set /a RAM_MB=%RAM_BYTES%/1024/1024

:: Allocate 75% of RAM to Minikube
set /a MINIKUBE_MEM=%RAM_MB%*75/100
:: Convert to MB rounded to nearest 1024 MB (optional)
set /a MINIKUBE_MEM=(%MINIKUBE_MEM%/1024)*1024

:: Start Minikube in background via WSL
wsl -d %DISTRO% --exec /bin/bash -c "minikube start --driver=docker --cpus=%MINIKUBE_CPUS% --memory=%MINIKUBE_MEM% >/dev/null 2>&1 &"

