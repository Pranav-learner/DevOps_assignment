# Amazon Elastic Compute Cloud (EC2) — Resilient Cloud Compute

## 1. What is EC2?

**Amazon Elastic Compute Cloud (Amazon EC2)** is a core AWS Infrastructure-as-a-Service (IaaS) offering that provides scalable, on-demand virtual computing capacity in the AWS Cloud. EC2 eliminates the need to invest in upfront hardware, allowing developers and DevOps engineers to launch virtual server instances in minutes, scale capacity up and down dynamically based on demand, and pay only for compute resources consumed.

```
       +-------------------------------------------------------------+
       |                      Amazon EC2 Instance                    |
       |  +--------------------+             +--------------------+  |
       |  |  vCPU & RAM Core   |             | EBS Root / Data    |  |
       |  |  (Instance Type)   | <=========> | Volumes (gp3, io2) |  |
       |  +--------------------+             +--------------------+  |
       |            ^                                   ^            |
       +------------|-----------------------------------|------------+
                    |                                   |
    +---------------+---------------+   +---------------+---------------+
    | Security Group (Stateful FW)  |   | IAM Instance Profile (STS)    |
    | - Inbound: Port 22, 443       |   | - No hardcoded access keys!   |
    | - Outbound: All traffic       |   | - Auto-rotated temporary token|
    +-------------------------------+   +-------------------------------+
```

---

## 2. Amazon Machine Images (AMI)

An **Amazon Machine Image (AMI)** is a pre-configured template that contains the software configuration (operating system, application server, libraries, and applications) required to launch an EC2 instance.

### 2.1 Types of AMIs:
- **AWS Provided AMIs**: Maintained by AWS (e.g., Amazon Linux 2023, Ubuntu, Red Hat Enterprise Linux, Windows Server).
- **Custom AMIs (Golden Images)**: Built by users/organizations (often using HashiCorp Packer or EC2 Image Builder) with security hardening, internal agents, and monitoring tools baked in.
- **AWS Marketplace AMIs**: Packaged software stacks built by third-party vendors (e.g., Cisco firewalls, WordPress, Splunk, Datadog forwarders).
- **Community AMIs**: Shared publicly by the AWS community.

### 2.2 AMI Architecture & Virtualization:
- **Architectures**: `x86_64` (Intel/AMD) vs `arm64` (AWS Graviton processors, delivering up to 40% better price-performance).
- **Virtualization Type**: Modern AMIs use **HVM (Hardware Virtual Machine)** with AWS Nitro Hypervisor for near-bare-metal performance.

---

## 3. Instance Types & Families

EC2 instances are grouped into families optimized for different workloads. The naming convention follows:

$$\text{Instance Name} = \underbrace{\text{Family}}_{\text{m}} \underbrace{\text{Generation}}_{\text{6}} \underbrace{\text{Processor/Feature}}_{\text{i / g / a}} \cdot \underbrace{\text{Size}}_{\text{xlarge}}$$

*(e.g., `m6i.2xlarge` = General Purpose, 6th Generation, Intel processor, 2x large size)*

| Family Category | Instance Series | Target Workloads |
|---|---|---|
| **General Purpose** | `t4g`, `t3`, `m6i`, `m7g` | Web servers, small/medium databases, code repositories, microservices. Balanced compute, memory, and networking. |
| **Compute Optimized** | `c6i`, `c7g`, `c6a` | High-performance web servers, scientific computing, batch processing, gaming servers, machine learning inference. |
| **Memory Optimized** | `r6i`, `r7g`, `x2idn` | In-memory databases (Redis, Memcached), SAP HANA, real-time big data processing (Apache Spark), relational databases. |
| **Storage Optimized** | `i3en`, `i4i`, `d3` | High sequential read/write IOPS, data warehousing (Elasticsearch, Apache Kafka), distributed file systems. |
| **Accelerated Computing** | `g5`, `p4d`, `inf2` | Deep learning training, LLM fine-tuning, 3D graphics rendering, computer vision, video encoding. |

---

## 4. Key Pairs & Secure Access

EC2 uses **public-key cryptography** to authenticate remote access to Linux and Windows instances.
- **Key Pair Structure**: AWS holds the **public key**, while the user securely stores the **private key** (`.pem` or OpenSSH format).
- **Algorithms**:
  - `ED25519`: Modern, high-performance, short 256-bit key length.
  - `RSA`: Traditional 2048-bit or 4096-bit key algorithm.
