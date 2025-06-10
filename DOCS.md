# GhostMesh Documentation

GhostMesh is a modern, high-performance peer-to-peer VPN mesh, inspired by Tailscale/Headscale but built for next-gen speed, privacy, and modularity.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Components](#components)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [NAT Traversal (QUIC + ICE/TURN)](#nat-traversal-quic--iceturn)
- [Security](#security)
- [Extending GhostMesh](#extending-ghostmesh)
- [FAQ](#faq)

---

## Overview

**GhostMesh** is a modular mesh VPN platform designed for:

- High-performance, peer-to-peer networking
- Full zero-trust model and fine-grained routing
- Modern NAT traversal (QUIC first, ICE/TURN/STUN fallback)
- Seamless CLI (`ghostctl`) for all roles
- Linux-first but cross-platform design

---

## Architecture

```
+-------------+     +-------------+     +-------------+
| ghostlink   | <-> | ghostmesh   | <-> | ghostgate   |
| (client)    |     | (coord)     |     | (relay)     |
+-------------+     +-------------+     +-------------+
       |                                 |
       +------------ Mesh --------------+
                (QUIC / WireGuard)
```

- **ghostlink**: Main VPN client (handles keys, routes, connections)
- **ghostmesh**: Coordination/control server (auth, node registry, ACLs)
- **ghostgate**: High-speed relay service (QUIC relay, ICE/TURN/STUN fallback)
- **ghostctl**: Command-line tool used for both client/server control

---

## Components

- **ghostlink**  
  Mesh VPN client; manages peer state, WireGuard tunnels, keygen, and routes.  
  Controlled via `ghostctl`.

- **ghostmesh**  
  Coordination/control server. Handles authentication, registration, node discovery, ACLs, config sync.  
  Controlled via `ghostctl`.

- **ghostgate**  
  Relay node for NAT traversal. Uses QUIC as primary, falls back to ICE/TURN/STUN if required.  
  Headless; managed via API or `ghostctl`.

- **ghostctl**  
  Unified CLI for both client/server/relay (node management, ACLs, status, debug, admin ops).

---

## Installation

### Prerequisites

- [Zig 0.14+](https://ziglang.org/download/)
- [WireGuard tools](https://www.wireguard.com/install/)
- (Optional) [QUIC](https://github.com/cloudflare/quiche), [libnice](https://github.com/libnice/libnice) for ICE/TURN.

### Quick Build

```sh
zig build -Drelease-fast
```

Binaries:

```
./zig-out/bin/ghostlink
./zig-out/bin/ghostmesh
./zig-out/bin/ghostgate
./zig-out/bin/ghostctl
```

---

## Usage

### Start the Coordination Server

```sh
ghostmesh --config ghostmesh.toml
```

### Start a Relay Node

```sh
ghostgate --config ghostgate.toml
```

### Start a Client

```sh
ghostlink join --server <ghostmesh_host> --auth <token>
```

### Manage with CLI

```sh
ghostctl status
ghostctl peers
ghostctl route add 10.1.1.0/24 via peer01
ghostctl keys rotate
```

---

## Configuration

### Example ghostmesh.toml

```toml
[server]
bind = "0.0.0.0:7777"
auth_method = "oidc"
acl_file = "acls.toml"
```

### Example ghostgate.toml

```toml
[relay]
listen = "0.0.0.0:3478"
use_quic = true
fallback = ["ice", "turn", "stun"]
```

---

## NAT Traversal (QUIC + ICE/TURN)

- **QUIC relay**: First attempt for lowest latency, multiplexed connections.
- **ICE/TURN/STUN fallback**: Automatic fallback for tough NATs or firewalled networks.
- **No DERP**: Designed to be more performant and reliable than legacy DERP relay.

---

## Security

- End-to-end encryption (WireGuard for data plane, TLS/QUIC for relay)
- Zero trust architecture (no trust in coordination server or relays)
- Pluggable authentication (OIDC, static keys, mTLS)
- ACLs & firewall integration (user-defined, programmable)

---

## Extending GhostMesh

- Written in Zig for speed and safety; designed for modular extension
- Easily add new relay types or mesh protocols
- gRPC or REST API planned for future scripting/admin integration
- CLI (`ghostctl`) is fully pluggable for custom commands

---

## FAQ

**Q: Why Zig?**  
A: Predictable performance, no GC, tiny static binaries, easier FFI and lower attack surface than Go or Rust.

**Q: Can I run the client and server on the same host?**  
A: Yes, all binaries are standalone.

**Q: Is this compatible with Tailscale or Headscale?**  
A: No, but architectural concepts are similar.

**Q: Will there be a GUI?**  
A: A minimal web UI or TUI is planned.

---

See also:

- `README.md`
- `COMMANDS.md`
- `DIAGRAM.md`

