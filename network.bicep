@description('VNet name')
param vnetName string = 'VNet1'

@description('Address prefix')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Subnet 1 Prefix')
param subnet1Prefix string = '10.0.0.0/24'

@description('Subnet 1 Name')
param subnet1Name string = 'Subnet1'

@description('Subnet 2 Prefix')
param subnet2Prefix string = '10.0.1.0/24'

@description('Subnet 2 Name')
param subnet2Name string = 'Subnet2'

@description('Location for all resources.')
param location string = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name:'testmadhan'
  location:'eastus'
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name:'testnetwork'
        properties: {
          addressPrefix: subnet1Prefix
        }
      }
      {
        name:'testnetwork1'
        properties: {
          addressPrefix: subnet2Prefix
        }
      }
    ]
  }
}
