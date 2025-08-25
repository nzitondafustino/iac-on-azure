param natName string

var location = resourceGroup().location

// Public IP for NAT Gateway
resource outboundIp 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: '${natName}-ip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// NAT Gateway
resource natGateway 'Microsoft.Network/natGateways@2019-09-01' = {
  name: natName
  location: location
  sku: {
    name: 'Standard'
  }
  zones: []
  properties: {
    publicIpAddresses: [
      {
        id: outboundIp.id
      }
    ]
    idleTimeoutInMinutes: 4
  }
}

output natGatewayIp string = natGateway.id
