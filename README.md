# wis2box-app

## test locally without docker

To test the webapp locally without docker, you need to install the following dependencies:

- [nodejs](https://nodejs.org/en/download/)
- [npm](https://www.npmjs.com/get-npm)

Then, you can run the following commands:

```bash
    cd webapp
    npm install
    npm run dev
```
This will start the webapp which will be available at http://localhost:8080/wis2box-webapp/

## test locally with docker

### build the image

Run the following command to build the image:

```bash
    docker build -t wis2box-webapp ./webapp/
```

### test the image

Test the result with the following command:

```bash
    docker-compose -f test/docker-compose.yml up -d
```

This will start the webapp which will be available at http://localhost:8080/wis2box-webapp/

