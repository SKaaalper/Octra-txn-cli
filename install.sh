#!/bin/bash

# --------------------------------------
# OCTRA TX CLI Installer by _Jheff 🧠
# --------------------------------------

# 🎨 Colors
GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'
RED='\033[0;31m'; BOLD='\033[1m'; NC='\033[0m'

clear
echo -e "${CYAN}----------------------------------------${NC}"
echo -e "${GREEN}       OCTRA TX CLI INSTALLER          ${NC} "
echo -e "${CYAN}----------------------------------------${NC}"
echo -e "${BOLD}             by _Jheff${NC}\n"

# Step 1: System update and dependencies
echo -e "${YELLOW}[1/7] Installing required packages...${NC}"
sudo apt update && sudo apt install -y python3 python3-pip python3-venv git curl

# Step 2: Clone Octra TX CLI repo
echo -e "${YELLOW}[2/7] Cloning Octra CLI repo...${NC}"
rm -rf octra_pre_client
git clone https://github.com/octra-labs/octra_pre_client.git || { echo -e "${RED}❌ Failed to clone repo${NC}"; exit 1; }
cd octra_pre_client

# Step 3: Python virtual environment
echo -e "${YELLOW}[3/7] Setting up Python environment...${NC}"
python3 -m venv venv
source venv/bin/activate

# Step 4: Install Python dependencies
echo -e "${YELLOW}[4/7] Installing Python dependencies...${NC}"
pip install --upgrade pip
pip install -r requirements.txt

# Step 5: Get user input
echo ""
echo -e "${CYAN}🔐 Enter your PRIVATE KEY (Base64 format):${NC}"
read -r PRIV

# Ask if user wants auto recipient or manual
echo ""
echo -e "${CYAN}🎯 Do you want to auto-fetch a recipient? (y/n)${NC}"
read -r AUTO_RECIPIENT

if [[ "$AUTO_RECIPIENT" == "y" ]]; then
  TO_ADDR=$(curl -s https://octrascan.io/network \
    | grep -o 'To: oct[a-zA-Z0-9]*' \
    | awk '{print $2}' \
    | shuf -n 1)
  if [[ $TO_ADDR =~ ^oct[a-zA-Z0-9]+$ ]]; then
    echo -e "${GREEN}✔️ Using auto-fetched address: $TO_ADDR${NC}"
  else
    echo -e "${RED}⚠️ Failed to fetch address. Switching to manual.${NC}"
    AUTO_RECIPIENT="n"
  fi
fi

# If manual, prompt for recipient
if [[ "$AUTO_RECIPIENT" != "y" ]]; then
  while true; do
    echo -e "${CYAN}💳 Enter recipient Octra wallet address (starts with 'oct'):${NC}"
    read -r TO_ADDR
    if [[ $TO_ADDR =~ ^oct[a-zA-Z0-9]+$ ]]; then
      echo -e "${GREEN}✔️ Valid address: $TO_ADDR${NC}"
      break
    else
      echo -e "${RED}❌ Invalid address. Try again.${NC}"
    fi
  done
fi

# Step 6: RPC config
echo ""
echo -e "${CYAN}🌐 Enter RPC endpoint [Default: https://octra.network]:${NC}"
read -r RPC
RPC=${RPC:-https://octra.network}

# Step 7: Save wallet.json
echo -e "${YELLOW}[6/7] Saving your config to wallet.json...${NC}"
cat <<EOF > wallet.json
{
  "priv": "$PRIV",
  "addr": "$TO_ADDR",
  "rpc": "$RPC"
}
EOF
echo -e "${GREEN}✅ wallet.json saved! Ready to send transactions.${NC}"

# Step 8: Run CLI
echo ""
echo -e "${YELLOW}[7/7] Launching Octra CLI now...${NC}"
python3 cli.py
