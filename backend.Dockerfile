# build stage 
FROM golang:alpine AS builder 

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

# # the run stage
# FROM scratch

# # Set the working directory 
# WORKDIR /app

# # Copy the binary from the build stage
# COPY --from=builder /app .

EXPOSE 8080

CMD ["chmod", "+x", "api"] 
ENTRYPOINT ["./api"]
