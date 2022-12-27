# LAB: Create and deploy an Azure Resource Manager (ARM) template

This lab introduces you to Azure Resource Manager (ARM) templates. It shows you how to create a starter template and deploy it to Azure. You'll learn about the structure of the template and the tools you'll need for working with templates.

## Create your first template

1. Open Visual Studio Code with the Azure Resource Manager (ARM) Tools extension installed.
2. Create a new file and name it **lab08.json**.
3. Start typing `arm` and pick `Resource Group Template` snippet.

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {},
    "functions": [],
    "variables": {},
    "resources": [],
    "outputs": {}
}
```

This template doesn't deploy any resources. It's just a starting, blank template.

4. Save the file.

## Sign in to Azure

To start working with Azure PowerShell/Azure CLI, sign in with your Azure credentials.

[PowerShell]

```azurepowershell
Connect-AzAccount
```

[Azure CLI]

```azurecli
az login
```

---

## Create resource group

When you deploy a template, you specify a resource group that will contain the resources.

[PowerShell]

```azurepowershell
New-AzResourceGroup -Name otp-rg -Location "westeurope"
```

[Azure CLI]

```azurecli
az group create --name otp-rg --location "westeurope"
```

---

## Deploy template

To deploy the template, use either Azure CLI or Azure PowerShell. Use the resource group you created. Give a name to the deployment so you can easily identify it in the deployment history. For convenience, also create a variable that stores the path to the template file.

[PowerShell]

```azurepowershell
$templateFile = "{provide-the-path-to-the-template-file}"

New-AzResourceGroupDeployment `
  -Name blanktemplate `
  -ResourceGroupName otp-rg `
  -TemplateFile $templateFile
```

[Azure CLI]

```azurecli
templateFile="{provide-the-path-to-the-template-file}"

az group deployment create \
  --name blanktemplate \
  --resource-group otp-rg \
  --template-file $templateFile
```

---

## Verify deployment

You can verify the deployment by exploring the resource group from the Azure portal.

---

## Add resource

To add a storage account definition to the existing template, start typing `arm-storage` inside the **resources** section and pick `Storage account` snippet. Compare that snippet with the following:

```json
        {
            "name": "{provide-unique-name}",
            "type": "Microsoft.Storage/storageAccounts",
            "apiVersion": "2021-04-01",
            "location": "westeurope",
            "kind": "StorageV2",
            "sku": {
                "name": "Standard_LRS",
                "tier": "Standard"
            }
        }

```

