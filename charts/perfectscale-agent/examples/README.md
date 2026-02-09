# ClusterSettings CRD Examples

This directory contains examples of how to use the `ClusterSettings` Custom Resource Definition (CRD) to configure PerfectScale profiles via GitOps.

## Recommended Workflow

**We prefer users to use refByID rather than inline profiles.**

1. **Create and test profiles in UI first**
   - Create profiles through the PerfectScale UI
   - Test and validate the configuration
   - Once satisfied, note the profile ID shown in UI (format: {type|class}-N, e.g., jira-1, slack-2)

2. **Reference tested profiles via refByID in CR (preferred method)**
   - Use `refByID` to reference the UI-created profile by its ID
   - No `assigned` field needed - refByID profiles are always assigned
   - See examples in `clustersettings-assign-existing.yaml`

3. **Alternative: Create inline profiles for testing**
   - Create inline profiles with `assigned: false` (default)
   - Profiles will be visible in UI and can be tested
   - Once tested, update CR to set `assigned: true` to activate the profile

## Validation Rules

- **Only ONE profile of each type can be assigned to a cluster**
- **For inline profiles**: Only ONE can have `assigned: true` per type (validation fails if multiple)
- **For refByID profiles**: Only ONE can be specified per type (validation fails if multiple)
- **IMPORTANT**: You CANNOT have BOTH a refByID AND an inline profile with `assigned: true` for the same type
  - If refByID exists for a type, ALL inline profiles of that type MUST have `assigned: false` (or unset)
  - Having both will fail validation
  - Valid: refByID + inline profiles with `assigned: false`
  - Invalid: refByID + any inline profile with `assigned: true`
- **refByID profiles**: Always considered assigned (no `assigned` field needed or required)
- **Non-existent refByID**: If referenced profile doesn't exist, validation passes but nothing happens (noop)
- **CRD Override**: CRD profiles (both refByID and inline) ALWAYS WIN over UI-assigned profiles

## Important Notes

- **All ClusterSettings resources MUST be applied in the `perfectscale` namespace**
- Only **one** ClusterSettings resource is allowed per cluster
- Secrets referenced in the CRD must exist in the `perfectscale` namespace
- **Profiles assigned via CRD cannot be deleted via UI** - deletion must be done via CRD

## UI-only Features

Some PerfectScale features are currently available only through the UI and cannot be configured via CRD:
- **Custom Grouping** (Ephemeral Pods Grouping) - See: https://docs.perfectscale.io/customize-workflow/ephemeral-pods-grouping
- **Automation Policies** - Automation rules and maintenance windows

All other profiles are fully supported via CRD.

## Files Overview

### Complete Examples
- **`clustersettings-all.yaml`** - Comprehensive example showing all profile types and configuration options
- **`clustersettings-mixed.yaml`** - Example combining inline profiles and profile references

### Simple Examples
- **`clustersettings-assign-existing.yaml`** - Assign existing profiles to cluster
- **`clustersettings-custom-pricing.yaml`** - Create custom node pricing inline
- **`clustersettings-podfit-labels.yaml`** - Configure PodFit label visibility
- **`clustersettings-customization.yaml`** - Configure workload labels
- **`clustersettings-resiliency-alerts.yaml`** - Resiliency alerts configuration
- **`clustersettings-cluster-labels.yaml`** - Configure cluster-scoped labels for classification

### Pricing Examples
- **`clustersettings-aws-cur.yaml`** - AWS Cost and Usage Report integration
- **`clustersettings-gcp-billing.yaml`** - GCP billing export integration
- **`clustersettings-azure-billing.yaml`** - Azure billing integration
- **`clustersettings-cloud-billing.yaml`** - Multi-cloud billing (GCP + Azure)

### Integration Examples
- **`clustersettings-slack.yaml`** - Slack integration for alerts
- **`clustersettings-teams.yaml`** - Microsoft Teams integration
- **`clustersettings-jira.yaml`** - Jira ticketing integration
- **`clustersettings-datadog.yaml`** - Datadog monitoring integration
- **`clustersettings-observability.yaml`** - Custom observability platform
- **`clustersettings-integrations.yaml`** - Multiple integrations (Teams + Jira + Datadog)

## Cluster Labels

Cluster labels allow you to tag your cluster with metadata for classification, governance, and organization purposes. Labels are defined at the `spec` level (not inside `profiles`).

```yaml
spec:
  clusterLabels:
    env: production
    team: platform
    cost-center: engineering
```

### Validation Rules
- Keys and values must be **1-255 characters**
- Keys and values must match pattern: `^[a-zA-Z0-9.\-_/]+$`
  - Allowed: alphanumeric, dots (`.`), hyphens (`-`), underscores (`_`), slashes (`/`)
  - Not allowed: spaces, `@`, `:`, `=`, `#`, or other special characters
- Empty keys or values are not allowed

