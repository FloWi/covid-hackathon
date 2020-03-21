import * as cdk from '@aws-cdk/core';
import * as s3 from '@aws-cdk/aws-s3';
import * as assets from '@aws-cdk/aws-s3-assets';
import * as s3deploy from '@aws-cdk/aws-s3-deployment';

export class CovidUiStack extends cdk.Stack {
  constructor(scope: cdk.Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const accessLogsBucket = new s3.Bucket(this, 'AccessLogsBucket');

    const bucket = new s3.Bucket(this, 'ui-pubic-bucket', {
      //encryption: s3.BucketEncryption.KMS,
      serverAccessLogsBucket: accessLogsBucket,
      publicReadAccess: true,
      websiteIndexDocument: 'index.html',
      bucketName: "de.hivemind-vs-covid",
      // TODO: Restrict me
      cors: []
    });

    const asset = s3deploy.Source.asset('../ui.zip')
    
    const deployment = new s3deploy.BucketDeployment(this, 'covid-website', {
      sources: [asset],
      destinationBucket: bucket,
      //destinationKeyPrefix: 'public' // optional prefix in destination bucket
    });

  }
}


/*
Filling the bucket as part of deployment
To put files into a bucket as part of a deployment (for example, to host a website), see the @aws-cdk/aws-s3-deployment package, which provides a resource that can do just that.

*/