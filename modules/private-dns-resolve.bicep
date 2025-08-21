param vnetId string
param subnetId string

var location = resourceGroup().location

resource dnsResolvers 'Microsoft.Network/dnsResolvers@2022-07-01' = {
  name: 'hub-dns-resolver'
  location: location
  properties: {
     virtualNetwork: {
      id: vnetId
     }
  }

  resource inboundEndpoints 'inboundEndpoints' = {
    name: 'inbound-endpoint'
    location: location
    properties: {
      ipConfigurations: [
        {
          privateIpAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
        }
      ]
    }
  }
}

output dnsResolversIp string = dnsResolvers::inboundEndpoints.properties.ipConfigurations[0].privateIpAddress
