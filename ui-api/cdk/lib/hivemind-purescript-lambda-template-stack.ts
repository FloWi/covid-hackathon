import * as cdk from '@aws-cdk/core';
import lambda = require('@aws-cdk/aws-lambda');
import path = require('path');
import apigateway = require('@aws-cdk/aws-apigateway');

export class HivemindPurescriptLambdaTemplateStack extends cdk.Stack {
  constructor(scope: cdk.Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const fn = new lambda.Function(this, 'covid-hackathon-ui-api-lambda', {
      runtime: lambda.Runtime.NODEJS_12_X,
      handler: 'index.handler',
      code: lambda.Code.fromAsset("../lambda.zip"),
    });

    const api = new apigateway.LambdaRestApi(this, 'covid-hackathon-ui-api-gateway', {
      handler: fn,
      proxy: false,
      deployOptions: {
        loggingLevel: apigateway.MethodLoggingLevel.INFO,
        dataTraceEnabled: true
      }
    });

    const sms = api.root.addResource('api');
    sms.addMethod('GET');  // GET /items
    sms.addMethod('POST'); // POST /items

  }
}
