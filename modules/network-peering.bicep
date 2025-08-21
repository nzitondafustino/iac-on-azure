param vnetNames array
param hub string
param hasVpnGateway bool

resource hub_peerings 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = [for i in range(0,length(vnetNames)): {
  name: format('{0}/{0}-to-{1}', hub, vnetNames[i])
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: hasVpnGateway
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', vnetNames[i])
    }
  }
}
]

resource spoke_peerings 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = [for i in range(0,length(vnetNames)): {
  name: format('{0}/{0}-to-{1}', vnetNames[i], hub)
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: hasVpnGateway
    remoteVirtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', hub)
    }
  }
}
]
