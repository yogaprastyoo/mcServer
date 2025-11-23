# Use a Java 22 base image for modern Minecraft versions
FROM openjdk:22-jdk-slim

# Set environment variables for Minecraft
# Using latest versions for Minecraft 1.21 as of July 2025
ENV MC_VERSION=1.21.6
ENV FABRIC_LOADER_VERSION=0.16.14
ENV FABRIC_INSTALLER_VERSION=1.1.0
ENV MEMORY=6G

# Accept build arguments for user and group IDs for setting permissions
ARG UID=1000
ARG GID=1000

# Install necessary tools (curl for downloading, gosu for user switching)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gosu \
    git \
    # Use the NodeSource script to get the latest Node.js and npm
    && curl -fsSL https://deb.nodesource.com/setup_current.x | bash - \
    && apt-get install -y nodejs \
    && (. /etc/os-release && curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | env os=${ID} dist=${VERSION_CODENAME} bash) \
    && apt-get install git-lfs \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user to run the server securely
RUN groupadd -g ${GID} minecraft && \
    useradd -u ${UID} -g minecraft -d /fabric-server -m minecraft

# Set the working directory for the application files
WORKDIR /app

# Download the Fabric server launcher
RUN curl -L -o fabric-server-launch.jar "https://meta.fabricmc.net/v2/versions/loader/${MC_VERSION}/${FABRIC_LOADER_VERSION}/${FABRIC_INSTALLER_VERSION}/server/jar"

WORKDIR /app
# Copy the entrypoint script into the image and make it executable
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# Expose the ports the server will use
EXPOSE 34980
EXPOSE 50651/udp

# Set the entrypoint script as the command to run.
ENTRYPOINT ["/app/entrypoint.sh"]
# This is the default command that the entrypoint script will run.
# It now uses the MEMORY environment variable defined above.
CMD npm start
