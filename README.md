# Infrastructure as Code Lab

## Origin Story
This lab was forked from the Configuration Management lab which was written by the Azure-CAT team.
Their content ceised being maintained on the 1st January 2017. 
ref: https://github.com/AzureCAT-GSI/DevOps-Deep-Dive/tree/master/Labs/Configuration%20Management

## Abstract

During this lab, you will learn how to define infrastructure-as-code (IaC). You will learn how to use Azure Resource Manager (ARM) templates to describe an infrastructure of resources such as a virtual network, virtual machine, and more. Then, you will learn how to use PowerShell Desired Stated Configuration (DSC) to configure the internals of a virtual machine.


## Learning Objectives

After completing the exercises in this lab, you will be able to:

-   Create an ARM template to provision a virtual machine and additional required resources.

-   Use PowerShell to deploy an ARM template to Azure.

-   Use PowerShell Desired State Configuration (DSC) to apply internal configuration for a virtual machine.


**Estimated time to complete this lab: *120* minutes**

# Exercise : Create an ARM template to provision a virtual machine

## Scenario

In this exercise, we will introduce you to the authoring tools used to create ARM templates using Visual Studio 2015. You will create a new ARM template from scratch to provision an Azure virtual machine. For this exercise, you will use:

-   Visual Studio 2015 with Update 3 or Visual Studio 2017

-   Microsoft Azure SDK for .NET > v2.9.1

After completing this exercise, you will understand:

-   The overall structure of an ARM template.

-   How resources are added and configured in an ARM template.

-   How parameters are passed into an ARM template.

## Create a new Azure Resource Group Project

1. Open Visual Studio.

1. Select **File &gt; New &gt; Project**.

    - Select the **Azure Resource Group** project.

    - Set the **Name** of the project to *IaC-Lab*.

    - Click **OK**.

        ![image](./media/image2.png)

1. In the **Azure Template** window, select the **Blank Template** and click **OK**.

    ![image](./media/image3.png)

1. Select **View &gt; Solution Explorer**.

1. In **Solution Explorer**, expand the **Templates** folder and double-click **azuredeploy.json**. Opening this file in the Visual Studio editor should result in the **JSON Outline** window displaying as shown. If it is not visible, you can open it by selecting **View &gt; Other Windows &gt; JSON Outline**.

    ![image](./media/image4.png)

## Add Azure resources to the deployment template

1. In the **JSON Outline** window, right-click **Resources** and select **Add New Resource**.

1. In the **Add Resource** window, select **Storage Account**.

    - Set the resource **Name** to *stg*. Note: Be sure to use all lowercase letters. Azure storage account names must be al lowercase and can only contain alpha-numeric characters.

    - Click **Add**.

    ![image](./media/image5.png)

1. Deploy storage account from Visual Studio to Azure.

    - Log into the Azure Portal and check the resource has been created

    - In the Azure Portal, add a container to the storage and upload *any* file

1. In the JSON template, add a **Tag** key/value pair to the storage account

    - Re-deploy to Azure

    - Check in the Azure portal that the tag has been applied to the existing resource

1. In the JSON template, add a **Parameter** to represent the project name.

    - Add another **Tag** key/value pair to the storage account to reference the project name

    - Change the storage account name to be the Project Prefix and then the existing storage account

    - Re-deploy to Azure

    - Inspect the resources in the **Resource Group**, see that another storage account has been created.  The name of the storage account is unsed to uniquely reference it.

1. In the **JSON Outline** window, right-click **Resources** and select **Add New Resource**.

1. In the **Add Resource** window, select **Virtual Network**.

    - Set the resource **Name** to *vnet*.

    - Click **Add**.

    - Proceed to re-deploy this to Azure

    ![image](./media/image6.png)

1. In the **JSON Outline** window, right-click **Resources** and select **Add New Resource**.