### Common Use Cases
- **Environment**: `env: production`, `env: staging`, `env: development`
- **Team ownership**: `team: platform`, `team: backend`
- **Cost allocation**: `cost-center: engineering`, `cost-center: CC-1234`
- **Business unit**: `business-unit: core`, `business-unit: growth`
- **Geographic region**: `region: us-east-1`, `region: eu-west-1`
- **Kubernetes-style labels**: `app.kubernetes.io/managed-by: terraform`

See `clustersettings-cluster-labels.yaml` for complete examples.

## Profile Types

### Pricing Profiles
Control how costs are calculated for your cluster.

Optional field for any pricing profile:
- `global_discount` - Applies a single discount percent to on-demand resource prices for any pricing profile type (not applied to DoiT pricing profiles). Discount applies only when `start_date` is provided and valid.
  - `percentage` - Discount percent (0-100) applied to on-demand resource prices only.
  - `start_date` - ISO date (yyyy-mm-dd) when the discount starts; if missing or invalid, the discount is not applied. Changing this date does not automatically update past reports; contact support if historical data needs recalculation.

**Types:**
- `custom` - Define custom pricing per instance type
  - `instanceType`: The name of the instance that is given by the provider (e.g., c5.large, m5.xlarge)
  - `memGBHourPrice`: Indicates the price ($) of 1 GB of memory per hour
  - `cpuCoreHourPrice`: Indicates the price ($) of 1 core per hour
  - `nodeHourPrice`: Indicates the price ($) of a node per hour
- `aws_cur` - AWS Cost and Usage Report integration
  - Authentication Method 1 (Recommended): IAM Role
    - `role_arn`: The Amazon Resource Name (ARN) associated with the role possessing the necessary credentials to execute calls on your behalf
    - `aws_external_id`: The ID for cross-account access in AWS Identity and Access Management (IAM). A unique, user-defined string that ensures only trusted third-party entities can assume a specific role
  - Authentication Method 2 (Alternative): IAM User
    - `access_key_id`: AWS access key ID (via `access_key_id` in CRD)
    - `secret_access_key`: AWS secret access key (via `secret_access_key_from` secret reference in CRD)
  - Configuration fields:
    - `athena_database`: Name of the database that was created during the Athena setup
    - `athena_region`: AWS region where Athena is running
    - `athena_result_bucket`: S3 bucket where Athena stores query results
    - `athena_table`: Name of the table that was created on the Athena setup
    - `aws_account_id`: AWS account where cluster is running (NOT the AWS billing account ID)
  - Full guide: https://docs.perfectscale.io/cloud-billing-integration/connecting-aws-cur
- `gcp_billing` - GCP BigQuery billing export integration
- `azure_billing` - Azure billing integration

### Integration Profiles
Configure external systems for notifications and monitoring.

**Types:**
- `slack` - Slack notifications
  - `slack_token`: A mandatory field used to permit PerfectScale to interact with your Slack (via `slack_token_from` secret reference in CRD)
    - Setup: Create an app at https://api.slack.com/apps
    - Required scopes: chat:write.public, chat:write, channels:read, conversations.list
  - `channel`: Slack channel name that indicates where to receive PerfectScale alerts
  - `routings`: Optional field allows alerts to be sent to different Slack channels for different workloads in a cluster
- `teams` - Microsoft Teams notifications
  - `webhook_url`: A mandatory field used to permit PerfectScale to interact with your Teams (via `webhook_url_from` secret reference in CRD)
    - Setup: Go to Apps at https://teams.microsoft.com/, add Incoming Webhook, and connect to a specific channel
  - `routings`: Optional field allows alerts to be sent for specific alert types
- `jira` - Jira ticketing
- `datadog` - Datadog monitoring
- `observability` - Custom observability platform
  - Setup: Go to https://github.com/perfectscale-io/observability, download either the Grafana or DataDog dashboard, import into your instances, and copy the dashboard link

### Resiliency Alerts Profiles
Configure workload health and resiliency alerts. **No type field required.**

### Podfit Labels Profiles
Configure which labels are displayed in the PodFit view. **No type field required.**

### Customization Profiles
Configure custom workload labels. **No type field required.**

**Fields:**
- `workload_labels`: Defines labels that can be applied to Kubernetes resources (pods, deployments, or stateful sets) to identify and manage workloads within a cluster
- `node.spot_labels`: Identifies spot nodes (key-value pairs)
- `node.node_group_labels`: Identifies the nodes group in a cluster
- `node.architecture_labels`: Specifies the architecture of the node (x86_64, arm64, etc.)
- `node.os_labels`: Specifies the operating system running on a node within the Kubernetes cluster
- `node.instance_type_labels`: Specifies the type or configuration of VMs (instances) within a cloud infrastructure
- `node.region_labels`: Specifies the geographical region where a particular resource is located
- `node.availability_zone_labels`: Specify the availability zone where a particular resource is located
- `ignored_pod_labels`: Defines labels that Kubernetes components should disregard when making pod decisions
- `ignored_node_labels`: Defines labels that Kubernetes components should disregard when making node decisions

**NOTE:** Labels should follow Prometheus conventions. Learn more at: https://prometheus.io/docs/concepts/data_model/#metric-names-and-labels

