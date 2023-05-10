# Deploy Azure OpenAI using Terraform and Azure CloudShell

## Prerequisites

- Have an Azure Account.
- Have an Azure Subscription.
- Create a Service Principal with a secret : [Guide](https://learn.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal)
- Create or have access to Azure CloudShell available [Here](https://portal.azure.com/#cloudshell/)

# The Terrafrom Template will deploy:
- One Resource Group.
- Two Virtual Networks.
- One Public IP.
- One Virtual Network Gateway.
- One Azure OpenAI.

## The script ensure all the connections needed are in placed, such as:
- Network peering between the Hub and the Spoke Virtual Networks.
- Subnet service endpoint to Microsoft.CognitiveServices.
- Public IP association to the virtual network gateway for you to create a Site to Site VPN to on-premises.
- Restricted access to the Azure OpenAI solution by only the traffic coming from the Hub virtual network.
- Azure Tags for all the supported resoruces.

# Steps:

## 1 Review and copy [Terraform Template](https://github.com/DavidArayaSanabria/Deploy_Azure_OpenAI/blob/79a4f4c52487455b87ec9339694b227905ff3d11/Template.tf)

Please fill out the provider information with your Azure's tenant and subscription and service principal information.
Fill out all the Local variables of the file.

## 2 Go to [CloudShell](https://portal.azure.com/#cloudshell/)

Create a new folder for the project and run the command ```terraform init``` to ensure Terraform is properly running.
Create a new ```.tf``` file inside of the folder, it can be modified by using the command ```code``` in CloudShell for you to paste for modified [Terraform Template](https://github.com/DavidArayaSanabria/Deploy_Azure_OpenAI/blob/79a4f4c52487455b87ec9339694b227905ff3d11/Template.tf) and save the file.
Back on the project's folder, run the command ```terraform plan``` the output will show you what Terraform will deploy on your subscription.

![alt text](https://github.com/DavidArayaSanabria/Deploy_Azure_OpenAI/blob/9b7768fc9022da667430d598bd946b5bf83f85e8/Images/tfoutput.png)

Review the output to finally run ```terraform apply``` 

Terraform will deploy these resources in your resoruce group:
![alt text](https://github.com/DavidArayaSanabria/Deploy_Azure_OpenAI/blob/8e09025966a7603be65efdd24f261fcaf1844201/Images/resoruces.tf.png) 

## 3 Setup a Site to Site VPN to Azure using the deployed virtual network gateway.

You will need to create a local network gateway and a connection to establish connectivity.
[Guide](https://learn.microsoft.com/en-us/azure/vpn-gateway/tutorial-site-to-site-portal#LocalNetworkGateway)

For that you can also use Terraform or any other supported method.

[azurerm_local_network_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/local_network_gateway)

[gateway_connection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway_connection)

## Configure you OpenAI Service using the OpenAI Studio tool.









