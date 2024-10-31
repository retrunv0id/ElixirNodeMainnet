#!/bin/bash

# Install Docker
apt update && apt install docker.io -y

# Create directory and enter it
mkdir -p ElixirNode
cd ElixirNode

# Request user input
echo "Enter information for Elixir Mainnet setup:"
echo "---------------------------------------------"
read -p "Enter VPS IP Address: " ip_address
read -p "Enter Display Name: " display_name
read -p "Enter Beneficiary Address (with 0x): " beneficiary
read -p "Enter Private Key (without 0x): " private_key

# Create environment file with user input
cat > validator.env << EOL
ENV=prod
STRATEGY_EXECUTOR_IP_ADDRESS=$ip_address
STRATEGY_EXECUTOR_DISPLAY_NAME=$display_name
STRATEGY_EXECUTOR_BENEFICIARY=$beneficiary
SIGNER_PRIVATE_KEY=$private_key
EOL

# Create auto update script
cat > update.sh << EOL
#!/bin/bash

# Pull latest image and check for changes
if docker pull elixirprotocol/validator --platform linux/amd64 | grep -q "Image is up to date"; then
   exit 0
else
   # If there's an update, restart container
   docker stop elixir
   docker rm elixir
   docker run --env-file ./validator.env \
   --platform linux/amd64 \
   --name elixir \
   --restart unless-stopped \
   -p 17690:17690 \
   elixirprotocol/validator
fi
EOL

# Make script executable
chmod +x update.sh

# Pull image and run container
docker pull elixirprotocol/validator --platform linux/amd64
docker run --env-file ./validator.env \
--platform linux/amd64 \
--name elixir \
--restart unless-stopped \
-p 17690:17690 \
elixirprotocol/validator

echo "Setup completed!"
echo "---------------------"
echo "To check logs: docker logs -f elixir"
echo "For manual update: ./update.sh"
