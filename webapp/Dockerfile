FROM node:lts-alpine

# Set the working directory inside the container
WORKDIR /wis2box-webapp

# copy both 'package.json' and 'package-lock.json' (if available)
COPY package*.json ./

# install project dependencies
RUN npm install

# copy project files and folders to the current working directory
COPY . .

# expose port 4173
EXPOSE 4173

# Copy the entrypoint script into /app and make it executable
RUN chmod +x /wis2box-webapp/docker/entrypoint.sh

COPY healthcheck.sh /wis2box-webapp/healthcheck.sh

RUN chmod +x /wis2box-webapp/healthcheck.sh

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD /wis2box-webapp/healthcheck.sh

# Set the entrypoint
ENTRYPOINT ["sh", "/wis2box-webapp/docker/entrypoint.sh"]
