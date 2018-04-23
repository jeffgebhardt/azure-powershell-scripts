# Variables for common values
$resourceGroup = "jegebhDevRG"
$location = "eastus"
$vmName = "jegebhLinuxVm"
$prefix = "jegebh"
$subscriptionId = ""

# Login
Try {
    $subInfo = Select-AzureRmSubscription -SubscriptionId $subscriptionId -ErrorAction stop
}
Catch {
    Write-Host "Not logged in to Azure, please login at prompt"
    Connect-AzureRmAccount
    Try {
        $subInfo = Select-AzureRmSubscription -SubscriptionId $subscriptionId -ErrorAction stop
    }
    Catch {
        Write-Host "No access to subscription, please check your subscription and try again. Exiting..." -ForegroundColor white -BackgroundColor Red
        Return
    }
}

Write-Host ("User ID, Subscription ID: {0}" -f $subInfo.Name) -ForegroundColor white -BackgroundColor Green

# Definer user name and blank password
$securePassword = ConvertTo-SecureString '' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("jegebh", $securePassword)

# Create a subnet configuration
$subnetConfig = New-AzureRmVirtualNetworkSubnetConfig -Name "$($prefix)Subnet" -AddressPrefix 192.168.1.0/24

# Create a virtual network
$vnet = New-AzureRmVirtualNetwork -ResourceGroupName $resourceGroup -Location $location `
  -Name "$($prefix)vNET" -AddressPrefix 192.168.0.0/16 -Subnet $subnetConfig

# Create a public IP address and specify a DNS name
$pip = New-AzureRmPublicIpAddress -ResourceGroupName $resourceGroup -Location $location `
  -Name "$($prefix)publicdns$(Get-Random)" -AllocationMethod Static -IdleTimeoutInMinutes 4

# Create an inbound network security group rule for port 22
$nsgRuleSSH = New-AzureRmNetworkSecurityRuleConfig -Name "$($prefix)NetworkSecurityGroupRuleSSH"  -Protocol Tcp `
  -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
  -DestinationPortRange 22 -Access Allow

# Create a network security group
$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $resourceGroup -Location $location `
  -Name "$($prefix)NetworkSecurityGroup" -SecurityRules $nsgRuleSSH

# Create a virtual network card and associate with public IP address and NSG
$nic = New-AzureRmNetworkInterface -Name "$($prefix)Nic" -ResourceGroupName $resourceGroup -Location $location `
  -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

# Create a virtual machine configuration
$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize Standard_DS1_V2 | `
Set-AzureRmVMOperatingSystem -Linux -ComputerName $vmName -Credential $cred -DisablePasswordAuthentication | `
Set-AzureRmVMSourceImage -PublisherName RedHat -Offer RHEL -Skus 7.3 -Version latest | `
Add-AzureRmVMNetworkInterface -Id $nic.Id

# Configure SSH Keys
$sshPublicKey = ""
Add-AzureRmVMSshPublicKey -VM $vmconfig -KeyData $sshPublicKey -Path "/home/jegebh/.ssh/authorized_keys"

# Create a virtual machine
New-AzureRmVM -ResourceGroupName $resourceGroup -Location $location -VM $vmConfig
