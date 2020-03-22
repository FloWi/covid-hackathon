"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const cdk = require("@aws-cdk/core");
const lambda = require("@aws-cdk/aws-lambda");
const apigateway = require("@aws-cdk/aws-apigateway");
const ec2 = require("@aws-cdk/aws-ec2");
const iam = require("@aws-cdk/aws-iam");
class HivemindPurescriptLambdaTemplateStack extends cdk.Stack {
    constructor(scope, id, props) {
        super(scope, id, props);
        const vpc = ec2.Vpc.fromLookup(this, "my-vpc", {
            vpcId: 'vpc-0b0b036cf05edd0b6'
        });
        const sg = new ec2.SecurityGroup(this, 'lambda-security-group', {
            vpc,
            description: "all outbound",
            allowAllOutbound: true
        });
        sg.addIngressRule(ec2.Peer.anyIpv4(), ec2.Port.allTraffic(), "allow all traffic");
        const fn = new lambda.Function(this, 'covid-hackathon-ui-api-lambda', {
            runtime: lambda.Runtime.NODEJS_12_X,
            handler: 'index.handler',
            code: lambda.Code.fromAsset("../lambda.zip"),
            vpc: vpc
        });
        const policyStatement = new iam.PolicyStatement();
        policyStatement.addAllResources();
        policyStatement.addActions("es:*");
        fn.addToRolePolicy(policyStatement);
        const api = new apigateway.LambdaRestApi(this, 'covid-hackathon-ui-api-gateway', {
            handler: fn,
            proxy: false,
            deployOptions: {
                loggingLevel: apigateway.MethodLoggingLevel.INFO,
                dataTraceEnabled: true
            },
            defaultCorsPreflightOptions: {
                allowOrigins: apigateway.Cors.ALL_ORIGINS,
                allowMethods: apigateway.Cors.ALL_METHODS // this is also the default
            }
        });
        const sms = api.root.addResource('api');
        sms.addMethod('GET'); // GET /items
        sms.addMethod('POST'); // POST /items
    }
}
exports.HivemindPurescriptLambdaTemplateStack = HivemindPurescriptLambdaTemplateStack;
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiaGl2ZW1pbmQtcHVyZXNjcmlwdC1sYW1iZGEtdGVtcGxhdGUtc3RhY2suanMiLCJzb3VyY2VSb290IjoiIiwic291cmNlcyI6WyJoaXZlbWluZC1wdXJlc2NyaXB0LWxhbWJkYS10ZW1wbGF0ZS1zdGFjay50cyJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiOztBQUFBLHFDQUFxQztBQUNyQyw4Q0FBK0M7QUFFL0Msc0RBQXVEO0FBQ3ZELHdDQUF5QztBQUN6Qyx3Q0FBdUM7QUFHdkMsTUFBYSxxQ0FBc0MsU0FBUSxHQUFHLENBQUMsS0FBSztJQUNsRSxZQUFZLEtBQW9CLEVBQUUsRUFBVSxFQUFFLEtBQXNCO1FBQ2xFLEtBQUssQ0FBQyxLQUFLLEVBQUUsRUFBRSxFQUFFLEtBQUssQ0FBQyxDQUFDO1FBRXhCLE1BQU0sR0FBRyxHQUFHLEdBQUcsQ0FBQyxHQUFHLENBQUMsVUFBVSxDQUFDLElBQUksRUFBRSxRQUFRLEVBQUU7WUFDN0MsS0FBSyxFQUFFLHVCQUF1QjtTQUMvQixDQUFDLENBQUM7UUFFSCxNQUFNLEVBQUUsR0FBRyxJQUFJLEdBQUcsQ0FBQyxhQUFhLENBQUMsSUFBSSxFQUFFLHVCQUF1QixFQUFFO1lBQzlELEdBQUc7WUFDSCxXQUFXLEVBQUUsY0FBYztZQUMzQixnQkFBZ0IsRUFBRSxJQUFJO1NBQ3ZCLENBQUMsQ0FBQTtRQUVGLEVBQUUsQ0FBQyxjQUFjLENBQUMsR0FBRyxDQUFDLElBQUksQ0FBQyxPQUFPLEVBQUUsRUFBRSxHQUFHLENBQUMsSUFBSSxDQUFDLFVBQVUsRUFBRSxFQUFFLG1CQUFtQixDQUFDLENBQUE7UUFFakYsTUFBTSxFQUFFLEdBQUcsSUFBSSxNQUFNLENBQUMsUUFBUSxDQUFDLElBQUksRUFBRSwrQkFBK0IsRUFBRTtZQUNwRSxPQUFPLEVBQUUsTUFBTSxDQUFDLE9BQU8sQ0FBQyxXQUFXO1lBQ25DLE9BQU8sRUFBRSxlQUFlO1lBQ3hCLElBQUksRUFBRSxNQUFNLENBQUMsSUFBSSxDQUFDLFNBQVMsQ0FBQyxlQUFlLENBQUM7WUFDNUMsR0FBRyxFQUFFLEdBQUc7U0FDVCxDQUFDLENBQUM7UUFFSCxNQUFNLGVBQWUsR0FBRyxJQUFJLEdBQUcsQ0FBQyxlQUFlLEVBQUUsQ0FBQTtRQUNqRCxlQUFlLENBQUMsZUFBZSxFQUFFLENBQUE7UUFDakMsZUFBZSxDQUFDLFVBQVUsQ0FBQyxNQUFNLENBQUMsQ0FBQTtRQUVsQyxFQUFFLENBQUMsZUFBZSxDQUFDLGVBQWUsQ0FBQyxDQUFBO1FBR25DLE1BQU0sR0FBRyxHQUFHLElBQUksVUFBVSxDQUFDLGFBQWEsQ0FBQyxJQUFJLEVBQUUsZ0NBQWdDLEVBQUU7WUFDL0UsT0FBTyxFQUFFLEVBQUU7WUFDWCxLQUFLLEVBQUUsS0FBSztZQUNaLGFBQWEsRUFBRTtnQkFDYixZQUFZLEVBQUUsVUFBVSxDQUFDLGtCQUFrQixDQUFDLElBQUk7Z0JBQ2hELGdCQUFnQixFQUFFLElBQUk7YUFDdkI7WUFDRCwyQkFBMkIsRUFBRTtnQkFDM0IsWUFBWSxFQUFFLFVBQVUsQ0FBQyxJQUFJLENBQUMsV0FBVztnQkFDekMsWUFBWSxFQUFFLFVBQVUsQ0FBQyxJQUFJLENBQUMsV0FBVyxDQUFDLDJCQUEyQjthQUN0RTtTQUNGLENBQUMsQ0FBQztRQUVILE1BQU0sR0FBRyxHQUFHLEdBQUcsQ0FBQyxJQUFJLENBQUMsV0FBVyxDQUFDLEtBQUssQ0FBQyxDQUFDO1FBQ3hDLEdBQUcsQ0FBQyxTQUFTLENBQUMsS0FBSyxDQUFDLENBQUMsQ0FBRSxhQUFhO1FBQ3BDLEdBQUcsQ0FBQyxTQUFTLENBQUMsTUFBTSxDQUFDLENBQUMsQ0FBQyxjQUFjO0lBRXZDLENBQUM7Q0FDRjtBQWhERCxzRkFnREMiLCJzb3VyY2VzQ29udGVudCI6WyJpbXBvcnQgKiBhcyBjZGsgZnJvbSAnQGF3cy1jZGsvY29yZSc7XG5pbXBvcnQgbGFtYmRhID0gcmVxdWlyZSgnQGF3cy1jZGsvYXdzLWxhbWJkYScpO1xuaW1wb3J0IHBhdGggPSByZXF1aXJlKCdwYXRoJyk7XG5pbXBvcnQgYXBpZ2F0ZXdheSA9IHJlcXVpcmUoJ0Bhd3MtY2RrL2F3cy1hcGlnYXRld2F5Jyk7XG5pbXBvcnQgZWMyID0gcmVxdWlyZSgnQGF3cy1jZGsvYXdzLWVjMicpO1xuaW1wb3J0ICogYXMgaWFtIGZyb20gJ0Bhd3MtY2RrL2F3cy1pYW0nXG5cblxuZXhwb3J0IGNsYXNzIEhpdmVtaW5kUHVyZXNjcmlwdExhbWJkYVRlbXBsYXRlU3RhY2sgZXh0ZW5kcyBjZGsuU3RhY2sge1xuICBjb25zdHJ1Y3RvcihzY29wZTogY2RrLkNvbnN0cnVjdCwgaWQ6IHN0cmluZywgcHJvcHM/OiBjZGsuU3RhY2tQcm9wcykge1xuICAgIHN1cGVyKHNjb3BlLCBpZCwgcHJvcHMpO1xuXG4gICAgY29uc3QgdnBjID0gZWMyLlZwYy5mcm9tTG9va3VwKHRoaXMsIFwibXktdnBjXCIsIHtcbiAgICAgIHZwY0lkOiAndnBjLTBiMGIwMzZjZjA1ZWRkMGI2J1xuICAgIH0pO1xuXG4gICAgY29uc3Qgc2cgPSBuZXcgZWMyLlNlY3VyaXR5R3JvdXAodGhpcywgJ2xhbWJkYS1zZWN1cml0eS1ncm91cCcsIHtcbiAgICAgIHZwYyxcbiAgICAgIGRlc2NyaXB0aW9uOiBcImFsbCBvdXRib3VuZFwiLFxuICAgICAgYWxsb3dBbGxPdXRib3VuZDogdHJ1ZVxuICAgIH0pXG5cbiAgICBzZy5hZGRJbmdyZXNzUnVsZShlYzIuUGVlci5hbnlJcHY0KCksIGVjMi5Qb3J0LmFsbFRyYWZmaWMoKSwgXCJhbGxvdyBhbGwgdHJhZmZpY1wiKVxuXG4gICAgY29uc3QgZm4gPSBuZXcgbGFtYmRhLkZ1bmN0aW9uKHRoaXMsICdjb3ZpZC1oYWNrYXRob24tdWktYXBpLWxhbWJkYScsIHtcbiAgICAgIHJ1bnRpbWU6IGxhbWJkYS5SdW50aW1lLk5PREVKU18xMl9YLFxuICAgICAgaGFuZGxlcjogJ2luZGV4LmhhbmRsZXInLFxuICAgICAgY29kZTogbGFtYmRhLkNvZGUuZnJvbUFzc2V0KFwiLi4vbGFtYmRhLnppcFwiKSxcbiAgICAgIHZwYzogdnBjXG4gICAgfSk7XG5cbiAgICBjb25zdCBwb2xpY3lTdGF0ZW1lbnQgPSBuZXcgaWFtLlBvbGljeVN0YXRlbWVudCgpXG4gICAgcG9saWN5U3RhdGVtZW50LmFkZEFsbFJlc291cmNlcygpXG4gICAgcG9saWN5U3RhdGVtZW50LmFkZEFjdGlvbnMoXCJlczoqXCIpXG5cbiAgICBmbi5hZGRUb1JvbGVQb2xpY3kocG9saWN5U3RhdGVtZW50KVxuXG5cbiAgICBjb25zdCBhcGkgPSBuZXcgYXBpZ2F0ZXdheS5MYW1iZGFSZXN0QXBpKHRoaXMsICdjb3ZpZC1oYWNrYXRob24tdWktYXBpLWdhdGV3YXknLCB7XG4gICAgICBoYW5kbGVyOiBmbixcbiAgICAgIHByb3h5OiBmYWxzZSxcbiAgICAgIGRlcGxveU9wdGlvbnM6IHtcbiAgICAgICAgbG9nZ2luZ0xldmVsOiBhcGlnYXRld2F5Lk1ldGhvZExvZ2dpbmdMZXZlbC5JTkZPLFxuICAgICAgICBkYXRhVHJhY2VFbmFibGVkOiB0cnVlXG4gICAgICB9LFxuICAgICAgZGVmYXVsdENvcnNQcmVmbGlnaHRPcHRpb25zOiB7XG4gICAgICAgIGFsbG93T3JpZ2luczogYXBpZ2F0ZXdheS5Db3JzLkFMTF9PUklHSU5TLFxuICAgICAgICBhbGxvd01ldGhvZHM6IGFwaWdhdGV3YXkuQ29ycy5BTExfTUVUSE9EUyAvLyB0aGlzIGlzIGFsc28gdGhlIGRlZmF1bHRcbiAgICAgIH1cbiAgICB9KTtcblxuICAgIGNvbnN0IHNtcyA9IGFwaS5yb290LmFkZFJlc291cmNlKCdhcGknKTtcbiAgICBzbXMuYWRkTWV0aG9kKCdHRVQnKTsgIC8vIEdFVCAvaXRlbXNcbiAgICBzbXMuYWRkTWV0aG9kKCdQT1NUJyk7IC8vIFBPU1QgL2l0ZW1zXG5cbiAgfVxufVxuIl19