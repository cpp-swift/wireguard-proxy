# wireguard-proxy-scripts
Scripts to expose service behind a NAT router/firewall using Wireguard, AWS, and iptables.

## Usage
On both machines:

```
git clone https://github.com/cpp-swift/wireguard-proxy.git
```

Run ./aws-wg.sh on the AWS machine.

Run ./onprem-wg.sh on the on-premise machine.

Follow the prompts on both machines.

PS if something breaks, it's probably because one of the public keys contains a slash, and that breaks the `sed` command.