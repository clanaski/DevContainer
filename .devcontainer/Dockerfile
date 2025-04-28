ARG VARIANT="6.0-jammy"
FROM mcr.microsoft.com/dotnet/sdk:${VARIANT}

ENV AZURE_DEVOPS_EXT_PAT="6e6CQR6ICnvLIegoKh6uMUl1nKnnKUZrq5kVJdZcN6oOkb9gNWt9JQQJ99BDACAAAAAAFU20AAASAZDO44OQ"

# Set the working directory in the container
WORKDIR /WellFit

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget apt-transport-https ca-certificates gnupg
    RUN apt-get update && apt-get install -y sudo
    RUN sudo chmod -R 777 ./

# Copy application files from host to container
COPY . ./repos
# RUN install.sh

# RUN source authenticateDevops.sh
EXPOSE 8080