1. In the **Add Resource** window, select **Windows Virtual Machine**.

    - Set the resource **Name** to *vm*.

    - Set the **Storage account** field to *stg*, which is the storage account you created previously.

    - Set the **Virtual network/subnet** field to *\[variables(‘vnetSubnet1Name/\](vnet)*, which is the virtual network you created previously. By default, it creates two subnets but you can add, remove, or rename the subnets in the template. For this lab, you will just use the first default subnet.

    - Click **Add**.

    ![image](./media/image7.png)

1. In the **JSON Outline** window, right-click on **Resources** and select **Add New Resource**.

1. In the **Add Resource** window, select **Public IP Address**.

    - Set the resource **Name** to *vmpip*.

    - Set the **Network interface** field to *vmNic*. The Network Interface Card (Nic) resource was added when you added the virtual machine resource.

    - Click **Add**.

    ![image](./media/image8.png)

1. In the **JSON Outline** window, expand the **Parameters** node to show all the parameters.

    - Right-click *vmpipDnsName* and select **Delete**.

1. In the editor window for azuredeploy.json, add a new variable called *vmpipDnsName* as shown.

    ```json
    "variables": {

        "stgName": "\[concat('stg', uniqueString(resourceGroup().id))\]",

        "vnetPrefix": "10.0.0.0/16",

        "vnetSubnet1Name": "Subnet-1",

        "vnetSubnet1Prefix": "10.0.0.0/24",

        "vnetSubnet2Name": "Subnet-2",

        "vnetSubnet2Prefix": "10.0.1.0/24",

        "vmImagePublisher": "MicrosoftWindowsServer",

        "vmImageOffer": "WindowsServer",

        "vmOSDiskName": "vmOSDisk",

        "vmVmSize": "Standard\_D1",

        "vmVnetID": "\[resourceId('Microsoft.Network/virtualNetworks', 'vnet')\]",

        "vmSubnetRef": "\[concat(variables('vmVnetID'), '/subnets/', variables('vnetSubnet1Name'))\]",

        "vmStorageAccountContainerName": "vhds",

        "vmNicName": "\[concat(parameters('vmName'), 'NetworkInterface')\]",

        "vmpipName": "vmpip",

        "vmpipDnsName": "\[concat(parameters('vmName'), uniqueString(resourceGroup().id))\]"
    ```

    In last few steps, we refactor the parameter called *vmpipDnsName* into a variable that will automatically generate a unique DNS name for the Public IP Address. If we did not do it, then the end-user deploying the template could potentially experience a DNS name conflict if the value specified is not unique. By refactoring to a variable and using the uniqueString function, we are able to provide a better end-user experience during deployment.

1. In the **JSON Outline** window, click the *vmpip* resource in the **resources** node.

    ![image](./media/image9.png)

    The **JSON Outline** window is also a useful way to navigate through the JSON text file that describes the environment.

1. Change the **dnsSettings.domainNameLabel** property for the **Public IP Address** to reference the **vmpipDnsName** variable.

    ```json
    {

        "name": "\[variables('vmpipName')\]",

        "type": "Microsoft.Network/publicIPAddresses",

        "location": "\[resourceGroup().location\]",

        "apiVersion": "2015-06-15",

        "dependsOn": \[ \],

        "tags": {

            "displayName": "vmpip"

        },

        "properties": {

            "publicIPAllocationMethod": "Dynamic",

            "dnsSettings": {

                "domainNameLabel": "\[variables('vmpipDnsName')\]"

            }

        }

    }
    ```

1. Press **Ctrl-S** to save the changes.

1. In the **JSON Outline** window, right-click **Resources** and select **Add New Resource**.

1. In the **Add Resource** window, select **PowerShell DSC Extension**.

    - Set the resource **Name** to *dsc*.

    - Set the **Virtual machine** field to *vm*, which is the virtual machine resource you added previously to the template.

    - Click **Add**.

    ![image](./media/image10.png)

1. In **Solution Explorer**, expand the **DSC** folder and double-click the **dsc.ps1** file.

    - Replace the contents of **dsc.ps1** with the following code 
    https://github.com/Gordonby/DevOps-Deep-Dive/blob/master/scripts/dsc.ps1.

   

1. Press **Ctrl-S** to save the changes.

1. In **Solution Explorer**, double-click **azuredeploy.parameters.json**.

    - Replace the parameters section with the highlighted code.

    ```json
    {

        "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json\#",

        "contentVersion": "1.0.0.0",

        "parameters": {

            "vmName": {

                "value": "iisvm"

            },

            "vmAdminUserName": {

                "value": "adminuser"

            },

            "vmAdminPassword": {

                "value": "TechReady23!"

            }

        }

    }
    ```

1. Press **Ctrl-S** to save the changes.

    A best practice is to store credentials in Azure Key Vault and have Azure Resource Manager retrieve the credentials from the vault to provision the administrator credentials in the virtual machine. Azure Key Vault is beyond the scope of this lab so we are storing the credentials in the parameters file for simplicity.

You now have a complete ARM template that provisions an IaaS environment with the following resources:

-   A storage account to store the virtual machine’s hard disk (.vhd).

-   A virtual network with two subnets, a virtual machine requires a virtual network.

-   A virtual network interface card (NIC). It binds the virtual machine to the virtual network.

-   A public IP address resource. It is necessary if you want the virtual machine to be publicly accessible.

-   A PowerShell DSC extension to configure the internals of the virtual machine. The DSC configuration script adds the following configuration:

    -   Configures the virtual machine to be an IIS Web Server.

    -   Adds support for ASP.NET 4.5.

    -   Downloads and installs the Web Deploy Service package.

    -   Starts the Web Deploy Service.

    -   Downloads a sample Web Deploy Package from GitHub.

    -   Installs the Web Deploy Package.

# Exercise : Deploy the ARM Template

## Scenario

In this exercise, you will deploy the ARM template created in the previous exercise. There are several ways to deploy the ARM template including:

-   Using Azure PowerShell—AzureRm cmdlets.

-   Using Azure Command-Line Interface (CLI) from a Mac, Linux, or Windows client.

-   Deploying directly from Visual Studio.

-   Using the **Template Deployment** feature in the Azure portal.

-   Deploying as part of Continuous Deployment Strategy (see TR22 session CT302 ).

For this exercise, you will first deploy from Visual Studio since you used Visual Studio to create the template. Then, you will deploy the same template using PowerShell. You will be using:

-   Visual Studio 2015 with Update 3

-   Microsoft Azure SDK for .NET v2.9.1

-   Azure PowerShell Cmdlets v1.6.0

After completing this exercise, you will understand:

-   How to deploy an ARM template from Visual Studio.

-   How to deploy an ARM template using PowerShell.

## Deploy from Visual Studio

1. Select **Project &gt; Deploy &gt; New Deployment**.

1. In the **Deploy to Resource Group** window

    - Set the **Subscription** field to your Azure Subscription.

    - Set the **Resource Group** field to *&lt;Create New&gt;*.

    - In the **Create Resource Group** dialog, select a **Resource group location** closest to you. It is where the resource group will be created and eventually where the resources will be deployed.

    - Click **Create**.

        ![image](./media/image11.png)

    - Click **Edit Parameters**.

    - In the Edit Parameters dialog:

        - Set the **vmName** field to *iisvm*. Ensure it is lowercase.

        - Set the **vmAdminUserName** field to *adminuser*.

        - Set the **vmAdminPassword** field to *TechReady23!.*

        - Select **Save passwords as plain text in the parameters file**.

        - Click **Save**.

        ![image](./media/image12.png)

Note: It is a best practice to save passwords in Azure Key Vault instead of in source code. However, Azure Key Vault is beyond the scope of this lab so we are storing the password in the azuredeploy.parameters.json file.

The Visual Studio tools integrate with your Azure Key Vault (assuming you have already created a Key Vault) and enable you to store your passwords and secrets in the vault. To access these features of the Visual Studio tools, click the **Key Vault** icon as shown.

1. Set the **Artifact storage account** field to *&lt;Automatically create a storage account&gt;* if it is not already.

1. Click **Deploy**.

    ![image](./media/image13.png)

    When you click **Deploy**, Visual Studio invokes the *Deploy-AzureResourceGroup.ps1* PowerShell script that is part of your Azure Resource Group project. You can see evidence of it in the **Output** window as shown. Note: If the **Output** window is not visible, then you can open it by selecting **View &gt; Output** from the main menu.

    ![image](./media/image14.png)

    Explore the output in the **Output** window to understand what the deployment script is doing and review the Deploy-AzureResourceGroup.ps1 script in the project. Some things that are worthy of pointing out include:

    -   The script generates a unique name for a storage account that is used solely to upload the DSC artifacts to blob storage. After the virtual machine is provisioned, the DSC.zip file is copied into the virtual machine using a SAS token and the DSC process internal to the virtual machine is started. The storage account created for this purpose is created in a new resource group call *ARM\_Deploy\_Staging*. If you open the portal, you will see this resource group and the auto-generated storage account. If you look at the blob container in the storage account, you will see the DSC.zip fle.

    -   The script automatically generates the DSC.zip file. If you add additional DSC modules such as xNetworking, xActiveDirectory, xSQServer, etc. to this folder, the script will include them in the DSC.zip file that is copied to the virtual machine.

    -   The script automatically generates a SAS token (and URL) that is used by the virtual machine after it is provisioned to copy the DSC.zip file locally and start the DSC process.

    -   The bulk of the script is only applicable if there are artifacts that need to be uploaded. For example, in this case we need the DSC configuration (an artifact) copied to the virtual machine to configure it the way we want. If we did not have any artifacts, then the script essentially calls **New-AzureRmResourceGroup** to create the resource group and then **New-AzureRmResourceGroupDeployment** to deploy the resources into the resource group.

A successful deployment will take about 15 minutes to finish. You will see evidence of it in the **Output** window as shown.

![image](./media/image15.png)

If your deployment is still running, you may continue to the next section. It is not necessary to wait. Leave Visual Studio open so you can come back to it later.
