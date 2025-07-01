#!/bin/bash

# Define colors
GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'
RED='\033[0;31m'; BOLD='\033[1m'; NC='\033[0m'

clear
echo -e "${CYAN}=========================================${NC}"
echo -e "     ${GREEN}🟢 OCTRA SEND TRANSACTION CLI 🟢${NC}     "
echo -e "${CYAN}=========================================${NC}"
echo -e "${BOLD}        Auto Installer by _Jheff${NC}"
echo ""

# 1️⃣ Install prerequisites
echo -e "${YELLOW}[1/8] Installing Python & curl...${NC}"
sudo apt update && sudo apt install -y python3 python3-pip python3-venv python3-dev git curl

# Clone repo
echo -e "${YELLOW}[2/8] Cloning Octra client...${NC}"
rm -rf octra_pre_client && git clone https://github.com/octra-labs/octra_pre_client.git
cd octra_pre_client || { echo -e "${RED}❌ Cannot access folder${NC}"; exit 1; }

# Setup env
echo -e "${YELLOW}[3/8] Setting up Python virtualenv...${NC}"
python3 -m venv venv && source venv/bin/activate

echo -e "${YELLOW}[4/8] Installing Python requirements...${NC}"
pip install --upgrade pip && pip install -r requirements.txt

# Prompt for private key
echo ""
echo -e "${CYAN}🔐 Enter your PRIVATE KEY (Base64 format):${NC}"
read -r PRIV

# Prompt for Octra wallet address
while true; do
  echo -e "${CYAN}💳 Enter your Octra wallet address (must start with 'oct'):${NC}"
  read -r TO_ADDR
  if [[ $TO_ADDR =~ ^oct[a-zA-Z0-9]+$ ]]; then
    echo -e "${GREEN}✔️ Valid address: $TO_ADDR${NC}"
    break
  else
    echo -e "${RED}❌ Invalid address. Try again.${NC}"
  fi
done

# Prompt for RPC
echo -e "${CYAN}🌐 Enter RPC endpoint [default (Press Enter): https://octra.network]:${NC}"
read -r RPC
RPC=${RPC:-https://octra.network}

# Write wallet.json
echo -e "${YELLOW}[6/8] Writing wallet.json...${NC}"
cat <<EOF > wallet.json
{
  "priv": "$PRIV",
  "addr": "$TO_ADDR",
  "rpc": "$RPC"
}
EOF
echo -e "${GREEN}✅ wallet.json saved!${NC}"

# Run CLI
echo ""
echo -e "${YELLOW}[7/8] Running Octra Send Transaction CLI...${NC}"
python3 cli.py
