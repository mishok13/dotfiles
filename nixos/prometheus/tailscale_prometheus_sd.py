#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///

import json
import sys


def parse_node(info):
    tags = set(info.get("Tags", set()))
    if not {"tag:homelab", "tag:server"} & tags:
        return None

    hostname = info.get("HostName")
    if not hostname:
        print(f"Error: Node {info.get('ID')} missing HostName", file=sys.stderr)
        return None

    return {"targets": [f"{hostname}:9100"], "labels": {"node": hostname}}


def parse_tailscale_status(data):
    host = data.get("Self", {})
    peers = list(data.get("Peer", {}).values())
    return list(
        filter(
            None,
            (parse_node(peer) for peer in peers + [host]),
        )
    )


def main():
    input_data = sys.stdin.read()
    tailscale_status = json.loads(input_data)
    prometheus_targets = parse_tailscale_status(tailscale_status)
    json.dump(prometheus_targets, sys.stdout)
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()
