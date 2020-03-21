import * as cdk from "@aws-cdk/core";
import * as es from "@aws-cdk/aws-elasticsearch";
import * as ec2 from '@aws-cdk/aws-ec2';
import { BastionHostLinux, Peer } from "@aws-cdk/aws-ec2";


export class InfrastructureStack extends cdk.Stack {
  constructor(scope: cdk.Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const vpc: ec2.Vpc = new ec2.Vpc(this, 'covid-vpc', {
      cidr: '178.22.0.0/20',
    });


    const privateSubnetIds = vpc.privateSubnets.map((subnet) => subnet.subnetId);
    const defaultSg = ec2.SecurityGroup.fromSecurityGroupId(this, 'default-sg', vpc.vpcDefaultSecurityGroup);

    const sg = new ec2.SecurityGroup(this, 'elastic-search', {
      vpc,
      description: "allow access to es",
      allowAllOutbound: true
    })

    sg.addIngressRule(ec2.Peer.anyIpv4(), ec2.Port.allTraffic(), "allow all traffic")

    // The code that defines your stack goes here
    const securityGroupIds = [defaultSg, sg].map((sg) => sg.securityGroupId)
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
          securityGroupIds: securityGroupIds,
          subnetIds: [privateSubnetIds[0]] //although it's an array, it requires only one subnet
        },
        accessPolicies: {
          "Version": "2012-10-17",
          "Statement": [
            {
              "Effect": "Allow",
              "Principal": {
                "AWS": "*"
              },
              "Action": [
                "es:*"
              ],
              "Resource": "*"
            }
          ]
        }
      }
    )

    const bastion = new BastionHostLinux(this, "bastion", {
      vpc: vpc,
      instanceName: 'covid-bastion',
      subnetSelection: { subnetType: ec2.SubnetType.PUBLIC }
    })

    bastion.allowSshAccessFrom(Peer.anyIpv4())

  }
}

/*
import autoscaling = require('@aws-cdk/aws-autoscaling');
import ec2 = require('@aws-cdk/aws-ec2');
import elb = require('@aws-cdk/aws-elasticloadbalancing');
import cdk = require('@aws-cdk/core');

class LoadBalancerStack extends cdk.Stack {
  constructor(app: cdk.App, id: string) {
    super(app, id);

    const vpc = new ec2.Vpc(this, 'VPC');

    const asg = new autoscaling.AutoScalingGroup(this, 'ASG', {
      vpc,
      instanceType: ec2.InstanceType.of(ec2.InstanceClass.T2, ec2.InstanceSize.MICRO),
      machineImage: new ec2.AmazonLinuxImage(),
    });

    const lb = new elb.LoadBalancer(this, 'LB', {
      vpc,
      internetFacing: true,
      healthCheck: {
        port: 80
      },
    });

    lb.addTarget(asg);
    const listener = lb.addListener({ externalPort: 80 });

    listener.connections.allowDefaultPortFromAnyIpv4('Open to the world');
  }
}
*/

/*
aws ec2-instance-connect send-ssh-public-key --instance-id i-04932a6a6696e56f0 --availability-zone eu-west-1a --instance-os-user ec2-user --ssh-public-key file:///Users/florian_witteler/programming/hivemind/.ssh/hivemind/id.rsa.pub
*/
