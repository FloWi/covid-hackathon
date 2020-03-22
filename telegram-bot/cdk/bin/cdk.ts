import * as cdk from '@aws-cdk/core';
import lambda = require('@aws-cdk/aws-lambda');
import path = require('path');
import apigateway = require('@aws-cdk/aws-apigateway');
import ec2 = require('@aws-cdk/aws-ec2');
import * as iam from '@aws-cdk/aws-iam'
import dynamodb = require('@aws-cdk/aws-dynamodb');


export class HivemindPurescriptLambdaTemplateStack extends cdk.Stack {
    constructor(scope: cdk.Construct, id: string, props?: cdk.StackProps) {
        super(scope, id, props);

        // VPC
        const vpc = ec2.Vpc.fromLookup(this, "my-vpc", {
            vpcId: 'vpc-0b0b036cf05edd0b6'
        });

        const sg = new ec2.SecurityGroup(this, 'covid-hackathon-chatbot-lambda-security-group', {
            vpc,
            description: "all outbound",
            allowAllOutbound: true
        })

        sg.addIngressRule(ec2.Peer.anyIpv4(), ec2.Port.allTraffic(), "allow all traffic")


        // Lambda Function
        const fn = new lambda.Function(this, 'covid-hackathon-chatbot-lambda', {
            runtime: lambda.Runtime.NODEJS_12_X,
            handler: 'index.handler',
            code: lambda.Code.fromAsset("../lambda.zip"),
            vpc: vpc,
            securityGroups: [sg],
            environment: {
                "VOUCHER_LOCATION_REPO_ENDPOINT_URL": "???",
                "CHATBOT_HISTORY_ELASTICSEARCH_ENDPOINT_URL": "???"
            }
        });

        // Policy
        const policyStatement = new iam.PolicyStatement()
        policyStatement.addAllResources()
        policyStatement.addActions("es:*")

        fn.addToRolePolicy(policyStatement)

        // API
        const api = new apigateway.LambdaRestApi(this, 'covid-hackathon-chatbot-api', {
            handler: fn,
            proxy: false,
            deployOptions: {
                loggingLevel: apigateway.MethodLoggingLevel.INFO,
                dataTraceEnabled: true
            }
        });

        const sms = api.root.addResource('sms');
        sms.addMethod('GET');  // GET /items
        sms.addMethod('POST'); // POST /items
    }
}
