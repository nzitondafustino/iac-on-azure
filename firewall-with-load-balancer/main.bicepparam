using './main.bicep'

param vnetName = 'loadbalancer-vnet'
param loadBalancername = 'web-load-balancer'
param nsgName = 'vm-nsg'
param adminUsername = 'azureuser'
param adminPassword = 'azureuser12345!'
param natName = 'vms-nat'
param firewallName = 'app-firewall'
param subnets = [
  'default'
  'load-balancer'
  'AzureFirewallSubnet'
]
param vmNames = [
  'vm1'
  'vm2'
]
param ports = [
  '22'
  '222'
]

