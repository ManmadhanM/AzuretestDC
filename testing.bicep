param location string = resourceGroup().location
resource testing 'Microsoft.Storage/storageAccounts@2022-09-01'= {
  name:'madhutesting'
  location:'eastus'
tags:{
  owner:'Madhan'
  product:'madhuman'
}
properties:{
  accessTier:'Cool'
  allowBlobPublicAccess:false
}
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}
