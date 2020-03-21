"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const cdk = require("@aws-cdk/core");
const lambda = require("@aws-cdk/aws-lambda");
const apigateway = require("@aws-cdk/aws-apigateway");
class HivemindPurescriptLambdaTemplateStack extends cdk.Stack {
    constructor(scope, id, props) {
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
        sms.addMethod('GET'); // GET /items
        sms.addMethod('POST'); // POST /items
    }
}
exports.HivemindPurescriptLambdaTemplateStack = HivemindPurescriptLambdaTemplateStack;
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiaGl2ZW1pbmQtcHVyZXNjcmlwdC1sYW1iZGEtdGVtcGxhdGUtc3RhY2suanMiLCJzb3VyY2VSb290IjoiIiwic291cmNlcyI6WyJoaXZlbWluZC1wdXJlc2NyaXB0LWxhbWJkYS10ZW1wbGF0ZS1zdGFjay50cyJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiOztBQUFBLHFDQUFxQztBQUNyQyw4Q0FBK0M7QUFFL0Msc0RBQXVEO0FBRXZELE1BQWEscUNBQXNDLFNBQVEsR0FBRyxDQUFDLEtBQUs7SUFDbEUsWUFBWSxLQUFvQixFQUFFLEVBQVUsRUFBRSxLQUFzQjtRQUNsRSxLQUFLLENBQUMsS0FBSyxFQUFFLEVBQUUsRUFBRSxLQUFLLENBQUMsQ0FBQztRQUV4QixNQUFNLEVBQUUsR0FBRyxJQUFJLE1BQU0sQ0FBQyxRQUFRLENBQUMsSUFBSSxFQUFFLCtCQUErQixFQUFFO1lBQ3BFLE9BQU8sRUFBRSxNQUFNLENBQUMsT0FBTyxDQUFDLFdBQVc7WUFDbkMsT0FBTyxFQUFFLGVBQWU7WUFDeEIsSUFBSSxFQUFFLE1BQU0sQ0FBQyxJQUFJLENBQUMsU0FBUyxDQUFDLGVBQWUsQ0FBQztTQUM3QyxDQUFDLENBQUM7UUFFSCxNQUFNLEdBQUcsR0FBRyxJQUFJLFVBQVUsQ0FBQyxhQUFhLENBQUMsSUFBSSxFQUFFLGdDQUFnQyxFQUFFO1lBQy9FLE9BQU8sRUFBRSxFQUFFO1lBQ1gsS0FBSyxFQUFFLEtBQUs7WUFDWixhQUFhLEVBQUU7Z0JBQ2IsWUFBWSxFQUFFLFVBQVUsQ0FBQyxrQkFBa0IsQ0FBQyxJQUFJO2dCQUNoRCxnQkFBZ0IsRUFBRSxJQUFJO2FBQ3ZCO1NBQ0YsQ0FBQyxDQUFDO1FBRUgsTUFBTSxHQUFHLEdBQUcsR0FBRyxDQUFDLElBQUksQ0FBQyxXQUFXLENBQUMsS0FBSyxDQUFDLENBQUM7UUFDeEMsR0FBRyxDQUFDLFNBQVMsQ0FBQyxLQUFLLENBQUMsQ0FBQyxDQUFFLGFBQWE7UUFDcEMsR0FBRyxDQUFDLFNBQVMsQ0FBQyxNQUFNLENBQUMsQ0FBQyxDQUFDLGNBQWM7SUFFdkMsQ0FBQztDQUNGO0FBeEJELHNGQXdCQyIsInNvdXJjZXNDb250ZW50IjpbImltcG9ydCAqIGFzIGNkayBmcm9tICdAYXdzLWNkay9jb3JlJztcbmltcG9ydCBsYW1iZGEgPSByZXF1aXJlKCdAYXdzLWNkay9hd3MtbGFtYmRhJyk7XG5pbXBvcnQgcGF0aCA9IHJlcXVpcmUoJ3BhdGgnKTtcbmltcG9ydCBhcGlnYXRld2F5ID0gcmVxdWlyZSgnQGF3cy1jZGsvYXdzLWFwaWdhdGV3YXknKTtcblxuZXhwb3J0IGNsYXNzIEhpdmVtaW5kUHVyZXNjcmlwdExhbWJkYVRlbXBsYXRlU3RhY2sgZXh0ZW5kcyBjZGsuU3RhY2sge1xuICBjb25zdHJ1Y3RvcihzY29wZTogY2RrLkNvbnN0cnVjdCwgaWQ6IHN0cmluZywgcHJvcHM/OiBjZGsuU3RhY2tQcm9wcykge1xuICAgIHN1cGVyKHNjb3BlLCBpZCwgcHJvcHMpO1xuXG4gICAgY29uc3QgZm4gPSBuZXcgbGFtYmRhLkZ1bmN0aW9uKHRoaXMsICdjb3ZpZC1oYWNrYXRob24tdWktYXBpLWxhbWJkYScsIHtcbiAgICAgIHJ1bnRpbWU6IGxhbWJkYS5SdW50aW1lLk5PREVKU18xMl9YLFxuICAgICAgaGFuZGxlcjogJ2luZGV4LmhhbmRsZXInLFxuICAgICAgY29kZTogbGFtYmRhLkNvZGUuZnJvbUFzc2V0KFwiLi4vbGFtYmRhLnppcFwiKSxcbiAgICB9KTtcblxuICAgIGNvbnN0IGFwaSA9IG5ldyBhcGlnYXRld2F5LkxhbWJkYVJlc3RBcGkodGhpcywgJ2NvdmlkLWhhY2thdGhvbi11aS1hcGktZ2F0ZXdheScsIHtcbiAgICAgIGhhbmRsZXI6IGZuLFxuICAgICAgcHJveHk6IGZhbHNlLFxuICAgICAgZGVwbG95T3B0aW9uczoge1xuICAgICAgICBsb2dnaW5nTGV2ZWw6IGFwaWdhdGV3YXkuTWV0aG9kTG9nZ2luZ0xldmVsLklORk8sXG4gICAgICAgIGRhdGFUcmFjZUVuYWJsZWQ6IHRydWVcbiAgICAgIH1cbiAgICB9KTtcblxuICAgIGNvbnN0IHNtcyA9IGFwaS5yb290LmFkZFJlc291cmNlKCdhcGknKTtcbiAgICBzbXMuYWRkTWV0aG9kKCdHRVQnKTsgIC8vIEdFVCAvaXRlbXNcbiAgICBzbXMuYWRkTWV0aG9kKCdQT1NUJyk7IC8vIFBPU1QgL2l0ZW1zXG5cbiAgfVxufVxuIl19