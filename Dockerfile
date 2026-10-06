# syntax=docker/dockerfile:1
FROM ipfs/kubo:v0.43.1

ENV IPFS_PROFILE=lowpower,server \
    PORT=5001

COPY --chmod=755 <<"EOF" /container-init.d/001-config.sh
#!/bin/sh
# ---------------------INICIO---------------------Reducir tráfico
# --- 1. Ajustes de recursos y red local ---
ipfs config Swarm.ResourceMgr.MaxMemory 256MB
ipfs config Swarm.ConnMgr.GracePeriod 30s
ipfs config --json Swarm.DisableNatPortMap true
ipfs config --json Discovery.MDNS.Enabled false
ipfs config --json Gateway.ExposeRoutingAPI false

# --- 2. Desactivación de servicios Relay y Hole Punching ---
ipfs config --json Swarm.RelayService.Enabled false
ipfs config --json Swarm.RelayClient.Enabled false
ipfs config --json Swarm.EnableHolePunching false

# --- 3. Límites estrictos de conexiones (minimo 5 a 15 nodos, mejor 10 a 30) ---
ipfs config --json Swarm.ConnMgr.LowWater 10
ipfs config --json Swarm.ConnMgr.HighWater 30
# ---------------------FIN--------------------- Reducir tráfico

# El gateway (sin protección) queda solo dentro del contenedor
ipfs config Addresses.Gateway /ip4/127.0.0.1/tcp/8080

# API pública, pero solo con token y solo comandos de lectura
if [ -z "$GATEWAY_TOKEN" ]; then
  echo "ERROR: falta GATEWAY_TOKEN"
  exit 1
fi
ipfs config Addresses.API /ip4/0.0.0.0/tcp/5001
ipfs config --json API.Authorizations "{
  \"script\": {
    \"AuthSecret\": \"bearer:$GATEWAY_TOKEN\",
    \"AllowedPaths\": [\"/api/v0/cat\", \"/api/v0/ls\"]
  }
}"
EOF
