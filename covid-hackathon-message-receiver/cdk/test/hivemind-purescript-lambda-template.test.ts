import { expect as expectCDK, matchTemplate, MatchStyle } from '@aws-cdk/assert';
import * as cdk from '@aws-cdk/core';
import HivemindPurescriptLambdaTemplate = require('../lib/hivemind-purescript-lambda-template-stack');

test('Empty Stack', () => {
    const app = new cdk.App();
    // WHEN
    const stack = new HivemindPurescriptLambdaTemplate.HivemindPurescriptLambdaTemplateStack(app, 'MyTestStack');
    // THEN
    expectCDK(stack).to(matchTemplate({
      "Resources": {}
    }, MatchStyle.EXACT))
});
