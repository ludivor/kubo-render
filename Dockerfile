FROM ipfs/kubo:latest

ENV IPFS_PROFILE=lowpower,server
ENV PORT=8080

RUN mkdir -p /container-init.d && \
    printf '%s\n' \
      '#!/bin/sh' \
      'ipfs config --json Swarm.RelayService.Enabled false' \
      'ipfs config --json Swarm.RelayClient.Enabled false' \
      'ipfs config --json Swarm.DisableNatPortMap true' \
      'ipfs config --json Swarm.ConnMgr.LowWater 10' \
      'ipfs config --json Swarm.ConnMgr.HighWater 30' \
      'ipfs config Swarm.ConnMgr.GracePeriod 30s' \
      'ipfs config Swarm.ResourceMgr.MaxMemory 256MB' \
      > /container-init.d/001-lowbandwidth.sh && \
    chmod 755 /container-init.d/001-lowbandwidth.sh
