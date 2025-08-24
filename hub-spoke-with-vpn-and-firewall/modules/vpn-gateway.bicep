param name string
param subnetId string

var location = resourceGroup().location
var tenantId = 'ec4367b3-8a89-4af5-9503-2e664476fcde'
var audience = '41b23e61-6c1e-4545-b367-cd054e0ed4b4'
var asn = 65515
var sku = 'VpnGw1'
var generation = 'Generation1'


resource newPublicIp 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: '${name}-primaryIp'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource activeActivePublicIp 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: '${name}-secondaryIp'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource point2siteIp 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: '${name}-p2s'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource vpnGateway 'Microsoft.Network/virtualNetworkGateways@2024-05-01' = {
  name: name
  location: location
  properties: {
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    vpnGatewayGeneration: generation
    activeActive: true
    enableBgp: true
    sku: {
      name: sku
      tier: sku
    }
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: newPublicIp.id
          }
        }
      }
      {
        name: 'activeActive'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: activeActivePublicIp.id
          }
        }
      }
      {
        name: 'p2sConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: point2siteIp.id
          }
        }
      }
    ]
    bgpSettings: {
      asn: asn
      bgpPeeringAddresses: [
        {
          ipconfigurationId: resourceId('Microsoft.Network/virtualNetworkGateways/ipConfigurations', name, 'default')
          customBgpIpAddresses: []
        }
        {
          ipconfigurationId: resourceId('Microsoft.Network/virtualNetworkGateways/ipConfigurations', name, 'activeActive')
          customBgpIpAddresses: []
        }

      ]
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
      vpnAuthenticationTypes: [
        'AAD'
      ]
      vpnClientRootCertificates: []
      vpnClientRevokedCertificates: []
      vngClientConnectionConfigurations: []
      radiusServers: []
      vpnClientIpsecPolicies: []
      aadTenant: 'https://login.microsoftonline.com/${tenantId}'
      aadAudience: audience
      aadIssuer: 'https://sts.windows.net/${tenantId}/'
    }
  }
}

