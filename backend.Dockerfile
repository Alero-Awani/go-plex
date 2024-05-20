# build stage 
FROM golang:1.21.6-alpine AS builder 

# Set the working directory 
WORKDIR /app/go-plex

# Copy and download dependencies 
COPY go.mod go.sum ./
RUN go mod download 

# Copy the source code 
COPY ./src/api .
COPY ./internals ./internals/
COPY ./src/graphql ./src/graphql

#BUILD THE Go application
RUN go build -o api 

EXPOSE 8080

# the run stage
FROM scratch

# Set the working directory 
WORKDIR /app/go-plex

# Copy the binary from the build stage
COPY --from=builder /app/go-plex .

EXPOSE 8080

CMD ["chmod", "+x", "api"] 
ENTRYPOINT ["./api"]
