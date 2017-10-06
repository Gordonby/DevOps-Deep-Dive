Configuration Main

{
    Param ( [string] $nodeName )
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Node $nodeName
    {
        WindowsFeature WebServerRole
        {
            Name = "Web-Server"
            Ensure = "Present"
        }
        WindowsFeature WebManagementService
        {
            Name = "Web-Mgmt-Service"
            Ensure = "Present"
        }   
        WindowsFeature ASPNet45
        {
            Name = "Web-Asp-Net45"
            Ensure = "Present"
        }
        Script DownloadWebDeploy
        {
            TestScript = {
                Test-Path "C:\WindowsAzure\WebDeploy_amd64_en-US.msi"
            }
            SetScript ={
                $source = "https://download.microsoft.com/download/0/1/D/01DC28EA-638C-4A22-A57B-4CEF97755C6C/WebDeploy_amd64_en-US.msi"
                $dest = "C:\WindowsAzure\WebDeploy_amd64_en-US.msi"
                Invoke-WebRequest $source -OutFile $dest
            }
            GetScript = {@{Result = "DownloadWebDeploy"}}
            DependsOn = "[WindowsFeature]WebServerRole"
        }
        Package InstallWebDeploy
        {
            Ensure = "Present"
            Path = "C:\WindowsAzure\WebDeploy_amd64_en-US.msi"
            Name = "Microsoft Web Deploy 3.6"
            ProductId = "{ED4CC1E5-043E-4157-8452-B5E533FE2BA1}"
            Arguments = "ADDLOCAL=ALL"
            DependsOn = "[Script]DownloadWebDeploy"
        }
        Service StartWebDeploy
        {
            Name = "WMSVC"
            StartupType = "Automatic"
            State = "Running"
            DependsOn = "[Package]InstallWebDeploy"
        }
        Script DownloadWebDeployPackage
        {
            TestScript = {
                Test-Path -Path "C:\TR23WebApp.zip"
            }
            SetScript = {
                $source = "https://github.com/GSIAzureCOE/Networking/raw/master/Demo-TrafficManager/TM-Demo-Solution/TM-Demo/App/TM-Demo-App.zip"
                $dest = "C:\TR23WebApp.zip"
                Invoke-WebRequest $source -OutFile $dest
            }
            GetScript = {@{Result = "DownloadWebDeployPackage"}}
            DependsOn = "[Service]StartWebDeploy"
        }
        Script InstallWebDeployPackage
        {
            TestScript = {
            Test-Path -Path "HKLM:\SOFTWARE\TR23\WebDeployPkgInstalled"
        }
        SetScript = {
            $appName = "IIS Web Application Name"
            $siteName = "Default Web Site"
            $msDeployPath = "C:\Program Files\IIS\Microsoft Web Deploy V3\msdeploy.exe"
            & $msDeployPath "-verb:sync", "-source:package=C:\TR23WebApp.zip", "-dest:auto,ComputerName=""localhost""", "-setParam:name=""$appName"",value=""$siteName"""
            if ($LASTEXITCODE -eq 0)
            {
                               
               New-Item -Path "HKLM:\SOFTWARE\TR23\WebDeployPkgInstalled" -Force
            }
        }
        GetScript = {@{Result = "InstallWebDeployPackage"}}

        DependsOn = "[Script]DownloadWebDeployPackage"

        }
    }
}