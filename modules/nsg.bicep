resource vmsng 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: 'vm-nsg'
  location: resourceGroup().location
  properties: {
    securityRules: [
    ]
  }
}
output nsgId string = vmsng.id
