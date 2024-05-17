### Get the application to work locally 

1. `npm install` - This installs all the things in the package.json file
2. `npm run dev`
3.  To run the golang backend, make sure .env file is created, then `cd src/api` run `./api`
4. Set up postgres database with docker `docker compose up`

### Package React app with docker
1. Build docker image `docker build -t vite-react-app:latest .`

update vite.config.ts to support docker 
```ts
export default {
  server: {
    host: true,
    proxy: {
      "/api": {
        target: "http://backend:8080",
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, ""),
      },
    },
  },
  },
};
```
change the target from `localhost` to backend when running with docker-compose, since you are running the backend and frontend within Docker containers, and they are all part of the same Docker network (learning), you can access the backend service (backend) from the frontend service (frontend) using the service name defined in the Docker Compose file.

changed dev in `package.json` to `"dev":"vite"`

2. `docker run -p 5173:5173 vite-react-app`

3. 
Build Golang docker image `docker build -t go-api:latest .`
Run golang app `docker run -p 8080:8080 go-api --env-file .env`

put them in a docker compose file and run using `docker compose up --build`



- tag image before pushing to docker hub 
docker tag b1912f06500e aleroawani/go-plex-frontend:latest
docker push aleroawani/go-plex-frontend:latest


POSTGRES MANIFEST 
1. kubectl create configmap postgres-data-config --from-file=./postgres-data

2. kubectl create configmap create-tables-sql-config --from-file=./db/create_tables.sql


TODO 
1. reduce docker image size using multistage build 