Sometimes, the snippet you'll add to your template might be using the old API version and doesn't support current resource properties. How to find the properties to use for each resource type? You can use the [Resource Manager template reference](https://docs.microsoft.com/azure/templates/) to find the resource types you want to deploy.

Use the above snippet and replace **{provide-unique-name}** with a unique storage account name. The storage account name must be unique across Azure. The name must have only lowercase letters or numbers. It can be no longer than 24 characters.

It's important to understand the connection between the API version and the available properties. You are using the API version at [storageAccounts 2021-04-01](https://docs.microsoft.com/en-us/azure/templates/microsoft.storage/2021-04-01/storageaccounts). Notice that you didn't add all of the properties to your template. Many of the properties are optional.

## Deploy template

You can deploy the template to create the storage account. Give your deployment a different name so you can easily find it in the history.

[PowerShell]

```azurepowershell
New-AzResourceGroupDeployment `
  -Name addstorage `
  -ResourceGroupName otp-rg `
  -TemplateFile $templateFile
```

[Azure CLI]

```azurecli
az group deployment create \
  --name addstorage \
  --resource-group otp-rg \
  --template-file $templateFile
```

---

You might encounter two possible deployment failures:

- Error: Code=AccountNameInvalid; Message={provide-unique-name} is not a valid storage account name. Storage account name must be between 3 and 24 characters in length and use numbers and lower-case letters only.

    In the template, replace **{provide-unique-name}** with a unique storage account name.

- Error: Code=StorageAccountAlreadyTaken; Message=The storage account named store1abc09092019 is already taken.

    In the template, try a different storage account name.

---

## Add parameters to your Resource Manager template

There's a problem with the current template. The storage account name is hard-coded.

## Make template reusable

To make a template reusable, let's add a parameter that you can use to pass in a storage account name. The following snippet shows what should change in your template. The **storageName** parameter is identified as a string. The max length is set to 24 characters to prevent any names that are too long.

```json
    "parameters": {
        "storageName": {
            "type": "string",
            "minLength": 3,
            "maxLength": 24
        }
    },
    "resources": [
        {


            "name": "[parameters('storageName')]",


        }
```

## Deploy template

Notice that you provide the storage account name as one of the values in the deployment command. For the storage account name, provide the SAME name you used earlier.

[PowerShell]

```azurepowershell
New-AzResourceGroupDeployment `
  -Name addnameparameter `
  -ResourceGroupName otp-rg `
  -TemplateFile $templateFile `
  -storageName "{your-unique-name}"
```

[Azure CLI]

```azurecli
az group deployment create \
  --name addnameparameter \
  --resource-group otp-rg \
  --template-file $templateFile \
  --parameters storageName={your-unique-name}
```

---

## Customize by environment

The previous template always deployed a Standard_LRS storage account. You might want the flexibility to deploy different SKUs depending on the environment. The following example shows the changes to add a parameter for SKU. Add it to the `parameters` block.

```json
"storageSKU": {
            "type": "string",
            "defaultValue": "Standard_LRS",
            "allowedValues": [
                "Standard_LRS",
                "Standard_GRS",
                "Standard_RAGRS",
                "Standard_ZRS",
                "Standard_GZRS",
                "Standard_RAGZRS"
            ]
        }
```

Don't forget to update the **sku** property:

```json
"sku": {
    "name": "[parameters('storageSKU')]",
    "tier": "Standard"
}
```

The **storageSKU** parameter has the default value. This value is used when a value isn't specified during the deployment. It also has a list of allowed values. These values match the values that are needed to create a storage account. You don't want users of your template to pass in SKUs that don't work.

## Redeploy template

You're ready to deploy again. Because the default SKU is set to **Standard_LRS**, you don't need to provide a value for that parameter.

[PowerShell]

```azurepowershell
New-AzResourceGroupDeployment `
  -Name addskuparameter `
  -ResourceGroupName otp-rg `
  -TemplateFile $templateFile `
  -storageName "{your-unique-name}"
```

[Azure CLI]

```azurecli
az group deployment create \
  --name addskuparameter \
  --resource-group otp-rg \
  --template-file $templateFile \
  --parameters storageName={your-unique-name}
```

---

To see the flexibility of your template, let's deploy again. This time set the SKU parameter to **Standard_GRS**. You can either pass in a new name to create a different storage account, or use the same name to update your existing storage account. Both options work.

[PowerShell]

```azurepowershell
New-AzResourceGroupDeployment `
  -Name changesku `
  -ResourceGroupName otp-rg `
  -TemplateFile $templateFile `
  -storageName "{your-unique-name}" `
  -storageSKU Standard_GRS
```

[Azure CLI]

```azurecli
az group deployment create \
  --name changesku \
  --resource-group otp-rg \
  --template-file $templateFile \
  --parameters storageSKU=Standard_GRS storageName={your-unique-name}
```

---

Finally, let's run one more test and see what happens when you pass in a SKU that isn't one of the allowed values. In this case, we test the scenario where a user of your template thinks **basic** is one of the SKUs.

[PowerShell]

```azurepowershell
New-AzResourceGroupDeployment `
  -Name testskuparameter `
  -ResourceGroupName otp-rg `
  -TemplateFile $templateFile `
  -storageName "{your-unique-name}" `
  -storageSKU basic
```

[Azure CLI]

```azurecli
az group deployment create \
  --name testskuparameter \
  --resource-group otp-rg \
  --template-file $templateFile \
  --parameters storageSKU=basic storageName={your-unique-name}
```

---

The command fails immediately with an error message that states which values are allowed. Resource Manager identifies the error before the deployment starts.

---

## Add template functions to your Resource Manager template

Your current template has the following JSON:

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "storageName": {
            "type": "string",
            "minLength": 3,
            "maxLength": 24
        },
        "storageSKU": {
            "type": "string",
            "defaultValue": "Standard_LRS",
            "allowedValues": [
                "Standard_LRS",
                "Standard_GRS",
                "Standard_RAGRS",
                "Standard_ZRS",
                "Standard_GZRS",
                "Standard_RAGZRS"
            ]
        }
    },
    "functions": [],
    "variables": {},
    "resources": [
        {
            "name": "[parameters('storageName')]",
            "type": "Microsoft.Storage/storageAccounts",
            "apiVersion": "2021-04-01",
            "location": "westeurope",
            "kind": "StorageV2",
            "sku": {
                "name": "[parameters('storageSKU')]",
                "tier": "Standard"
            }
        }
    ],
    "outputs": {}
}
```

The location of the storage account is hard-coded to **West Europe**. However, you may need to deploy the storage account to other regions, for example **East US**. You're again facing an issue of your template lacking flexibility. You could add a parameter for location, but it would be great if its default value made more sense than just a hard-coded value.

## Use function

Functions add flexibility to your template by dynamically getting values during deployment. You can use a function to get the location of the resource group you're using for deployment.

Let's add a parameter called **location**. The parameter default value calls the `resourceGroup` function. This function returns an object with information about the resource group being used for deployment. One of the properties on the object is the `location` property.

```json
"location": {
            "type": "string",
            "defaultValue": "[resourceGroup().location]"
        }
```

Don't forget to update the **location** property:

```json
    "location": "[parameters('location')]",
```

## Deploy template

Use the default value for location, so you don't need to provide that parameter value. You must provide a new name for the storage account because you're creating a storage account in a different location.

[PowerShell]

```azurepowershell
New-AzResourceGroupDeployment `
  -Name addlocationparameter `
  -ResourceGroupName otp-rg `
  -TemplateFile $templateFile `
  -storageName "{new-unique-name}"
```

[Azure CLI]

```azurecli
az group deployment create \
  --name addlocationparameter \
  --resource-group otp-rg \
  --template-file $templateFile \
  --parameters storageName={new-unique-name}
```

---

## Add variables to your Resource Manager template

Variables simplify your templates by enabling you to write an expression once and reuse it throughout the template.

The parameter for the storage account name is hard-to-use because you have to provide a unique name. You solve this problem by adding a variable that constructs a unique name for the storage account.

## Use variable

The following JSON introduces the changes to add a variable to your template that creates a unique storage account name.
We are adding a new parameter, **storagePrefix**, a variable named **uniqueStorageName**, and use that variable to specify a name for a storage account.

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "storagePrefix": {
            "type": "string",
            "minLength": 3,
            "maxLength": 11
        },
        "storageSKU": {
            "type": "string",
            "defaultValue": "Standard_LRS",
            "allowedValues": [
                "Standard_LRS",
                "Standard_GRS",
                "Standard_RAGRS",
                "Standard_ZRS",
                "Standard_GZRS",
                "Standard_RAGZRS"
            ]
        },
        "location": {
            "type": "string",
            "defaultValue": "[resourceGroup().location]"
        }
    },
    "variables": {
        "uniqueStorageName": "[concat(parameters('storagePrefix'), uniqueString(resourceGroup().id))]"
    },
    "resources": [
        {
            "name": "[variables('uniqueStorageName')]",
            "type": "Microsoft.Storage/storageAccounts",
            "apiVersion": "2021-04-01",
            "location": "[parameters('location')]",
            "kind": "StorageV2",
            "sku": {
                "name": "[parameters('storageSKU')]",
                "tier": "Standard"
            }
        }
    ]
}
```

**uniqueStorageName** variable uses four functions to construct a string value.

`parameters` and `resourceGroup` functions are familiar already. The only difference is that now we use the **id** property instead of the **location** property. The **id** property returns the full identifier of the resource group, including the subscription ID and resource group name.

The `uniqueString` function creates a 13 character hash value. The returned value is determined by the parameters you pass in. We use the resource group ID as the input for the hash value.

The `concat` function takes values and combines them. For this variable, it takes the string from the parameter and the string from the uniqueString function, and combines them into one string.

The **storagePrefix** parameter enables you to pass in a prefix that helps you identify storage accounts. You can create your own naming convention that makes it easier to identify storage accounts after deployment from a long list of resources.

Finally, notice that the storage name is now set to the variable instead of a parameter.

## Deploy template

Let's deploy the template. Deploying this template is easier than the previous templates because you provide just the prefix for the storage name.

[PowerShell]

```azurepowershell
New-AzResourceGroupDeployment `
  -Name addnamevariable `
  -ResourceGroupName otp-rg `
  -TemplateFile $templateFile `
  -storagePrefix "store1" `
  -storageSKU Standard_LRS
```