- **EC2 Instance Connect & SSM Session Manager**: Modern alternative to managing static SSH keys. SSM Session Manager allows one-click, audited, TLS-encrypted shell access via IAM without opening inbound port 22 in Security Groups or allocating public IPs.

---

## 5. Security Groups (Stateful Virtual Firewalls)

A **Security Group** acts as a virtual firewall for your EC2 instances to control inbound and outbound traffic at the hypervisor network interface level (ENI).

### Key Rules and Characteristics:
- **Stateful**: If you send a request from an instance, the return traffic is automatically allowed regardless of inbound rules.
- **Allow-Only**: Security groups have no `Deny` rules; all traffic is blocked by default until an explicit `Allow` rule is added.
- **Security Group Chaining / Referencing**: A security group rule can reference another security group ID as the source instead of a CIDR block (e.g., backend app security group allows port 3000 only from ALB security group `sg-alb123`).

---

## 6. Elastic Block Store (EBS)

**Amazon Elastic Block Store (EBS)** provides persistent block-level storage volumes for EC2 instances. EBS volumes operate like raw, unformatted physical hard drives attached over high-speed network interconnects.

| EBS Volume Type | API Name | Max IOPS | Max Throughput | Ideal Use Cases |
|---|---|---|---|---|
| **General Purpose SSD** | `gp3` | 16,000 | 1,000 MB/s | Default boot volumes, virtual desktops, medium workloads. Configurable baseline performance without storage expansion. |
| **Provisioned IOPS SSD** | `io2` | 256,000 | 4,000 MB/s | Mission-critical low-latency databases (Oracle, MS SQL, PostgreSQL), multi-attach clustering. |
| **Throughput Optimized HDD**| `st1` | 500 | 500 MB/s | Big data, log processing, data warehouses, streaming map-reduce. |
| **Cold HDD** | `sc1` | 250 | 250 MB/s | Infrequently accessed data, lowest-cost block storage. |

### Snapshots & Encryption:
- **EBS Snapshots**: Point-in-time, incremental backups stored automatically in Amazon S3.
- **KMS Encryption**: EBS volumes support transparent AES-256 encryption at rest and in transit using AWS KMS customer managed or default keys.

---

## 7. Public vs. Private IP Addresses

| Characteristic | Private IPv4 | Public IPv4 | Elastic IP (EIP) |
|---|---|---|---|
| **Scope** | Internal VPC only | Public Internet | Public Internet |
| **Persistence** | Retained across instance stop/starts | Released upon instance stop/termination | Static public IP allocated to AWS account; retained across stop/starts |
| **DNS Resolution** | Internal VPC DNS (`ip-10-0-1-5.ec2.internal`) | Public DNS hostname | Public DNS hostname mapped to EIP |
| **Billing** | Free | Hourly charge applies | Free when attached to running instance; charged when unattached |

---

## 8. EC2 Instance Lifecycle

```
             +------------+
             |   Start    |
             +-----+------+
                   |
                   v
             [ Pending ]  <------------------+
                   |                         |
                   v                         |
              [ Running ]                    |
            /      |     \                   |
    Reboot /       |      \ Stop             |
          /        v       \                 |
 [ Rebooting ]  [ Terminated ]  [ Stopping ] |
                   |                 |       |
                 (Gone)              v       |
                                [ Stopped ] -+
```

1. **Pending**: Instance is being provisioned onto physical host hardware.
2. **Running**: Fully booted, guest OS active, running applications.
3. **Stopping / Stopped**: Storage volumes (EBS) persist, compute charges cease, RAM is wiped.
4. **Shutting-down / Terminated**: Permanently removed. Root EBS volume deleted by default unless `DeleteOnTermination=false`.
5. **Hibernate**: In-memory RAM state written directly to root EBS volume before stopping, allowing instant resumption.

---

## 9. Common EC2 Use Cases

1. **Scalable Web Hosting**: Web apps paired with Auto Scaling Groups (ASG) and Application Load Balancers (ALB).
2. **Self-Managed Databases**: Deploying custom MongoDB, Cassandra, or PostgreSQL clusters requiring fine-tuned OS kernels.
3. **Batch Computing**: Spot Instances processing video renders, genomic sequencing, or machine learning workloads at 70–90% discounts.
4. **CI/CD Self-Hosted Runners**: Dedicated Jenkins or GitHub Actions runners with enterprise firewall access.
