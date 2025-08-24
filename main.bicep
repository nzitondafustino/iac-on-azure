var spoke_address_prefixes = ['10.1.0.0/16', '10.2.0.0/16']
var spoke_vnet_names = ['spoke1-vnet', 'spoke2-vnet']
var subnet_names = ['default', 'storage-account']
var vmNames = ['vm1', 'vm2']
var adminpwd = 'azureuser12345!'
var adminUsename = 'azureuser'
var vpngwName = 'vpn-gw'
var storaheAccountName = 'learning1011'
var  dnsZoneName = 'privatelink.blob.core.windows.net'


// create hub vnet
module hubvnet 'modules/hub.bicep' = {}

// create private dns resolver
module dns_resolver 'modules/private-dns-resolve.bicep' = {
  params: {
    subnetId: hubvnet.outputs.inbountDnsSubnet
    vnetId: hubvnet.outputs.vnetId
  }
}

// // create VPN Gateway

module vpnGw 'modules/vpn-gateway.bicep' = {
  params: {
    name: vpngwName
    subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', hubvnet.outputs.vnetName, 'GatewaySubnet')
  }
}

// create route table
module routeTable 'modules/routing-table.bicep' = {}
// create vnets
module spoke_vnets 'modules/spoke.bicep' = {
  params: {
    privatePrefixes: spoke_address_prefixes
    subnets: subnet_names
    vnetNames: spoke_vnet_names
    dnsServers:[dns_resolver.outputs.dnsResolversIp,'168.63.129.16', '8.8.8.8']
    routeTableId: routeTable.outputs.routeTableId
  }
}
// create VMs
module nsg 'modules/nsg.bicep' = {}

module nic1 'modules/nic.bicep' = {
  dependsOn:[spoke_vnets]
  params: {
    nsgId: nsg.outputs.nsgId
    subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', spoke_vnet_names[0], subnet_names[0])
    vmName: vmNames[0]
  }
}

module nic2 'modules/nic.bicep' = {
  dependsOn:[spoke_vnets]
  params: {
    nsgId: nsg.outputs.nsgId
    subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', spoke_vnet_names[1], subnet_names[0])
    vmName: vmNames[1]
  }
}

module vm1 'modules/mv.bicep' = {
  params: {
    adminpwd: adminpwd
    adminUsename: adminUsename
    nicId: nic1.outputs.id
    vmName:vmNames[0]
  }
}

module vm2 'modules/mv.bicep' = {
  params: {
    adminpwd: adminpwd
    adminUsename: adminUsename
    nicId: nic2.outputs.id
    vmName:vmNames[1]
  }
}

// create vnet peerings
module peerings 'modules/network-peering.bicep' = {
  dependsOn:[spoke_vnets]
  params: {
    hasVpnGateway: true
    hub: hubvnet.outputs.vnetName
    vnetNames: spoke_vnet_names
  }
}
// create IP
module public_ip 'modules/public-ip.bicep' = {}

// create firewall

module firewall 'modules/firewall.bicep' = {
  name:'firewall'
  params: {
    publicIp: public_ip.outputs.firewallIpId
    subnetId: hubvnet.outputs.firewallSubnet
    // inboundPrivateIp: dns_resolver.outputs.dnsResolversIp
    publicIpIpAddress: public_ip.outputs.firewallIpAddress
    destinationPorts: ['22','222'] 
    vmPrivateIps: [nic1.outputs.privateIp, nic2.outputs.privateIp]
  }
}

// update routing table route
module routeTableRoute 'modules/route-table-routes.bicep' = {
  params: {
    nextHopIp: firewall.outputs.firewallPrivateIp
    routeTableName: routeTable.outputs.routeTableName
  }
}

// create storage account 

// create dns zone

module dnszone 'modules/private-dns.bicep' = {
  params: {
    dnsZoneName: dnsZoneName
  }
}

module sroragAccout1 'modules/storage-account.bicep' = {
  dependsOn: [dnszone]
  params: {
    name: '${storaheAccountName}1'
    subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', spoke_vnet_names[0], subnet_names[1])
    hubVnet: hubvnet.outputs.vnetName
    spokeVnet: spoke_vnet_names[0]
    dnsZoneName: dnsZoneName
  }
}

module sroragAccout2 'modules/storage-account.bicep' = {
  dependsOn: [dnszone, sroragAccout1]
  params: {
    name: '${storaheAccountName}2'
    subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', spoke_vnet_names[1], subnet_names[1])
    hubVnet: hubvnet.outputs.vnetName
    spokeVnet: spoke_vnet_names[1]
    dnsZoneName: dnsZoneName
  }
}

