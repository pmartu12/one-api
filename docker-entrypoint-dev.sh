#!/bin/bash
set -e

# Step 1
COMPOSER_MEMORY_LIMIT=-1 composer install --optimize-autoloader

# Step 2
#	make clear-cache
#	make init-db

# Step 3
symfony local:server:start --no-tls --port=80

exec "$@"
