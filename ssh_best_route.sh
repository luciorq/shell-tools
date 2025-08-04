#!/bin/bash

# ============================================================================
# WARNING: This is generated content, do not run without testing first!
# ============================================================================

# A modern shell script to find the best available SSH route.
# It measures latency to all hosts, then tries to connect to the
# fastest one that has the specified port open.

# Should be used with the following in `~/.ssh/config`:

# Host my-workstation
#    # The real hostname of your workstation
#    HostName my-workstation.internal.company.com
#
#    # Add all possible ways to connect here. The script will find the best one.
#    # %h and %p are replaced by ssh with the HostName and Port from above.
#    ProxyCommand ssh-best-route.sh localhost:4242 %h:%p my-workstation.public-dns.com

# Exit if any command fails
set -e

# --- Helper Functions ---

# Print usage information to stderr and exit.
usage() {
  cat >&2 <<EOF
Usage: $(basename "$0") host1[:port] [host2[:port]...]

Finds the host with the lowest latency (ping) and an open TCP port,
then acts as a proxy to it. Intended for use as an ssh ProxyCommand.
EOF
  exit 1
}

# --- Main Logic ---

# Check if at least one host is provided.
if [ "$#" -eq 0 ]; then
  usage
fi

# --- 1. Measure Latency for all Hosts ---

echo "🔎 Pinging hosts to find the fastest route..." >&2
results=""
for host_arg in "$@"; do
  # Separate host and port. Default to port 22.
  host="${host_arg%%:*}"
  port="${host_arg##*:}"
  if [ "$host" = "$port" ]; then
    port=22
  fi

  # Ping the host 3 times with a 1-second timeout.
  # We extract the average round-trip time (RTT).
  if avg_rtt=$(ping -c 3 -W 1 "$host" 2>/dev/null | grep 'rtt' | cut -d'/' -f5); then
    # If ping succeeds, store the RTT and the original host:port argument.
    echo "  - ${host_arg}: ${avg_rtt} ms" >&2
    results+="${avg_rtt} ${host_arg}\n"
  else
    echo "  - ${host_arg}: Unreachable" >&2
  fi
done

# If no hosts were reachable, exit.
if [ -z "$results" ]; then
  echo "❌ No hosts were reachable." >&2
  exit 1
fi

# --- 2. Try to Connect, Best First ---

echo -e "\n✅ Found reachable hosts. Checking for open SSH port in order of speed..." >&2

# Sort the results numerically to get the fastest hosts first.
# The `head -n -1` removes the final blank line from the `results` variable.
sorted_hosts=$(echo -e "$results" | head -n -1 | sort -n)

while read -r line; do
  # Get the host:port argument from the sorted line.
  host_arg=$(echo "$line" | cut -d' ' -f2-)

  # Separate host and port again.
  host="${host_arg%%:*}"
  port="${host_arg##*:}"
  if [ "$host" = "$port" ]; then
    port=22
  fi

  echo "  - Trying ${host_arg}..." >&2
  # Check if the port is open using netcat (-z scans, -w sets timeout).
  if nc -z -w 2 "$host" "$port"; then
    echo "  - Connection successful! Proxying traffic." >&2
    # Use exec to replace this script with nc.
    # This connects ssh's stdin/stdout directly to the target.
    exec nc "$host" "$port"
  else
    echo "  - Port ${port} is closed or firewalled." >&2
  fi
done <<< "$sorted_hosts"

# --- 3. Fallback ---
echo "❌ All reachable hosts had their SSH ports closed. Cannot connect." >&2
exit 1