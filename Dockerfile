FROM node

RUN npm install -g --force npx
RUN npm install -g --unsafe-perm purescript
RUN npm install -g --unsafe-perm spago