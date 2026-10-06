# Amazon DynamoDB & Amazon RDS — Managed Cloud Databases

## 1. Overview: NoSQL vs. Relational Databases in AWS

Modern cloud architectures select database engines tailored to access patterns and consistency models:

| Dimension | Amazon DynamoDB | Amazon Relational Database Service (RDS) |
|---|---|---|
| **Paradigm** | **NoSQL** (Key-Value & Document store) | **Relational** (RDBMS / SQL engine) |
| **Data Schema** | Schema-free (flexible JSON attributes) | Strict, predefined schema with foreign key constraints |
| **Scalability** | Horizontal scaling via automated sharding | Vertical instance scaling + Read Replicas (Aurora scales storage horizontally) |
| **Latency** | Consistent single-digit millisecond latency | Low millisecond latency (dependent on index/query complexity) |
| **Maintenance** | Serverless; zero server patching, auto-scaling | Managed virtual instances; automated backups, patch windows |
| **Query Model** | Key-value lookup, batch gets, partition scans | Complex SQL joins, aggregations, window functions |

---

## 2. Amazon DynamoDB

**Amazon DynamoDB** is a fully managed, serverless, key-value and document NoSQL database designed for internet-scale applications requiring predictable sub-10ms response times.

```
       +-------------------------------------------------------------+
       |                   DynamoDB Table: `Orders`                  |
       +-------------------------------------------------------------+
       | Primary Key: Partition Key (`CustomerID`) + Sort Key (`OrderID`) |
       +-------------------------------------------------------------+
       | Items & Dynamic Attributes:                                 |
       | - PK: "CUST-100" | SK: "ORD-2026-001" | Total: 154.50       |
       | - PK: "CUST-100" | SK: "ORD-2026-002" | Total: 49.00        |
       | - PK: "CUST-200" | SK: "ORD-2026-003" | Items: ["x", "y"]   |
       +-------------------------------------------------------------+
                                      |
                       +--------------+--------------+
                       | Physical Sharding Mechanism |
                       +--------------+--------------+
                                      v
       [ Partition 1: Hash(PK) ]             [ Partition 2: Hash(PK) ]
        Auto-replicated across 3 AZs          Auto-replicated across 3 AZs
```

### 2.1 Core Concepts
- **Table**: Collection of items. Does not require a fixed schema; each item can contain distinct attributes.
- **Item**: A single record/row in the table. Maximum item size is **400 KB**.
- **Attribute**: A fundamental data element (e.g., String, Number, Binary, Boolean, List, Map).
- **Primary Key Types**:
  1. **Partition Key (Hash Key)**: A single attribute. DynamoDB passes the key to an internal hash function to determine the physical partition where the item is stored.
  2. **Composite Primary Key (Partition Key + Sort Key / Range Key)**: Two attributes. Items sharing the same Partition Key are stored together physically and sorted in ascending order by the Sort Key.

### 2.2 Secondary Indexes
- **Global Secondary Index (GSI)**: An index with a partition key and sort key that can be different from those on the base table. Can be queried across all partitions.
- **Local Secondary Index (LSI)**: An index that shares the same partition key as the base table, but has a different sort key. Scoped to a single partition key value.

### 2.3 DynamoDB Use Cases
- High-velocity shopping carts and user checkout sessions.
- Real-time mobile gaming leaderboards and player state.
- IoT device telemetry data ingestion.
- Microservice event sourcing and distributed lock management.

---

## 3. Amazon Relational Database Service (RDS)

**Amazon RDS** simplifies the setup, operation, and scaling of relational databases in the cloud. It automates time-consuming administrative tasks such as hardware provisioning, database setup, patching, and automated backups.

```
+-----------------------------------------------------------------------------------------+
|                              Amazon RDS Multi-AZ Deployment                             |
|                                                                                         |
|       Availability Zone A (Primary)                     Availability Zone B (Standby)   |
|   +------------------------------------+             +------------------------------------+
|   | RDS Primary Instance (Read/Write)  |             | RDS Standby Replica (Passive)      |
|   |  - Active Database Engine          |             |  - Inactive for direct queries     |
|   |  - Local EBS Storage (gp3/io2)     |             |  - Synchronously Replicated Storage|
|   +-----------------+------------------+             +-----------------+------------------+
|                     |                                                  ^
|                     +====== Synchronous Storage Block Replication =====+
|                                                  |
|                   [ Automatic Failover Trigger on HW/AZ Fault ]
|                   [ DNS CNAME automatically repointed in 60-120s]
+-----------------------------------------------------------------------------------------+
```

### 3.1 Supported Database Engines
1. **Amazon Aurora**: Cloud-native MySQL and PostgreSQL-compatible engine offering up to $5\times$ (MySQL) and $3\times$ (PostgreSQL) the throughput of standard engines with self-healing distributed storage.
2. **PostgreSQL**
3. **MySQL**
4. **MariaDB**
5. **Oracle Database** (Enterprise, Standard)
6. **Microsoft SQL Server** (Enterprise, Standard, Web, Express)

### 3.2 High Availability via Multi-AZ
- **Synchronous Replication**: When Multi-AZ is enabled, RDS automatically provisions and maintains a synchronous standby replica in a different Availability Zone within the same VPC.
- **Zero Data Loss Failover**: If the primary instance suffers a host failure, storage degradation, or network outage, RDS automatically triggers failover by repointing the database DNS endpoint to the standby instance within 60 to 120 seconds.

### 3.3 Scaling Reads via Read Replicas
- **Asynchronous Replication**: Read Replicas handle read-heavy queries to reduce load on the primary writer instance.
- Up to **5 Read Replicas** for standard RDS engines; up to **15 Read Replicas** for Amazon Aurora.
- Read Replicas can be deployed across regions for disaster recovery and local low-latency read performance.

### 3.4 Automated Backups & Security
- **Point-in-Time Recovery (PITR)**: Automated daily storage snapshots and continuous transaction log backups allow restoration to any second within the retention window (1 to 35 days).
- **Security**: Network isolation via VPC Private Subnets, Security Groups, TLS 1.3 in-transit encryption, AWS KMS at-rest encryption, and IAM Database Authentication.

### 3.5 RDS Use Cases
- ACID transactional financial ledger systems and accounting platforms.
- ERP, CRM, and enterprise supply chain management software.
- E-commerce order management with complex relational inventory joins.
