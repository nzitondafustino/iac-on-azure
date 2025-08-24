param vnetNames array
param privatePrefixes array
param subnets array
param dnsServers array
param routeTableId string

var location = resourceGroup().location


resource spokeVnet 'Microsoft.Network/virtualNetworks@2019-11-01' = [ for i in range(0,length((vnetNames))): {
  name: vnetNames[i]
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        privatePrefixes[i]
      ]
    }
    dhcpOptions: {
        dnsServers: dnsServers
    }
    subnets: [for j in range(0, length(subnets)): {
        name: subnets[j]
        properties: {
          addressPrefix: cidrSubnet(privatePrefixes[i], 24, j)
              // Conditionally include routeTable only if subnetName == 'default'
          routeTable: subnets[j]== 'default' ? {
            id: routeTableId
          } : null
        }
      }
    ]
  }
}
]
