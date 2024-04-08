# wis2box-webapp

## Test locally without Docker

To test the webapp locally without docker, you need to install the following dependencies:

- [nodejs](https://nodejs.org/en/download/)
- [npm](https://www.npmjs.com/get-npm)

Then, you can run the following commands:

```bash
    npm install
    npm run dev
```
This will start the webapp which will be available at http://localhost:8080/wis2box-webapp/

## test locally with docker

### build the image

Run the following command to build the image:

```bash
    docker build -t wis2box-webapp .
```

## Test the wis2box-webapp image as part of the wis2box stack

To test the webapp as part of the wis2box stack, run the following commands:

```bash
    cd tests/
    docker-compose -f docker-compose.yml up -d --build
```

This will start the webapp which will be available at http://localhost:4173/wis2box-webapp/

## Development

### Project setup

```bash
# yarn
yarn

# npm
npm install

# pnpm
pnpm install
```

#### Compiles and hot-reloads for development

```bash
# yarn
yarn dev

# npm
npm run dev

# pnpm
pnpm dev
```

#### Compiles and minifies for production

```bash
# yarn
yarn build

# npm
npm run build

# pnpm
pnpm build
```

### Linting

```bash
# yarn
yarn lint

# npm
npm run lint

# pnpm
pnpm lint
```

### Customize configuration

See [Configuration Reference](https://vitejs.dev/config/).

## Releasing

```bash
# create release (x.y.z is the release version)
vi package.json  # update "version"
vi package-lock.json  # update 'version' and 'packages."".version
git commit -am 'update release version x.y.z'
git push origin main
git tag -a x.y.z -m 'tagging release version x.y.z'
git push --tags

# publish release on GitHub (https://github.com/wmo-im/wis2box-webapp/releases/new)
```

## Bugs and Issues

All bugs, enhancements and issues are managed on [GitHub](https://github.com/wmo-im/wis2box-webapp/issues).

## Contact

* [David Berry](https://github.com/david-i-berry)
* [Rory Burke](https://github.com/RoryPTB)
* [Maaike Limper](https://github.com/maaikelimper)