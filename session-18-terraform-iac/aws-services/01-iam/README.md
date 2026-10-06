# AWS Identity and Access Management (IAM) — Governance & Access Control

## 1. What is IAM?

**AWS Identity and Access Management (IAM)** is a foundational AWS web service that enables secure management and governance of access to AWS services and resources. It provides fine-grained authorization and authentication controls without requiring shared credentials or external directory synchronizations.

IAM is a **global service** (it operates globally across all AWS regions without regional endpoints) and operates on a default **implicit deny** security model: any action that is not explicitly allowed is denied, and any explicit deny overrides all allows.

```
       +-----------------------------------------------------------+
       |                  AWS Identity (Principal)                |
       |      IAM User  /  IAM Role (Federated, EC2, Lambda)       |
       +-----------------------------+-----------------------------+
                                     |
                                     v
                       [ Authentication: Who are you? ]
                                     |
                                     v
                       [ Authorization: Can you do this? ]
                        - Identity-Based Policies
                        - Resource-Based Policies
                        - Permission Boundaries
                        - Service Control Policies (SCP)
                                     |
                                     +-----------------+
                                     | Decision Engine |
                        +------------+-----------------+------------+
                        |                                           |
                        v                                           v
               [ Explicit Deny? ]                           [ Explicit Allow? ]
                 YES: Access Denied                           YES: Access Allowed
                 NO: Proceed to check                         NO: Implicit Deny
```

---

## 2. Core IAM Components

### 2.1 IAM Users
An **IAM User** represents a specific human person or external application identity that interacts with AWS.
- **Credentials**: Can have console access (username + password) and programmatic access (up to two active Access Key ID & Secret Access Key pairs).
- **Direct Assignment**: While permissions can be attached directly to users (inline policies or managed policies), AWS best practices recommend grouping users into IAM Groups.

### 2.2 IAM Groups
An **IAM Group** is a collection of IAM users.
- Groups simplify permission management by allowing administrators to attach policies to the group rather than maintaining individual users.
- A user can belong to multiple groups (up to 300).
- Groups cannot be nested (a group cannot contain another group).
- Groups cannot be identified as a `Principal` in resource-based policies.

### 2.3 IAM Roles
An **IAM Role** is an IAM identity that you can create in your account that has specific permissions, but is **not associated with a specific person**.
- Instead of static long-term credentials (passwords or access keys), assuming a role grants **temporary security credentials** generated via the AWS Security Token Service (STS) (`sts:AssumeRole`).
- **Assume Role Policy Document (Trust Policy)**: Defines *who* is trusted to assume the role (e.g., an AWS service like `ec2.amazonaws.com`, another AWS account, or a SAML/OIDC identity provider).
- **Permissions Policy**: Defines *what* actions the entity can perform once the role is assumed.

```json
// Example Trust Policy (Who can assume this role)
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

---

## 3. Policies and Permissions

An **IAM Policy** is a JSON document that defines permissions. Policies can be identity-based or resource-based.

### 3.1 Policy Anatomy
Every IAM policy statement contains the following key elements:
- `Version`: Always `"2012-10-17"` (the current policy language version).
- `Statement`: Array of individual permission statements.
  - `Sid` (Optional): Statement Identifier for documentation/auditing.
  - `Effect`: `"Allow"` or `"Deny"`.
  - `Principal`: (Required for Resource-based policies & Trust policies) The entity allowed or denied access.
  - `Action`: The specific API call or list of actions (e.g., `"s3:GetObject"`, `"ec2:DescribeInstances"`).
  - `Resource`: The Amazon Resource Name (ARN) identifying the target resource(s).
  - `Condition` (Optional): Key-value pairs specifying circumstances under which the policy grants or denies permission (e.g., source IP, MFA status, tag match, date range).

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EnforceMFAAndReadOnlyS3",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::corporate-finance-data",
        "arn:aws:s3:::corporate-finance-data/*"
      ],
      "Condition": {
        "Bool": {
          "aws:MultiFactorAuthPresent": "true"
        },
        "IpAddress": {
          "aws:SourceIp": "198.51.100.0/24"
        }
      }
    }
  ]
}
```

