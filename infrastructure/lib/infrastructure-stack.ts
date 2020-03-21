import * as cdk from "@aws-cdk/core";
import * as es from "@aws-cdk/aws-elasticsearch";
import ec2 = require('@aws-cdk/aws-ec2');

export class InfrastructureStack extends cdk.Stack {
  constructor(scope: cdk.Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const vpc: ec2.Vpc = new ec2.Vpc(this, 'covid-vpc', {
      cidr: '178.22.0.0/20',
    });

    const privateSubnetIds = vpc.privateSubnets.map((subnet) => subnet.subnetId);
    const defaultSg = ec2.SecurityGroup.fromSecurityGroupId(this, 'default-sg', vpc.vpcDefaultSecurityGroup);

    // The code that defines your stack goes here

    const elasticSearch = new es.CfnDomain(this, "covid-elasticsearch-vpc",
      {
        domainName: 'covid-elasticsearch',
        elasticsearchVersion: '6.0',
        elasticsearchClusterConfig: {
          instanceCount: 1,
          instanceType: 't2.small.elasticsearch'
        },
        ebsOptions: {
          ebsEnabled: true,
          volumeType: 'standard',
          volumeSize: 10
        },
        vpcOptions: {
          securityGroupIds: [defaultSg.securityGroupId],
          subnetIds: privateSubnetIds
        }
        //FIXME: restrict access
        // accessPolicies: {
        //   "Version": "2012-10-17",
        //   "Statement": [
        //     {
        //       "Effect": "Allow",
        //       "Principal": { "AWS": "*" },
        //       "Action": ["es:*"],

        //     }]
        // }
      }
    );
  }
}

/*
aws es update-elasticsearch-domain-config --domain-name mylogs --access-policies '
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:root"
      },
      "Action":"es:*",
      "Resource":"arn:aws:es:us-east-1:555555555555:domain/index1/*"
    }
  ] }'
*/

/*

aws es create-elasticsearch-domain

--domain-name movies
 --elasticsearch-version 6.0
 --elasticsearch-cluster-config
   InstanceType=t2.small.elasticsearch,
   InstanceCount=1
 --ebs-options EBSEnabled=true,VolumeType=standard,VolumeSize=10
 --access-policies '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"AWS":"*"},"Action":["es:*"],"Condition":{"IpAddress":{"aws:SourceIp":["your_ip_address"]}}}]}'


 */
