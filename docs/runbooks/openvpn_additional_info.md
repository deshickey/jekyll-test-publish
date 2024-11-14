---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: OpenVPN Informational Guide
service: OpenVPN
title: Troubleshoot OpenVPN service
runbook-name: "OpenVPN Informational Guide"
link: /openvpn_additional_info.html
type: Operations
parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview
{:.no_toc}

* Will be replaced with the ToC, excluding the "Contents" header
{:toc}

---

## Detailed Information

One reason for coming to this page is because a Pagerduty alert was linked here. Check the errors logs in the Pagerduty alert.

`Container $containername is in error state. Openvpn may not be running! See container logs below`

These checks are coming from the alchemy-devtest machine. IP address 9.20.33.66. To request access go to [ITIM](https://huritim.hursley.ibm.com/itim/self/RequestAccounts.do) and search for alchemy-devtest.

## Detailed Procedure

### Client Side OpenVPN troubleshooting

To check container logs, look into this alchemy-devtest machine (9.20.33.66).

Check Status: 
`docker ps -a | grep openvpn`

Check Recent logs:
`docker logs --tail=100 $containername`

There are a few different reasons that the alerts will trigger.

1) Container has been up for less than 5 minutes.

2) [Cannot reach endpoint](#if-logs-contain-openvpn-connection-is-up-but-failed-to-reach-endpoint-xxxxxxxxx)

3) [Authentication failed](#container-logs-contain-auth_failed)

#### Container logs Contain AUTH_FAILED
The USAM user connecting is `dashboard-prod`, there may be a problem with the user.

Go into the infra-vpn server the user is trying to connect to. To find the server look into the configuration file for the specified environment on the alchemy-devtest machine.
`/root/openvpn_config/$environment/openvpn.conf`
Look for the line with `remote $ipaddress`

Once on the server check on the `dashboard-prod` user. [Here](#test-connectivity-to-the-usam-server)

Check to make sure this user is not locked out. If they are not locked out, the problem is with the OpenVPN server.

#### If logs contain: was not able to find the container at all!
This means that the container is not running. Run this command to get it running again:

~~~~
sudo docker run -d --restart=always --name=$containername -v /root/openvpn_config/$environment:/openvpn --device=/dev/net/tun:/dev/net/tun --net=host --privileged=true -e "OPENVPN_USERNAME=${OPENVPN_USERNAME}" -e "OPENVPN_PASSWORD=${OPENVPN_PASSWORD}" alchemyregistry.hursley.ibm.com:5000/alchemy/openvpn:latest
~~~~

OPENVPN_PASSWORD and OPENVPN_USERNAME can be found here: `/root/openvpn_config/$environment/login.conf`
containername is found in the pagerduty alert.

#### If logs contain: OpenVPN connection is up, but failed to reach endpoint XX.XXX.XX.XX
The container is up and running, but something is going on with the connection. Check if the endpoint is accessible. The endpoints point to the infra-vpn machines. 

### Server Side OpenVPN troubleshooting
Run the following command to check the OpenVPN service:
service openvpn status

If the service is stopped issue the following command:
sudo service openvpn start

If service is running you can check the logs using the following:

`
tail -300 /var/log/syslog
`

check for any errors or any possible users/ips trying to connect every few seconds.

You can also check to see if other users are connected

`
tail -300 /var/log/auth.log
`

If the user can connect to other openvpn, just can not connect to this openvpn, and you see such error in auth.log, that should be USAM server issue, go to the section [Test connectivity to the USAM server](#test-connectivity-to-the-usam-server)
```
pam_sss(openvpn:auth): received for user dashboard-vpn: 9 (Authentication service cannot retrieve authentication info)
```

`
cat /etc/openvpn/openvpn-status.log
`

These IP addresses can be used to find the users USAM id.

The top portion shows connections in progress and the bottom shows clients connected.

### Can't ssh to server when connected to OpenVPN

Log into the host using SL VPN and ssh and issue the following command:
~
route
~
You should see (2) 172.31.X.X routes if not they need to be added.

Prod servers will have OpenVPN 172 routes for both prod-lon02 and prod-dal09:

~~~~
* 172.31.246.0    prod-lon02-infra-vpn-02
* 172.31.247.0    prod-lon02-infra-vpn-01
* 172.31.248.0    prod-dal09-infra-vpn-02
* 172.31.249.0    prod-dal09-infra-vpn-01
~~~~

These are the OpenVPN IP addresses for all the environments:

~~~~
* dev-mon01-infra-vpn-01       172.31.245.0/24
* dev-mon01-infra-vpn-02       172.31.244.0/24
* prestage-mon01-infra-vpn-01  172.31.253.0/24
* prestage-mon01-infra-vpn-02  172.31.252.0/24
* stage-dal09-infra-vpn-01     172.31.251.0/24
* stage-dal09-infra-vpn-02     172.31.250.0/24
* prod-dal09-infra-vpn-01      172.31.249.0/24
* prod-dal09-infra-vpn-02      172.31.248.0/24
* prod-lon02-infra-vpn-01      172.31.247.0/24
* prod-lon02-infra-vpn-02      172.31.246.0/24
~~~~

### To check if a user has access or is locked out

To check on the status of a USAM account and what groups the user is a member of you can run the following this [Jenkins job](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/view/OpenVPN/job/ldap-lookup-for-usam-openvpn-users/).

You can convert the LDAP time for lockout using this [link](http://www.epochconverter.com/ldap).

### To see what USAM groups have access to OpenVPN

`
cat /etc/openvpn/auth/auth-ldap.conf
`

Groups can be added here but OpenVPN service needs to be restarted for the change to take effect.

A new group can be added to this file using this [Jenkins job](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/view/OpenVPN/job/openvpn-deploy-usam-groups/).

A restart of the service is still required to commit the change.

You can view the configuration [here](https://github.ibm.com/alchemy-conductors/conductors-playbooks/tree/master/playbooks).


### Test connectivity to the USAM server

`
ldapsearch -LLL -x -H ldap://$ldapserver.sso.ad.isops.ibm.com -D 'bindisops@sso.ad.isops.ibm.com' -w '$password' -b "DC=sso,DC=ad,DC=isops,DC=ibm,DC=com" '(&(uid=$username))' 
`

get the password from the entry of `ldap_default_authtok` in `/etc/sssd/sssd.conf` on the vpn server
the ldap server can be found in `/etc/hosts`
the username is the USAM username. You can try `bindisops` or the problematic USAM username.

Sample output:
```
root@prestage-mon01-infra-vpn-03:~# ldapsearch -LLL -x -H ldap://bu044-adsso-002.sso.ad.isops.ibm.com -D 'bindisops@sso.ad.isops.ibm.com' -w '$password' -b "DC=sso,DC=ad,DC=isops,DC=ibm,DC=com" '(&(uid=bindisops))'
# refldap://bu3.sso.ad.isops.ibm.com/DC=bu3,DC=sso,DC=ad,DC=isops,DC=ibm,DC=c
 om

# refldap://DomainDnsZones.sso.ad.isops.ibm.com/DC=DomainDnsZones,DC=sso,DC=a
 d,DC=isops,DC=ibm,DC=com

root@prestage-mon01-infra-vpn-03:~#
```

If the ldapsearch command can work on other openvpn servers, but can not work on this openvpn server, open a ServiceNow Request to the SOS Team, and ask for help in slack channel [#sos-idmgt](https://ibm-argonauts.slack.com/messages/C5BJXQ23C)

**Contacts for USAM/SSO issues**
- Bud Greasley
- Gary Porter
- Sean R Penndorf

### To see how many clients are connected to an OpenVPN server, issue the following command:

`
cat /etc/openvpn/openvpn-status.log
`

you will see their public IP and their assigned OpenVPN (172.31.x.x) IP
each client uses 2 IP addresses
These IP addresses can be used to find the users USAM account.

## Escalation
OpenVPN is owned by conductors, please ask for help in [#conductors](https://ibm-argonauts.slack.com/messages/C54H08JSK)
