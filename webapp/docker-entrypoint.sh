#!/bin/bash

# Set VITE_API_URL to the value of WIS2BOX_API_URL
echo "set VITE_API_URL to the value of WIS2BOX_API_URL in .env"
echo "VITE_API_URL=$WIS2BOX_API_URL"
export VITE_API_URL=$WIS2BOX_API_URL

npm run build
npm run preview