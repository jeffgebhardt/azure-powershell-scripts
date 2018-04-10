$vault = Get-AzureRmRecoveryServicesVault -Name <vault name goes here>
Set-AzureRmRecoveryServicesVaultContext -Vault $vault

$containers = Get-AzureRmRecoveryServicesBackupContainer -ContainerType AzureSQL -FriendlyName $vault.Name
ForEach ($container in $containers) {
    $items = Get-AzureRmRecoveryServicesBackupItem -container $container -WorkloadType AzureSQLDatabase
    ForEach ($item in $items) {
        Disable-AzureRmRecoveryServicesBackupProtection -item $item -RemoveRecoveryPoints -ea SilentlyContinue
    }
    Unregister-AzureRmRecoveryServicesBackupContainer -Container $container
}
Remove-AzureRmRecoveryServicesVault -Vault $vault -Verbose