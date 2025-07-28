#!/bin/bash

# Colors for clean output
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

clear
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}      OCTRA CLI QUICK INSTALLER${NC}"
echo -e "${CYAN}========================================${NC}"
echo -e "${BOLD}              by _Jheff ${NC}\n"

# 1. Rust install
echo -e "${YELLOW}[1/8] Checking Rust...${NC}"
if ! command -v cargo >/dev/null 2>&1; then
  echo -e "${CYAN}Installing Rust...${NC}"
  curl -sSf https://sh.rustup.rs | sh -s -- -y
  source $HOME/.cargo/env
else
  echo -e "${GREEN}Rust is already installed.${NC}"
fi

# 2. Clone Octra repo
echo -e "${YELLOW}[2/8] Grabbing Octra CLI repo...${NC}"
rm -rf ocs01-test
git clone https://github.com/octra-labs/ocs01-test.git
cd ocs01-test || { echo -e "${RED}Failed to cd into repo.${NC}"; exit 1; }

# 3. Build
echo -e "${YELLOW}[3/8] Building CLI... this might take a bit.${NC}"
cargo build --release || { echo -e "${RED}Build failed. Check your Rust setup.${NC}"; exit 1; }

# 4. Copy EI
echo -e "${YELLOW}[4/8] Setting up execution interface...${NC}"
cp EI/exec_interface.json . || { echo -e "${RED}Missing EI file. Something's off.${NC}"; exit 1; }

# 5. Ask for private key
echo ""
echo -e "${CYAN}🔑 Enter your Base64 PRIVATE KEY:${NC}"
read -r PRIV

# 6. Ask for wallet address
while true; do
  echo -e "${CYAN}🪪 Octra wallet address (starts with oct...):${NC}"
  read -r TO_ADDR
  if [[ $TO_ADDR =~ ^oct[a-zA-Z0-9]+$ ]]; then
    echo -e "${GREEN}Got it: $TO_ADDR${NC}"
    break
  else
    echo -e "${RED}That doesn't look right. Try again.${NC}"
  fi
done

# 7. RPC (with default)
echo -e "${CYAN}🌐 RPC endpoint [press Enter for default: https://octra.network]:${NC}"
read -r RPC
RPC=${RPC:-https://octra.network}

# 8. Save config
echo -e "${YELLOW}[8/8] Saving wallet config...${NC}"
cat > wallet.json <<EOF
{
  "priv": "$PRIV",
  "addr": "$TO_ADDR",
  "rpc": "$RPC"
}
EOF
echo -e "${GREEN}✔ wallet.json saved.${NC}"

# Run it
echo -e "\n${CYAN}🚀 All set. Running the Octra CLI...${NC}"
sleep 1
./target/release/ocs01-test
