# LAB: How to set up your environment

## Log in to your lab VM

Perform the following steps on your laptop: 
1. Open https://labs.azure.com in your browser.
2. Sign in using the credentials provided by an instructor
3. Click "Skip for now (14 days until this is required)" (sometimes you need to click more than once)
4. If the **ZeroToHeroLabVM** tile doesn't show "Running", click the toggle button showing "Stopped" to start the VM. Wait for a couple of minutes. Refresh the page, if the status doesn't change to "Running"
5. If the **ZeroToHeroLabVM** tile shows "Running", click the icon next to the "Running" button to download an RDP file you will use to connect to your lab VM
6. Log in to your lab VM as "labuser" using the password provided by the instructor

## Install the required applications

Perform the following steps on your lab VM.
1. Open the Power User menu (Win+X) and select **Terminal**.
Windows PowerShell session will start.
2. Install the required applications using Windows Package Manager (winget).

```powershell
winget install microsoft.powershell # UAC is required
winget install microsoft.azurecli  # UAC is required
winget install microsoft.bicep
winget install git.git
winget install Microsoft.VisualStudioCode
winget install OpenJS.NodeJS.LTS # UAC is required
winget install Microsoft.DotNet.SDK.7 # UAC is required
```

3. Close Windows Terminal.
4. Open the Power User menu (Win+X) and select **Terminal** again.
5. Change default profile to be PowerShell instead of Windows PowerShell.
(Settings > Startup > Default profile > PowerShell)
6. Click **Save** and close Windows Terminal.
7. Open Windows Terminal again.
It should open PowerShell tab now.

## Install Azure PowerShell from PowerShell Gallery

### System requirements

Azure PowerShell works with PowerShell 5.1 or higher on Windows, or PowerShell 7 or higher on any platform.
If you are using PowerShell 5 on Windows, you also need .NET Framework 4.7.2 installed.

```powershell
# Install the Az module from the PowerShell Gallery
# Confirm the installation with "Y"
Install-Module -Name Az -Scope CurrentUser -AllowClobber -Verbose
```

While waiting for Azure PowerShell installation to finish, proceed with the installation of Visual Studio Code extensions.

## Install Visual Studio Code extensions

Open another PowerShell tab.
Run the following commands.

```powershell
# Installation of the Visual Studio Code extensions from the command line
code --install-extension ms-vscode.powershell # PowerShell
code --install-extension ms-vscode.azurecli # Azure CLI Tools
code --install-extension ms-vscode.azure-account # Azure Account
code --install-extension msazurermtools.azurerm-vscode-tools # Azure Resource Manager (ARM) Tools
code --install-extension ms-azuretools.vscode-bicep # Bicep
code --install-extension ms-azuretools.vscode-azurestorage # Azure Storage
code --install-extension ms-dotnettools.dotnet-interactive-vscode # Polyglot noteooks
```

More details about the extensions:

[PowerShell](https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell)

[Azure CLI Tools](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azurecli)

[Azure Account](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azure-account) (On Windows, it requires [Node.js 6 or later](https://nodejs.org/en/) for Cloud Shell)

[Azure Resource Manager (ARM) Tools](https://marketplace.visualstudio.com/items?itemName=msazurermtools.azurerm-vscode-tools)

[Bicep](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep)

[Azure Storage](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azurestorage)

[Polyglot Notebooks](https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.dotnet-interactive-vscode)

## Dowload the lab files from the zero2hero GitHub repo

```powershell
cd\
git clone https://github.com/alexandair/zero2hero
cd zero2hero
# open Visual Studio Code; click 'Yes, I trust the authors'
code .
```

## SSH Client (instructions for Windows 10; already installed on Windows 11)

Go to the Settings > Apps > Apps & features > Optional features > Add a feature > OpenSSH Client > Install.

```powershell
# You need to start PowerShell with the "Run as Admin" option
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'
 
# Install the OpenSSH Client
Add-WindowsCapability -Name OpenSSH.Client~~~~0.0.1.0 -Online 
```

After installing the OpenSSH Client, you can now use the SSH client from PowerShell or the Command Prompt.




