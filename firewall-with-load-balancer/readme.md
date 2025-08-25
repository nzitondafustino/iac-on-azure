# Azure Network and Compute Design

This document explains the design and interactions between the deployed
Azure resources.

## Resources Overview

-   **Virtual Network (VNet)**: `loadbalancer-vnet`
    -   Address space: `10.0.0.0/16`
    -   Subnets:
        -   `default` → Hosts VMs and NICs
        -   `load-balancer` → Dedicated subnet for the Load Balancer
        -   `AzureFirewallSubnet` → Required subnet for Azure Firewall
-   **Network Security Group (NSG)**: `vm-nsg`
    -   Applied to VM NICs for traffic filtering.
-   **NAT Gateway**: `vms-nat`
    -   Provides outbound internet connectivity for VMs in the `default`
        subnet.
-   **Internal Load Balancer**: `web-load-balancer`
    -   Frontend IP in `load-balancer` subnet.
    -   Backend pool associated with VM NICs (`vm1-nic`, `vm2-nic`).
-   **Network Interfaces (NICs)**:
    -   `vm1-nic` → Associated with VM1, NSG, backend pool of Load
        Balancer.
    -   `vm2-nic` → Associated with VM2, NSG, backend pool of Load
        Balancer.
-   **Virtual Machines (VMs)**:
    -   `vm1`, `vm2`
    -   Admin user: `azureuser`
    -   Password: `azureuser12345!`
    -   Connected via NICs and behind Load Balancer.
-   **Azure Firewall**: `app-firewall`
    -   Deployed in `AzureFirewallSubnet`.
    -   NAT rules created for ports `22` and `222` to allow SSH access
        to VM1 and VM2.
    -   Protects and controls inbound/outbound traffic for VMs and Load
        Balancer.

------------------------------------------------------------------------

## Interactions

1.  **Outbound Traffic**
    -   VMs in `default` subnet use **NAT Gateway** for outbound
        internet connectivity.
2.  **Inbound Traffic**
    -   Inbound traffic first hits **Azure Firewall**.
    -   Firewall has DNAT rules that forward traffic from its public IP:
        -   Port `22` → VM1 (SSH)
        -   Port `222` → VM2 (SSH)
    -   Load Balancer frontend IP is also protected behind Firewall
        rules.
3.  **Load Balancer**
    -   Distributes application traffic across VM1 and VM2 via backend
        pool.
    -   Uses health probes to monitor VM availability.
4.  **Network Security Group (NSG)**
    -   Enforces network rules for VM NICs, providing an extra layer of
        security in addition to the Firewall.
5.  **Virtual Machines**
    -   Hosted inside the VNet `default` subnet.
    -   Communicate internally through VNet and externally via
        Firewall + NAT.

------------------------------------------------------------------------

## High-Level Flow

1.  **Client → Firewall (DNAT Rules)** → VM1 or VM2 (SSH)\
2.  **Client → Firewall → Load Balancer → Backend Pool (VM1 & VM2)**\
3.  **VMs → NAT Gateway → Internet**

------------------------------------------------------------------------

## Diagram (Conceptual)

    Internet
       |
    [Azure Firewall]
       |
       +-- DNAT → VM1 (SSH 22)
       |
       +-- DNAT → VM2 (SSH 222)
       |
       +--→ Internal Load Balancer (App traffic)
               |
               +-- Backend Pool → VM1, VM2
       |
       +--→ Outbound via NAT Gateway

------------------------------------------------------------------------

## Design Considerations

-   **Separation of concerns**:
    -   Firewall subnet dedicated for inspection.\
    -   Load Balancer subnet isolates frontend traffic.\
    -   Default subnet hosts VMs.
-   **Security layering**:
    -   Azure Firewall for centralized rules.\
    -   NSGs for VM-specific security.
-   **Scalability**:
    -   Load Balancer can scale to distribute across more VMs.\
    -   Firewall can handle multiple NAT rules for additional services.