[Azure CLI]

```azurecli
az group deployment create \
  --name addnamevariable \
  --resource-group otp-rg \
  --template-file $templateFile \
  --parameters storagePrefix=store1 storageSKU=Standard_LRS
```

---

## Add outputs to your Resource Manager template

The current template deploys a storage account, but it doesn't return any information about the storage account. You might need to capture properties from a new resource so they're available later for reference.

## Add outputs

You can use outputs to return values from the template. For example, it might be helpful to get the endpoints for your new storage account. Add the following code snippet to the `outputs` block.

```json
"storageEndpoint": {
            "type": "object",
            "value": "[reference(variables('uniqueStorageName')).primaryEndpoints]"
        }
```

The type of returned value is set to **object**, which means it returns a JSON object.

It uses the `reference` function to get the runtime state of the storage account. To get the runtime state of a resource, you pass in the name or ID of a resource. In this case, you use the same variable you used to create the name of the storage account.

Finally, it returns the **primaryEndpoints** property from the storage account.

## Deploy template

You're ready to deploy the template and look at the returned value.

[PowerShell]

```azurepowershell
New-AzResourceGroupDeployment `
  -Name addoutputs `
  -ResourceGroupName otp-rg `
  -TemplateFile $templateFile `
  -storagePrefix "store1" `
  -storageSKU Standard_LRS
