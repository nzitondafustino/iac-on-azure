param vnetName string
param subnets  array
param addressPrefix string
param vmNatIp string

var location = resourceGroup().location


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [ for i in range(0,length(subnets)): {
        name: subnets[i]
        properties: {
          addressPrefix: cidrSubnet(addressPrefix, 24, i)
          natGateway: subnets[i] == 'default'? { id: vmNatIp }: null
        }
      }
    ]
  }
}
