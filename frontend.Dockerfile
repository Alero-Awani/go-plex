FROM node:18-alpine as BUILD_IMAGE

WORKDIR /app

# copy package.json
COPY package.json vite.config.ts ./


# Install all the packages 
RUN npm i --no-optional 

RUN npm install typescript


# Copy all the remaining files 
COPY . .

## EXPOSE [Port you mentioned in the vite.config file]

EXPOSE 5173

CMD ["npm", "run", "dev"]


# Implement Multi-stage build

FROM node:18-alpine as PRODUCTION_IMAGE

WORKDIR /app

COPY --from=BUILD_IMAGE /app .

EXPOSE 5173

CMD ["npm", "run", "dev"]