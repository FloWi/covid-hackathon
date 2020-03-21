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

    const elasticSearch = new es.CfnDomain(this, "covid-es-in-vpc",
      {
        domainName: 'covid-es-in-vpc',
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
          subnetIds: [privateSubnetIds[0]] //although it's an array, it requires only one subnet
        }
      }
    );
  }
}

