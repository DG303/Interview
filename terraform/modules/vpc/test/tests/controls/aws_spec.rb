# frozen_string_literal: true

# load data from Terraform output
content = inspec.profile.file('terraform.json')
params = JSON.parse(content)
DB_ENGINE = 'mysql'
SUBNET_IDS = params['subnet_ids']['value']
SUBNET_RANGES = params['subnet_ranges']['value']
VPC_ID = params['vpc_id']['value']
SG_ID = params['this_security_group_id']['value']
BASTION_SG_ID = params['bastion_sg_id']['value']
DB_ID = params['this_db_instance_id']['value']
DB_PORT = params['db_port']['value']
IDENTIFIER = "inspec-test-#{DB_ENGINE}"
ENVIRONMENT = 'support'
APP_NAME = "#{IDENTIFIER}-#{ENVIRONMENT}-rds"
SG_NAME = "#{IDENTIFIER}-#{ENVIRONMENT}-security_group"
CLOUD_WATCH_NAMESPACE = 'AWS/RDS'
CLOUD_WATCH_ALARM_CPU_NAME = "#{IDENTIFIER}-#{ENVIRONMENT}-RdsCPUAlarm"
CLOUD_WATCH_CPU_METRIC_NAME = 'CPUUtilization'
CLOUD_WATCH_ALARM_DISK_NAME = "#{IDENTIFIER}-#{ENVIRONMENT}-DiskSpaceAlarm"
CLOUD_WATCH_DISK_METRIC_NAME = 'FreeStorageSpace'
CLOUD_WATCH_ALARM_CONN_NAME = "#{IDENTIFIER}-#{ENVIRONMENT}-HighDbConnectionsAlarm"
CLOUD_WATCH_CONN_METRIC_NAME = 'DatabaseConnections'
CLOUD_WATCH_ALARM_QUEUE_NAME = "#{IDENTIFIER}-#{ENVIRONMENT}-HighDiskQueueDepthAlarm"
CLOUD_WATCH_QUEUE_METRIC_NAME = 'DiskQueueDepth'

# Test SG
describe aws_security_group(SG_ID) do
  it { should exist }
  its('description') { should cmp "#{DB_ID} RDS Security Group" }
  it { should allow_in(port: DB_PORT, protocol: 'tcp', ipv4_range: SUBNET_RANGES.split(',')) }
  it { should allow_in(port: DB_PORT, protocol: 'tcp', security_group: BASTION_SG_ID) }
  its('vpc_id') { should cmp VPC_ID }
  its('tags') { should include('Name'        => SG_NAME) }
  its('tags') { should include('Environment' => ENVIRONMENT) }
end

# Ensure all created subnets were created in the same (and desired) VPC
SUBNET_IDS.each do |subnet_id|
  describe aws_subnet(subnet_id) do
    its('vpc_id') { should cmp VPC_ID }
  end
end

# When given a string, in the module variable subnet_ranges,
#   ensure each CIDR in the string resulted in a matching subnet resource
# Ex. subnet_range = "10.202.223.0/27,10.202.223.32/27,10.202.223.64/27"
# Should result in 3 subnets, one for each CIDR.
# For each CIDR that doesn't have a matching subnet, test will fail for that CIDR
SUBNET_RANGES.split(',').each do |subnet|
  describe.one do
    SUBNET_IDS.each do |subnet_id|
      describe aws_subnet(subnet_id) do
        its('cidr_block') { should cmp subnet }
      end
    end
  end
end

# Test CloudWatch Alarms
describe aws_cloudwatch_alarm(metric_name: CLOUD_WATCH_CPU_METRIC_NAME,
                              metric_namespace: CLOUD_WATCH_NAMESPACE,
                              dimensions: [{ DBInstanceIdentifier: DB_ID }]) do
  it { should exist }
  its('alarm_name') { should eq CLOUD_WATCH_ALARM_CPU_NAME }
  its('alarm_actions') { should_not be_empty }
end

describe aws_cloudwatch_alarm(metric_name: CLOUD_WATCH_DISK_METRIC_NAME,
                              metric_namespace: CLOUD_WATCH_NAMESPACE,
                              dimensions: [{ DBInstanceIdentifier: DB_ID }]) do
  it { should exist }
  its('alarm_name') { should eq CLOUD_WATCH_ALARM_DISK_NAME }
  its('alarm_actions') { should_not be_empty }
end

describe aws_cloudwatch_alarm(metric_name: CLOUD_WATCH_CONN_METRIC_NAME,
                              metric_namespace: CLOUD_WATCH_NAMESPACE,
                              dimensions: [{ DBInstanceIdentifier: DB_ID }]) do
  it { should exist }
  its('alarm_name') { should eq CLOUD_WATCH_ALARM_CONN_NAME }
  its('alarm_actions') { should_not be_empty }
end

describe aws_cloudwatch_alarm(metric_name: CLOUD_WATCH_QUEUE_METRIC_NAME,
                              metric_namespace: CLOUD_WATCH_NAMESPACE,
                              dimensions: [{ DBInstanceIdentifier: DB_ID }]) do
  it { should exist }
  its('alarm_name') { should eq CLOUD_WATCH_ALARM_QUEUE_NAME }
  its('alarm_actions') { should_not be_empty }
end

# Test RDS Instance
describe aws_rds_instance(DB_ID) do
  it { should exist }
  its('engine') { should cmp DB_ENGINE }
  # its ('engine_version') { should cmp '5.6' } # requires knowing minor version
  its('storage_type') { should cmp 'gp2' }
  its('allocated_storage') { should cmp '20' }
  its('master_username') { should cmp 'ADTadmin' }
  its('db_instance_class') { should cmp 'db.m3.medium' }
end