## Profile Assignment Methods

### Method 1: Reference Existing Profile (refByID)
Reference a profile that was created in the UI:

```yaml
profiles:
  pricing:
    - type: custom
      refByID: "custom-1"  # ID format: {type|class}-N
```

**Note:** Profiles created via CRD are cluster-specific and cannot be referenced by other clusters.

**Important Rules:**
- `refByID` can only reference UI-created profiles (not inline CRD profiles)
- Profile IDs are shown in UI in format {type|class}-N (e.g., jira-1, slack-2, custom-3)
- **IMPORTANT**: Underscores in type/class names are converted to hyphens in IDs:
  - Class `resiliency_alerts` → ID `resiliency-alerts-1`
  - Class `podfit_labels` → ID `podfit-labels-1`
  - Type `aws_cur` → ID `aws-cur-1`
  - Type `gcp_billing` → ID `gcp-billing-1`
  - Type `azure_billing` → ID `azure-billing-1`
- The type field must match the referenced profile's type
- refByID profiles are always assigned (no `assigned` field needed)
- If the referenced profile doesn't exist, the assignment won't happen
- If the referenced profile is updated in UI, changes propagate to referencing clusters
- Only ONE profile per class can have `assigned: true` (applies to inline profiles only)

### Method 2: Create Inline Profile
Create a new profile directly in the CRD:

```yaml
profiles:
  pricing:
    - type: custom
      name: "my-inline-profile"
      assigned: true
      value:
        nodeTypes:
          - instanceType: c5.large
            pricing:
              cpuCoreHourPrice: 0.08
              memGBHourPrice: 0.02
```

**Note:** Inline profiles are cluster-specific and only available to the cluster where they are created.

## Using Secrets

You can't specify sensitive data directly in the CRD. Use secret references instead.

```yaml
secret_access_key_from:
  secretKeyRef:
    name: aws-credentials  # Secret name in perfectscale namespace
    key: secret-access-key # Key within the secret
```

## Validation Rules

1. **Singleton:** Only one ClusterSettings resource per cluster
2. **Valid Types:** Profile types must be valid for their class
3. **Name Requirements:**
   - `refByID` cannot be empty if provided
   - Inline profiles must have a `name`
4. **Assignment:** Only one inline profile per class can have `assigned: true`
5. **Type Requirements:**
   - `pricing` and `integrations` MUST have a `type`
   - `resiliency_alerts`, `podfit_labels`, `customization` MUST NOT have a `type`

## Applying Examples

```bash
# Apply all resources (including secrets) in the example file
kubectl apply -f examples/clustersettings-aws-cur.yaml

# View the ClusterSettings
kubectl get clustersettings -n perfectscale

# Describe to see details
kubectl describe clustersettings cluster-settings-main -n perfectscale

# Check logs for processing status
kubectl logs -n perfectscale -l app=perfectscale-exporter --tail=100
```

## Deleting Configuration

When you delete the ClusterSettings resource, the cluster returns to having no profiles (or default profiles):

```bash
kubectl delete clustersettings cluster-settings-main -n perfectscale
```

## Documentation Links

All profile types are documented in detail:

### Pricing
- **Custom Pricing**: https://docs.perfectscale.io/customize-workflow/pricing/custom-pricing-configuration
- **AWS CUR**: https://docs.perfectscale.io/cloud-billing-integration/connecting-aws-cur
- **GCP Billing**: https://docs.perfectscale.io/customize-workflow/pricing/gcp-cloud-billing-configuration
- **Azure Billing**: https://docs.perfectscale.io/cloud-billing-integration/connecting-azure-cost-management

### Integrations
- **Slack**: https://docs.perfectscale.io/customize-workflow/communication-and-messaging/slack-integration
- **Teams**: https://docs.perfectscale.io/customize-workflow/communication-and-messaging/ms-teams-integration
- **Jira**: https://docs.perfectscale.io/customizations/ticketing-and-bug-tracking
- **Datadog**: https://docs.perfectscale.io/customize-workflow/communication-and-messaging/datadog-alerts-integration
- **Observability**: https://docs.perfectscale.io/customize-workflow/observability

### Customizations
- **Label Customizations**: https://docs.perfectscale.io/customizations/label-customizations
- **PodFit Labels**: https://docs.perfectscale.io/customize-workflow/podfit-labels
- **Resiliency Alerts**: https://docs.perfectscale.io/customize-workflow/alerting/resiliency-alerts

## Troubleshooting

### CRD Creation Failed
- Check if ClusterSettings already exists: `kubectl get clustersettings -n perfectscale`
- Review logs: `kubectl logs -n perfectscale -l app=perfectscale-exporter`

### Profile Not Applied
- Check logs for sync errors
- Verify secrets exist: `kubectl get secrets -n perfectscale`
- Check profile format matches the type

### Secret Not Found
- Verify secret exists: `kubectl get secret <secret-name> -n perfectscale`
- Ensure secret is in `perfectscale` namespace
