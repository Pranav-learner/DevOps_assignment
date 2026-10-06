# Amazon Virtual Private Cloud (VPC) — Cloud Networking & Isolation

## 1. What is Amazon VPC?

**Amazon Virtual Private Cloud (Amazon VPC)** enables you to provision a logically isolated, software-defined section of the AWS Cloud where you can launch AWS resources in a virtual network that you define.

VPC gives you complete control over your network environment, including selection of your own IP address range, creation of subnets, configuration of route tables, network gateways, and multi-layer security filtering.

```
+---------------------------------------------------------------------------------------------------------+
|                                    Amazon VPC: 10.0.0.0/16                                              |
|                                                                                                         |
|   +------------------------------------+             +------------------------------------+             |
|   | Public Subnet: 10.0.1.0/24 (AZ-a)  |             | Private Subnet: 10.0.10.0/24 (AZ-a)|             |
|   |  - Internet Gateway Attached       |             |  - No Direct Internet Access      |             |
|   |  - Application Load Balancer / NAT |             |  - App Microservices / EKS Pods    |             |
|   +-----------------+------------------+             +------------------+-----------------+             |
|                     |                                                   |                               |
|                     v                                                   v                               |
|        [ Internet Gateway (IGW) ]                           [ NAT Gateway in Public Subnet]             |
|                     |                                                   |                               |
|                     +==================> [ INTERNET ] <=================+                               |
|                                                                                                         |
|   +------------------------------------+                                                                |
|   | Isolated Subnet: 10.0.20.0/24(AZ-a)|                                                                |
|   |  - Databases (RDS / Aurora)        |                                                                |
|   |  - Zero Egress to Internet         |                                                                |
|   +------------------------------------+                                                                |
+---------------------------------------------------------------------------------------------------------+
```

---

## 2. CIDR Blocks & IP Allocation

A **CIDR (Classless Inter-Domain Routing)** block defines the range of private IP addresses allocated to your VPC.
- **Allowed Sizes**: Between `/16` (65,536 IP addresses) and `/28` (16 IP addresses). Recommended VPC baseline: `10.0.0.0/16` or `172.16.0.0/16`.
- **Reserved IP Addresses**: In every subnet created in AWS, the first **4** and the last **1** IP address are reserved by AWS and cannot be assigned to hosts:
  - `.0`: Network address.
  - `.1`: Reserved by AWS for the VPC local router.
  - `.2`: Reserved by AWS for DNS (AmazonProvidedDNS).
  - `.3`: Reserved by AWS for future use.
  - `.255`: Network broadcast address (AWS does not support broadcast, but reserves it).
  - *Example*: A `/24` subnet contains $256 - 5 = 251$ usable IP addresses.

---

## 3. Subnets (Public vs. Private)

A **Subnet** is a range of IP addresses within a VPC mapped to a single specific **Availability Zone (AZ)**.

| Subnet Type | Route Table Target for `0.0.0.0/0` | Public IPs Auto-Assigned? | Typical Workloads |
|---|---|---|---|
| **Public Subnet** | Points to an **Internet Gateway (IGW)** | Yes (`map_public_ip_on_launch = true`) | Public ALBs, NAT Gateways, Bastion Jump Hosts, reverse proxies. |
| **Private Subnet** | Points to a **NAT Gateway** (or Virtual Private Gateway for VPN) | No | Backend microservices, EKS worker nodes, internal load balancers. |
| **Isolated Subnet**| No route to `0.0.0.0/0` (Local VPC route only) | No | Relational databases (RDS), Redis caches, internal HSMs. |

---

## 4. Route Tables & Gateways

### 4.1 Route Tables
A **Route Table** contains a set of rules (routes) that determine where network traffic from your subnet or gateway is directed.
- **Local Route**: Every route table automatically includes a local route (e.g., `10.0.0.0/16` $\to$ `local`) that enables private communication between all subnets in the VPC. This route cannot be deleted.
- **Default Route (`0.0.0.0/0`)**: The quad-zero destination specifies where non-local internet-bound packets are sent.

### 4.2 Internet Gateway (IGW)
An **Internet Gateway** is a horizontally scaled, redundant, highly available VPC component that enables direct bidirectional communication between your VPC and the internet.
- Performs 1-to-1 Network Address Translation (NAT) for instances with public IPv4 addresses.
- Imposes no bandwidth constraints or availability bottlenecks.

### 4.3 NAT Gateway (Network Address Translation)
A **NAT Gateway** enables instances in a private subnet to connect to the internet (e.g., downloading OS security patches, Docker images, external APIs) while **preventing the outside internet from initiating inbound connections** to those instances.
- Must be deployed in a **Public Subnet** with an associated **Elastic IP (EIP)**.
- Scaled automatically up to 45 Gbps per gateway.
- For high availability across AZ failures, deploy one NAT Gateway per Availability Zone.

---

## 5. Security Groups vs. Network Access Control Lists (NACLs)

AWS provides a defense-in-depth model utilizing two distinct firewall layers:

| Feature | Security Group (SG) | Network ACL (NACL) |
|---|---|---|
| **Operating Layer** | Virtual Network Interface (ENI / Instance level) | Subnet boundary level |
| **State Tracking** | **Stateful**: Return traffic automatically allowed regardless of inbound rules | **Stateless**: Inbound and outbound traffic must be explicitly allowed separately |
| **Rule Types** | **Allow rules only**; all other traffic implicitly denied | Supports **Allow** and **Deny** rules |
| **Rule Evaluation** | All rules evaluated in aggregate before making decision | Rules evaluated in order by **Rule Number** (lowest number first, e.g. 100, 200, *) |
| **Ephemerality** | Return ephemeral ports automatically handled | Must explicitly allow outbound return traffic on ephemeral ports (`1024-65535`) |

---

## 6. Secure Multi-Tier VPC Reference Architecture

```
                  +----------------------------------------------+
                  |               Internet Client                |
                  +----------------------+-----------------------+
                                         |  HTTPS (Port 443)
                                         v
                         [ Internet Gateway (IGW) ]
                                         |
     +-----------------------------------v-----------------------------------+
     | Public Subnet (AZ-a & AZ-b)                                           |
     | [ Application Load Balancer ] <--- SG: Inbound 443 from 0.0.0.0/0     |
     | [ NAT Gateway ] (Provides Egress for Private Subnets)                 |
     +-----------------------------------+-----------------------------------+
                                         |  Forward to Target Group (Port 3000)
                                         v
     +-----------------------------------------------------------------------+
     | Private Subnet (AZ-a & AZ-b)                                          |
     | [ Microservice Instances / EKS ] <--- SG: Inbound 3000 from ALB-SG    |
     +-----------------------------------+-----------------------------------+
                                         |  DB Connection (Port 5432)
                                         v
     +-----------------------------------------------------------------------+
     | Isolated Database Subnet (AZ-a & AZ-b)                                |
     | [ Amazon RDS Multi-AZ ] <--- SG: Inbound 5432 from App-SG ONLY        |
     +-----------------------------------------------------------------------+
```