```

[Azure CLI]

```azurecli
az group deployment create \
  --name addoutputs \
  --resource-group otp-rg \
  --template-file $templateFile \
  --parameters storagePrefix=store1 storageSKU=Standard_LRS
```

---

In the output for the deployment command, you'll see an object similar to:

```json
{
    "dfs": "https://store1fkrtgswos.dfs.core.windows.net/",
    "web": "https://store1fkrtgswos.z19.web.core.windows.net/",
    "blob": "https://store1fkrtgswos.blob.core.windows.net/",
    "queue": "https://store1fkrtgswos.queue.core.windows.net/",
    "table": "https://store1fkrtgswos.table.core.windows.net/",
    "file": "https://store1fkrtgswos.file.core.windows.net/"
}
```

## Review your work

Let's take a moment to review what you have done. You created a template with parameters that are easy to provide. The template is reusable in different environments because it allows for customization and dynamically creates needed values. It also returns information about the storage account that you could use in your script.

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "storagePrefix": {
            "type": "string",
            "minLength": 3,
            "maxLength": 11
        },
        "storageSKU": {
            "type": "string",
            "defaultValue": "Standard_LRS",
            "allowedValues": [
                "Standard_LRS",
                "Standard_GRS",
                "Standard_RAGRS",
                "Standard_ZRS",
                "Standard_GZRS",
                "Standard_RAGZRS"
            ]
        },
        "location": {
            "type": "string",
            "defaultValue": "[resourceGroup().location]"
        }
    },
    "variables": {
        "uniqueStorageName": "[concat(parameters('storagePrefix'), uniqueString(resourceGroup().id))]"
    },
    "resources": [
        {
            "name": "[variables('uniqueStorageName')]",
            "type": "Microsoft.Storage/storageAccounts",
            "apiVersion": "2021-04-01",
            "location": "[parameters('location')]",
            "kind": "StorageV2",
            "sku": {
                "name": "[parameters('storageSKU')]",
                "tier": "Standard"
            }
        }
    ],
    "outputs": {
        "storageEndpoint": {
            "type": "object",
            "value": "[reference(variables('uniqueStorageName')).primaryEndpoints]"
        }
    }
}
```

## Clean up resources

1. From the Azure portal, select **Resource group** from the left menu.
2. Enter the resource group name in the **Filter by name** field.
3. Select the resource group name.
4. Select **Delete resource group** from the top menu.
