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
`docker tag b1912f06500e aleroawani/go-plex-frontend:latest`
`docker push aleroawani/go-plex-frontend:latest`


POSTGRES MANIFEST 
- Test postgres container 
- `kubectl exec -it postgres-database-544dc76f54-dd4hj -- psql -h localhost -U postgres --password postgres -p 5432`
- \l, \c goplex , \dt 


TODO 
1. reduce docker image size using multistage build 


REDUCING GOLANG BACKEND IMAGE 
1. Find a specific version for the base image that is the smallest size possible. Go to dockerhub, go through the images and check out the least and a stable version 

-  `docker build -f backend.Dockerfile -t go-backend:1.0.0 .`

2. Remove the unneccessary file and caches 

REDUCING FRONTEND IMAGE 
1. Note that the .dockerignore file is only for the frontend and not the backend,so be careful when rebuilding it 
2. After building, run the container and ls into it to see the directories 


GENERAL STEPS 
1. Dockerise the frontend, backend and database 
2. Use Docker-compose to deploy them in the same networks for testing as opposed to using links for just docker 
3. Write manifest files for them and test the application on Minikube 
4. Convert it into helm charts and do CI for it 


HELM CHART FOR NODEJS APPLICATION WITH MINIKUBE 
1. `helm create node-app`
2. Run helm template command `helm template [RELEASE_NAME] [CHART] [flags]`

`[RELEASE_NAME]` is the name of the release you want to generate manifests for. This can be any name you choose.
`[CHART]` is the path to the directory containing your Helm chart, or the name of the chart if it's available in your Helm repositories.

`helm template frontend ./node-app`
3. Install the chart, `helm install frontend ./node-app`


HELM CHART FOR GOLANG APPLICATION

1. Handle Backend Configmap - this should actually be handled as a secret but will be taken care of when deployed to aws.
2. `helm install backend ./go-app`
3. `helm uninstal backend`

HELM CHART FOR DATABASE 
1. Use an already existing helm chart and modify it, Use the Bitnami Helm Chart 
2. `helm repo add bitnami https://charts.bitnami.com/bitnami`
3. `helm repo update`
4. Create Pv and Pvc and values.yaml file files 
5. `helm install psql-test bitnami/postgresql --set persistence.existingClaim=postgresql-pv-claim --set volumePermissions.enabled=true --set postgresql.service.name=postgres -f values.yaml`
5. To connect to your database from outside the cluster execute the following commands:
```sh
export POSTGRES_PASSWORD=$(kubectl get secret --namespace default psql-test-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)
```
6. Inspect bitnami chart 
`kubectl get -o yaml pod psql-test-postgresql-0 > postgres.yaml`             
7. Uninstall chart `helm uninstall psql-test bitnami/postgresql`
8. get the postgres service in yaml 
`kubectl get -o yaml svc psql-test-postgresql > bitnami-service.yaml`
9. Override bitname service name to `postgres` so it can connect to the backend 