param subnets array
param nsgName  string
param vnetName string
param vmNames array
param adminUsername string
@secure()
param adminPassword string
param natName  string
param firewallName string
param ports array
param loadBalancername string


// create NAT

module nat 'modules/outbound-nat.bicep' = {
  params: {
    natName: natName
  }
}

// create Vnet

module vnet 'modules/vnet.bicep' = {
  params: {
    vnetName: 'loadbalancer-vnet'
    addressPrefix: '10.0.0.0/16'
    subnets: subnets
    vmNatIp: nat.outputs.natGatewayIp
  }
}

// create nsg 

module nsg 'modules/nsg.bicep' = {
  params: {
    nsgName: nsgName
  }
}

// create load balancer

module internalLoadBalancer 'modules/load-balancer.bicep' = {
  params: {
    loadBalancerName: loadBalancername
    subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, 'load-balancer')
  }
}

// create NIC

module nic1 'modules/nic.bicep' = {
  dependsOn: [vnet]
  params: {
    nsgId: nsg.outputs.nsgId
    subNetId:  resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnets[0])
    vmName: vmNames[0]
    backEndPoolId: internalLoadBalancer.outputs.backendPoolId
  }
}

module nic2 'modules/nic.bicep' = {
  dependsOn: [vnet]
  params: {
    nsgId: nsg.outputs.nsgId
    subNetId:  resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnets[0])
    vmName: vmNames[1]
    backEndPoolId: internalLoadBalancer.outputs.backendPoolId
  }
}

// create VMs

module vm1 'modules/vm.bicep' = {
  params: {
    adminUsername: adminUsername
    adminPassword: adminPassword
    nicId: nic1.outputs.nicId
    vmName: vmNames[0]
  }
}

module vm2 'modules/vm.bicep' = {
  params: {
    adminUsername: adminUsername
    adminPassword: adminPassword
    nicId: nic2.outputs.nicId
    vmName: vmNames[1]
  }
}

// create firewall 
module firewall 'modules/firewall.bicep' = {
  params: {
    firewallName: firewallName
    ports: ports
    subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, 'AzureFirewallSubnet')
    vmIps: [nic1.outputs.nicIp, nic2.outputs.nicIp]
    loadbalancerIp: internalLoadBalancer.outputs.frontEndIp
  }
}

