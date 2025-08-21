param name string
param subnetId string

var location = resourceGroup().location
var tenantId = 'ec4367b3-8a89-4af5-9503-2e664476fcde'
var audience = '41b23e61-6c1e-4545-b367-cd054e0ed4b4'

resource primaryIp 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: '${name}-primaryIp'
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  zones: []
}

resource vpGw 'Microsoft.Network/virtualNetworkGateways@2024-05-01' = {
  name: name
  location: location
  properties: {
    gatewayType: 'Vpn'
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: primaryIp.id
          }
        }
      }
    ]
    vpnType: 'RouteBased'
    vpnGatewayGeneration: 'Generation1'
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
    vpnClientConfiguration: {
      vpnClientAddressPool: {
        addressPrefixes: [
          '10.255.0.0/16'
        ]
      }
      vpnClientProtocols: [
        'OpenVPN'
      ]
      aadAudience: audience
      aadIssuer: 'https://sts.windows.net/${tenantId}/'
      aadTenant: 'https://login.microsoftonline.com/${tenantId}'
    }
  }
}
