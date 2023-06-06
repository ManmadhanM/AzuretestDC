@description('KeyVault name')
param vaultName string

@description('Secret key values')
@secure()
param secrets object = {}

resource vault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: vaultName
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = [for secret in items(secrets): {
  name: secret.key
  parent: vault
  properties: {
    attributes: {
      enabled: true
    }
    value: secret.value
  }
}]
