param location string = resourceGroup().location
resource madhutest 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name:'testmadhu'
  location:'eastus'
  tags:{
  tagname:'testmadhu'
  owner:'Madhan'
  creaded:'madhan'
  product:'teststg'
  }
  sku: {
    name: 'Standard_LRS'
  }
  kind:'StorageV2'
}