### 3.2 Types of Policies
| Policy Type | Attached To | Description |
|---|---|---|
| **Identity-Based (AWS Managed)** | Users, Groups, Roles | Created and maintained by AWS (e.g., `AdministratorAccess`, `ReadOnlyAccess`). Automatically updated when new actions are released. |
| **Identity-Based (Customer Managed)** | Users, Groups, Roles | Custom policies tailored to organization needs. Version-controlled (up to 5 versions per policy). |
| **Inline Policies** | Single User, Group, or Role | Embedded directly within an identity. 1-to-1 relationship, deleted when the identity is deleted. |
| **Resource-Based Policies** | Resources (S3, SQS, KMS, Secrets Manager) | Attached directly to resources. Grants permissions to principals including cross-account principals. |
| **Permissions Boundaries** | Users, Roles | Sets the maximum permissions that an identity-based policy can grant. Prevents privilege escalation. |
| **Service Control Policies (SCPs)** | AWS Organizations OUs or Accounts | Guardrails that specify the maximum available permissions across an entire member account. |

---

## 4. The Principle of Least Privilege

The **Principle of Least Privilege (PoLP)** states that every identity (user, application, service) should be granted only the minimum permissions necessary to perform its intended job function, and only for the duration required.

### How to Achieve Least Privilege:
1. **Start with AWS Managed Job-Function Policies**: Use granular baseline policies rather than `AdministratorAccess` or `*`.
2. **Narrow Down with Resource ARNs**: Restrict `Resource: "*"` to specific resource ARNs (`arn:aws:s3:::my-app-logs/*`).
3. **Use Conditions for Contextual Control**: Enforce `aws:PrincipalTag`, `aws:SourceIp`, and `aws:SecureTransport` (HTTPS only).
4. **Grant Temporary Credentials via Roles**: Never distribute hardcoded secret keys; use IAM Roles with STS session tokens that expire after 1 hour.
5. **Analyze with IAM Access Analyzer**: Continuously identify unused permissions and public/cross-account resource access.

---

## 5. IAM Best Practices

1. **Lock Down the AWS Account Root User**:
   - Enable hardware or virtual MFA immediately.
   - Delete all root access keys.
   - Do not use the root user for daily operational or administrative tasks.
2. **Enforce Multi-Factor Authentication (MFA)**:
   - Require MFA for all IAM users with console access.
   - Enforce MFA via policy condition `aws:MultiFactorAuthPresent: "true"` for sensitive API calls.
3. **Use IAM Roles for Applications on EC2 / ECS / EKS / Lambda**:
   - Never bake AWS credentials into source code, container images, or configuration files.
   - Attach IAM Instance Profiles to EC2, Task Roles to ECS, and IRSA (IAM Roles for Service Accounts) to EKS pods.
4. **Use IAM Identity Center (AWS SSO) for Human Users**:
   - Federate human identity management with corporate identity providers (Okta, Azure AD, Google Workspace) via SAML 2.0 or OIDC.
5. **Rotate Credentials Regularly**:
   - Regularly rotate any long-lived IAM access keys (e.g., 90-day rotation cadence).
6. **Apply Permissions Boundaries for Delegated Administration**:
   - Prevent junior admins or automated CI/CD roles from creating users or roles with higher privileges than themselves.
7. **Regularly Audit and Monitor**:
   - Generate IAM Credential Reports to spot inactive users and old keys.
   - Stream CloudTrail logs to CloudWatch/S3 for auditing every API invocation.

---

## 6. Common IAM Use Cases

```
+---------------------------------------------------------------------------------------+
|                                COMMON IAM ARCHITECTURES                               |
+---------------------------------------------------------------------------------------+

1. Cross-Account Access via Role Delegation:
   [Dev Account: DevUser] ---> sts:AssumeRole ---> [Prod Account: S3ReadRole] ---> S3 Bucket

2. Application Workload Identity (EC2 Instance Profile):
   [EC2 Instance] ---> Metadata Service (IMDSv2) ---> Temporary STS Credentials ---> DynamoDB

3. EKS IAM Roles for Service Accounts (IRSA):
   [Pod in K8s] ---> OIDC Federation ---> STS AssumeRoleWithWebIdentity ---> SQS Queue

4. CI/CD Pipeline Deployment (GitHub Actions):
   [GitHub Runner] ---> OIDC Token ---> AWS STS ---> Assume Deployment Role (No static keys!)
+---------------------------------------------------------------------------------------+
```
