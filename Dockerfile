FROM node:lts-alpine

# Set the working directory inside the container
WORKDIR /wis2box-webapp

# copy both 'package.json'
COPY package.json ./

# install project dependencies
RUN npm install --omit=dev

# get rid of the dev dependencies
RUN npm uninstall eslint-plugin-vue eslint cross-spawn

# copy project files and folders to the current working directory
COPY . .

# remove cross-spawn from node_modules
RUN rm -rf node_modules/cross-spawn

# expose port 4173
EXPOSE 4173

# Copy the entrypoint script into /app and make it executable
RUN chmod +x /wis2box-webapp/docker/entrypoint.sh

COPY docker/healthcheck.sh /wis2box-webapp/healthcheck.sh

RUN chmod +x /wis2box-webapp/healthcheck.sh

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD /wis2box-webapp/healthcheck.sh

# Set the entrypoint
ENTRYPOINT ["sh", "/wis2box-webapp/docker/entrypoint.sh"]
