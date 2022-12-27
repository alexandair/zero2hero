# LAB: Update management and configuration

## Update management

Update Management service is included with Azure virtual machines and Azure Arc machines.
You can quickly assess the status of available updates and manage the process of installing required updates for your servers.
You only pay for logs stored in Log Analytics.
This service requires a Log Analytics workspace and an Automation account.
You can use your existing workspace and account or let Azure configure the nearest workspace and account for use.


1. Click **Home** and then **Virtual machines** under **Azure services**
2. Find the _windowsmgmt_ virtual machine and open its VM blade
3. In the sidebar, under **Operations** click the **Updates** option
4. Click **Go to Updates using automation** button
5. On the **Update Management** page, specify _West Europe_ as a location and allow Azure to create the default Log Analytics workspace and Automation account. Click **Enable** button.

NOTE: This process doesn't create **Run as account** for the default automation account. 

The **Update Management** solution is being enabled on this virtual machine.
This can take from a few minutes up to 15 minutes.

1. In the **Search** bar type _automation_ and pick **Automation accounts**.
2. Select the one create for you named **`Automate-<SubscriptionID>-WEU`** and open **Update management**.
3. Onboarded VM will start sending data about installed updates in the next 15 minutes.

Let's move to the VM configuration.

## Configure an Azure VM with Azure Automation State Configuration

In this lab, we will install Windows Admin Center on the _windowsmgmt_ VM using Azure Automation State Configuration service.
Download WindowsAdminCenter.ps1 configuration file from the GitHub repo.

1. In your Automation account, click **State configuration (DSC)** under **Configuration Management**.
2. Open **Configurations** tab, and then click **+Add**.
3. Import _WindowsAdminCenter.ps1_ configuration file
4. On the **Configurations** tab, click the **WindowsAdminCenter** configuration
5. On the **WindowsAdminCenter** page, click **Compile**.
6. When a compilation job is completed, a node configuration is created, and you can close that view on 'X'.
7. Click **Nodes** tab, and then **+Add**.
8. On the **Virtual Machines** page, find the _windowsmgmt_ VM, and select it.
9. On the next page, click **Connect** and on the **Registration** page specify _WindowsAdminCenter.localhost_ as **Node configuration name**. Leave the remaining defaults and click **OK**.
10. _Connecting..._ process will run for a few minutes.

After 15 minutes, _windowsmgmt_ VM will start sending feedback data to **Azure Automation State Configuration** service to let it know if it's compliant or not.