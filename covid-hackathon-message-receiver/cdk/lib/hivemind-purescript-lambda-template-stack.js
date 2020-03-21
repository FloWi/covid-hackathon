"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const cdk = require("@aws-cdk/core");
const lambda = require("@aws-cdk/aws-lambda");
const apigateway = require("@aws-cdk/aws-apigateway");
class HivemindPurescriptLambdaTemplateStack extends cdk.Stack {
    constructor(scope, id, props) {
        super(scope, id, props);
        const fn = new lambda.Function(this, 'covid-hackathon-message-receiver-lambda', {
            runtime: lambda.Runtime.NODEJS_12_X,
            handler: 'index.handler',
            code: lambda.Code.fromAsset("../lambda.zip"),
        });
        const api = new apigateway.LambdaRestApi(this, 'covid-hackathon-message-receiver-api', {
            handler: fn,
            proxy: false,
            deployOptions: {
                loggingLevel: apigateway.MethodLoggingLevel.INFO,
                dataTraceEnabled: true
            }
        });
        const sms = api.root.addResource('sms');
        sms.addMethod('GET'); // GET /items
        sms.addMethod('POST'); // POST /items
    }
}
exports.HivemindPurescriptLambdaTemplateStack = HivemindPurescriptLambdaTemplateStack;
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiaGl2ZW1pbmQtcHVyZXNjcmlwdC1sYW1iZGEtdGVtcGxhdGUtc3RhY2suanMiLCJzb3VyY2VSb290IjoiIiwic291cmNlcyI6WyJoaXZlbWluZC1wdXJlc2NyaXB0LWxhbWJkYS10ZW1wbGF0ZS1zdGFjay50cyJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiOztBQUFBLHFDQUFxQztBQUNyQyw4Q0FBK0M7QUFFL0Msc0RBQXVEO0FBRXZELE1BQWEscUNBQXNDLFNBQVEsR0FBRyxDQUFDLEtBQUs7SUFDbEUsWUFBWSxLQUFvQixFQUFFLEVBQVUsRUFBRSxLQUFzQjtRQUNsRSxLQUFLLENBQUMsS0FBSyxFQUFFLEVBQUUsRUFBRSxLQUFLLENBQUMsQ0FBQztRQUV4QixNQUFNLEVBQUUsR0FBRyxJQUFJLE1BQU0sQ0FBQyxRQUFRLENBQUMsSUFBSSxFQUFFLHlDQUF5QyxFQUFFO1lBQzlFLE9BQU8sRUFBRSxNQUFNLENBQUMsT0FBTyxDQUFDLFdBQVc7WUFDbkMsT0FBTyxFQUFFLGVBQWU7WUFDeEIsSUFBSSxFQUFFLE1BQU0sQ0FBQyxJQUFJLENBQUMsU0FBUyxDQUFDLGVBQWUsQ0FBQztTQUM3QyxDQUFDLENBQUM7UUFFSCxNQUFNLEdBQUcsR0FBRyxJQUFJLFVBQVUsQ0FBQyxhQUFhLENBQUMsSUFBSSxFQUFFLHNDQUFzQyxFQUFFO1lBQ3JGLE9BQU8sRUFBRSxFQUFFO1lBQ1gsS0FBSyxFQUFFLEtBQUs7WUFDWixhQUFhLEVBQUU7Z0JBQ2IsWUFBWSxFQUFFLFVBQVUsQ0FBQyxrQkFBa0IsQ0FBQyxJQUFJO2dCQUNoRCxnQkFBZ0IsRUFBRSxJQUFJO2FBQ3ZCO1NBQ0YsQ0FBQyxDQUFDO1FBRUgsTUFBTSxHQUFHLEdBQUcsR0FBRyxDQUFDLElBQUksQ0FBQyxXQUFXLENBQUMsS0FBSyxDQUFDLENBQUM7UUFDeEMsR0FBRyxDQUFDLFNBQVMsQ0FBQyxLQUFLLENBQUMsQ0FBQyxDQUFFLGFBQWE7UUFDcEMsR0FBRyxDQUFDLFNBQVMsQ0FBQyxNQUFNLENBQUMsQ0FBQyxDQUFDLGNBQWM7SUFFdkMsQ0FBQztDQUNGO0FBeEJELHNGQXdCQyIsInNvdXJjZXNDb250ZW50IjpbImltcG9ydCAqIGFzIGNkayBmcm9tICdAYXdzLWNkay9jb3JlJztcbmltcG9ydCBsYW1iZGEgPSByZXF1aXJlKCdAYXdzLWNkay9hd3MtbGFtYmRhJyk7XG5pbXBvcnQgcGF0aCA9IHJlcXVpcmUoJ3BhdGgnKTtcbmltcG9ydCBhcGlnYXRld2F5ID0gcmVxdWlyZSgnQGF3cy1jZGsvYXdzLWFwaWdhdGV3YXknKTtcblxuZXhwb3J0IGNsYXNzIEhpdmVtaW5kUHVyZXNjcmlwdExhbWJkYVRlbXBsYXRlU3RhY2sgZXh0ZW5kcyBjZGsuU3RhY2sge1xuICBjb25zdHJ1Y3RvcihzY29wZTogY2RrLkNvbnN0cnVjdCwgaWQ6IHN0cmluZywgcHJvcHM/OiBjZGsuU3RhY2tQcm9wcykge1xuICAgIHN1cGVyKHNjb3BlLCBpZCwgcHJvcHMpO1xuXG4gICAgY29uc3QgZm4gPSBuZXcgbGFtYmRhLkZ1bmN0aW9uKHRoaXMsICdjb3ZpZC1oYWNrYXRob24tbWVzc2FnZS1yZWNlaXZlci1sYW1iZGEnLCB7XG4gICAgICBydW50aW1lOiBsYW1iZGEuUnVudGltZS5OT0RFSlNfMTJfWCxcbiAgICAgIGhhbmRsZXI6ICdpbmRleC5oYW5kbGVyJyxcbiAgICAgIGNvZGU6IGxhbWJkYS5Db2RlLmZyb21Bc3NldChcIi4uL2xhbWJkYS56aXBcIiksXG4gICAgfSk7XG5cbiAgICBjb25zdCBhcGkgPSBuZXcgYXBpZ2F0ZXdheS5MYW1iZGFSZXN0QXBpKHRoaXMsICdjb3ZpZC1oYWNrYXRob24tbWVzc2FnZS1yZWNlaXZlci1hcGknLCB7XG4gICAgICBoYW5kbGVyOiBmbixcbiAgICAgIHByb3h5OiBmYWxzZSxcbiAgICAgIGRlcGxveU9wdGlvbnM6IHtcbiAgICAgICAgbG9nZ2luZ0xldmVsOiBhcGlnYXRld2F5Lk1ldGhvZExvZ2dpbmdMZXZlbC5JTkZPLFxuICAgICAgICBkYXRhVHJhY2VFbmFibGVkOiB0cnVlXG4gICAgICB9XG4gICAgfSk7XG5cbiAgICBjb25zdCBzbXMgPSBhcGkucm9vdC5hZGRSZXNvdXJjZSgnc21zJyk7XG4gICAgc21zLmFkZE1ldGhvZCgnR0VUJyk7ICAvLyBHRVQgL2l0ZW1zXG4gICAgc21zLmFkZE1ldGhvZCgnUE9TVCcpOyAvLyBQT1NUIC9pdGVtc1xuXG4gIH1cbn1cbiJdfQ==