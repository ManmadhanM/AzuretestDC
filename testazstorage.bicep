resource symbolicname 'Microsoft.Storage/storageAccounts@2022-09-01' = { 
  name:'madhantest'
  location:'eastus'
  sku:{
    name: 'Standard_LRS'
  }
  kind:'StorageV2'
  properties:{

    accessTier:'Cool'
    largeFileSharesState:'Disabled'
    } 
}
