# Params
$subscriptionId = "5bf4e2b7-a38f-4aea-b649-6327151af3a9"

$rgName = "jegebhTest"
$vmName = "jegebhWinVm"
$location = "eastus"

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

# Create Resource Group
Try { 
    $rgInfo = Get-AzureRmResourceGroup -name $rgName -ErrorAction Stop
}
Catch {
    Write-Host ("Creating Resource Group: {0}" -f $rgName) -ForegroundColor White -BackgroundColor Green
    Try {
        $rgInfo = New-AzureRmResourceGroup -name $rgName -location $location -ErrorAction stop
    }
    Catch {
        Write-Host ("Failed to create Resoure Group {0}." -f $rgName) -ForegroundColor White -BackgroundColor Red
        return
    }
}

Write-Host ("Resource Group {0} in the {1} region is ready for use." -f $rgInfo.ResourceGroupName, $rgInfo.location) -ForegroundColor White -BackgroundColor Green

# Create VM
$cred = Get-Credential

Try {
    $vmInfo = New-AzureRmVm `
    -ResourceGroupName $rgName `
    -Name $vmName `
    -Location $location `
    -VirtualNetworkName "$($vmName)Vnet" `
    -SubnetName "$($vmName)Subnet" `
    -SecurityGroupName "$($vmName)NetworkSecurityGroup" `
    -PublicIpAddressName "$($vmName)PublicIpAddress" `
    -Credential $cred `
    -ErrorAction Stop
}
Catch {
    Write-Host "Unable to create VM. Exiting..." -ForegroundColor white -BackgroundColor Red
    return
}

Write-Host ("{0} created succesfully" -f $vminfo.Name) -ForegroundColor White -BackgroundColor Green