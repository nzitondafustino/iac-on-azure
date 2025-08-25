param loadBalancerName string
param subnetId string

var location = resourceGroup().location

resource loadBalancerInternal 'Microsoft.Network/loadBalancers@2020-11-01' = {
  name: loadBalancerName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'app-${loadBalancerName}-frontend'
        properties: {
          privateIPAddress: '10.0.1.4'
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'app-${loadBalancerName}-backend'
      }
    ]
    loadBalancingRules: [
      {
        name: 'app-${loadBalancerName}-rule'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', loadBalancerName, 'app-${loadBalancerName}-frontend')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, 'app-${loadBalancerName}-backend')
          }
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          enableFloatingIP: false
          idleTimeoutInMinutes: 5
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', loadBalancerName, 'web-heath-probe')
          }
        }
      }
    ]
    probes: [
      {
        name: 'web-heath-probe'
        properties: {
          protocol: 'Tcp'
          port: 80
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
  }
}

output backendPoolId string = loadBalancerInternal.properties.backendAddressPools[0].id
output frontEndIp string = loadBalancerInternal.properties.frontendIPConfigurations[0].properties.privateIPAddress
