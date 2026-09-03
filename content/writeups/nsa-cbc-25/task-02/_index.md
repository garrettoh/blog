---
title: "Task 02 - Malicious Router"
layout: "Notes"
overview: "Concise solution notes: PCAP triage identified Router3 redirecting Ubuntu archive traffic to a malicious DNS destination."
status: "Complete — concise notes"
icon: "note"
---

> These are concise solution notes, not a full walkthrough. They capture the successful analysis path and the evidence used to identify the malicious router.

## Initial triage

I ran a PCAP-scanning script to carve files, create a network map, and surface IoCs or other items worth investigating. The resulting overview highlighted the hosts, protocols, and unusual traffic patterns in the capture.

![PCAP analysis overview showing protocol statistics and suspicious network activity](/images/nsa-cbc-25/task-02/pcap-analysis-network-overview.png)

The scanner also identified FTP activity and carved router-related configuration data from the capture.

![PCAP analysis showing FTP activity and automatically carved files](/images/nsa-cbc-25/task-02/pcap-analysis-ftp-file-carving.png)

## Identifying the anomalous router

I reviewed the network map and noticed that one of the router devices appeared to point to a strange IP address. Looking further, the FTP traffic showed activity involving router backup configurations.

The map led to Router3 (`R3`) as the suspicious device.

![Network map highlighting Router3 as the anomalous router](/images/nsa-cbc-25/task-02/network-map-router3-anomaly.png)

## Router3 configuration

Reviewing the Router3 backup configuration revealed that it forwarded Ubuntu archive traffic to a false Ubuntu repository IP. Entering that IP directly did not provide the answer, so I continued correlating the configuration with the network map and the captured traffic.

The following configuration was the key evidence:

```c
config interface 'loopback'
        option device 'lo'
        option proto 'static'
        option ipaddr '127.8.1.3'
        option netmask '255.0.0.0'

config globals 'globals'
        option ula_prefix 'fdf2:87c7:eb73::/48'
        option packet_steering '1'

config device
        option name 'br-lan'
        option type 'bridge'
        list ports 'eth0'

config interface 'lan'
        option device 'br-lan'
        option proto 'static'
        option ipaddr '192.168.3.254'
        option netmask '255.255.255.0'
        option ip6assign '60'

config interface 'to_openwrt2'
        option device 'eth1'
        option proto 'static'
        list ipaddr '192.168.5.1/28'

config interface 'host_nat'
        option proto 'dhcp'
        option device 'eth2'

config route
        option target '192.168.3.0/24'
        option gateway '192.168.3.254'
        option interface 'lan'

config route
        option target '0.0.0.0/0'
        option gateway '192.168.5.2'
        option interface 'to_openwrt2'
```

## Key addresses

- `192.168.5.2` — route to OpenWrt2
- `192.168.3.254` — LAN address
- `127.8.1.3` — loopback address

## Result

Router3 (`R3`) was the malicious router that forwarded Ubuntu archive traffic to the malicious DNS request. That was the correct answer.
