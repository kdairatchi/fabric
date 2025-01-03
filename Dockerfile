# Stage 1: Build the Go Application
FROM golang:1.23.3-alpine AS builder

# Set working directory
WORKDIR /app

# Copy go.mod and go.sum for dependency resolution
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy application source code
COPY . .

# Build the Go application
RUN CGO_ENABLED=0 GOOS=linux go build -o fabric

---

# Stage 2: Create a Minimal Runtime Environment
FROM alpine:latest

# Set environment variables
ENV GIN_MODE=release
ENV TRUSTED_PROXIES=127.0.0.1

# Create configuration directory
RUN mkdir -p /root/.config/fabric

# Copy built binary from the builder stage
COPY --from=builder /app/fabric /fabric

# Copy patterns directory
COPY patterns /patterns

# Copy environment configuration file
COPY ENV /root/.config/fabric/.env

# Verify files and structure
RUN ls -la /root/.config/fabric/
RUN ls -la /patterns

# Expose port 8080
EXPOSE 8080

# Run the application
CMD ["/fabric", "--serve", "--address=:8080"]
