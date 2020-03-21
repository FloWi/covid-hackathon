# Template for a simple purescript aws lambda

## Development
```
# Build your application
npx spago build
```
This creates the handler. To invoke it locally: 
```
# bundle app
npm run bundle 

# then run it
node -e "require('./index.js').handler({\"name\":\"Jan\"}, null)"
# or 
node ./test.js
```

## Deployment
```
npm run bundle
npm run zip
cd cdk/
cdk deploy --profile <<your profile>>
```