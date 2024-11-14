---
layout: default
description: Failing a VIP over to another HAProxy
title: armada-infra - Failing a VIP over to another HAProxy
service: armada-infra
runbook-name: "armada-infra - Failover for a VIP"
tags: alchemy, armada-infra, vip, haproxy
link: /armada/armada-infra-vip-failover.html
type: Troubleshooting
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes how to fail the VIP over from one HAProxy server to another.

## Example Alerts

This is a general troubleshooting runbook and is not tied to any specific alerts

## Investigation and Action

To investigate if the VIP needs to be failed over on a carrier, please try to `curl` a nodeport via the VIP:

`curl -v 169.61.177.3:20575`

In the example above, `169.61.177.3` is the VIP of `prod-dal12-carrier7` and `20575` is an active nodeport of a customer's master pod.  To retrieve a list of the active nodeports use the following command and pick one at random:

`kubectl get svc -n kubx-masters`

If the curl doesn't work:

~~~
* Rebuilt URL to: 169.61.177.3:20575/
*   Trying 169.61.177.3...
~~~

Then you are probably dealing with a VIP that needs a failover.

### Failing over the VIP

SSH into both of the `haproxy` servers designated to the carrier - in this example `prod-dal12-carrier7-haproxy-01` and `prod-dal12-carrier7-haproxy-02`.

Run `ip a` to get a list of IP addresses.

Example on the `-01` haproxy (VIP for `prod-dal12-carrier7-loadbalancer-gateway-vip` is `169.61.177.3`). Note: replace `169.61` below with the relavant numbers for the VIP in question:

~~~
root@prod-dal12-carrier7-haproxy-01:~# ip a | grep 169.61
    inet 169.61.176.73/26 brd 169.61.176.127 scope global bond1
    inet 169.61.177.3/32 scope global bond1
    inet 169.61.177.2/32 scope global bond1
    inet 169.61.177.4/32 scope global bond1
~~~

Check the output to find the active haproxy:
- If the output looks like the above (it finds some `/32` addresses), this means that the VIP is being managed by `haproxy-01`.
- If the grep result is empty, then the VIPs are on `haproxy-02`

On the haproxy which holds the VIPs, initiate the failover by running the following command:

`sudo /etc/init.d/keepalived restart`

Output will look like:

~~~
root@prod-dal12-carrier7-haproxy-01:~# sudo /etc/init.d/keepalived restart
[ ok ] Restarting keepalived (via systemctl): keepalived.service.
~~~

Try your `curl` again to see if the VIP has properly failed over.  If it has failed over correctly, a valid `curl` response would look like:

~~~
* Rebuilt URL to: 169.61.177.3:20575/
*   Trying 169.61.177.3...
* TCP_NODELAY set
* Connected to 169.61.177.3 (169.61.177.3) port 20575 (#0)
> GET / HTTP/1.1
> Host: 169.61.177.3:20575
> User-Agent: curl/7.54.0
> Accept: */*
> 

* Connection #0 to host 169.61.177.3 left intact
~~~

## Escalation Policy

### Any problems with the above steps?
Please escalate to #conductors on Slack.
