---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: How to use the new OpenVPN solution to access Alchemy servers
service: OpenVPN
title: VPN Access
runbook-name: "VPN Access"
link: /vpn.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

# Accessing Alchemy Machines in SoftLayer

## Overview

This runbook describes how to set up openvpn on your local machine. You can either run single instances directly via the cli, or multiple instances concurrently in containers as described in the last section titled `Ubuntu OpenVPN docker-compose Setup`

## Detailed Information

This runbook describes how to access Alchemy machines using the OpenVPN.

Most squads will only need VPN access via the OpenVPN servers. Only `SRE/conductors` and `netint` squads will continue to need SoftLayer VPN access, and they will only need to use it for cases when the network infrastructure has a problem which prevents OpenVPN access.

_NB. There is a second method of VPN in use `OpenConnect`, however, that is currently only authroised for use by automation - **not** for use by individuals!_

### Pre-reqs:

- Correct **AccessHub group** membership
- Two-factor authentication **['2FA']** mechanism  
_`IBM Security Verify` (ISV) is the current 2FA solution - Refer to [IBM Security Verify App setup guide](https://w3.wdc1a.cirrus.ibm.com/#/support/article/w3id_sso_setup_guides/verify?_lang=en)_ for installation instructions
- OpenVPN installation and configuration files


### AccessHub group membership

Before configuring OpenVPN, you must ensure you have the correct AccessHub group membership.

To view/set groups, navigate to [AccessHub](https://ibm-support.saviyntcloud.com/ECM/workflowmanagement/requesthome?menu=1) -> View Current Access -> Security System : SOS IDMgt -> Expand your account

Groups:

- You must also be a member of one or more of the following groups to be able to gain `ssh` access:

   - For the development environments, you must be a member of one of:  
   `BU044-ALC-IDCC-Developer`  
   `BU044-ALC-Conductor`  
   `BU044-ALC-Conductor-EU`  
   _You'll only get approved for EU access if you reside **in** the EU_
   
   - For the staging environments, you must be a member of one of:  
   `BU044-ALC-IDCC-Staging`  
   `BU044-ALC-Conductor`


### Access to the production machines (essential need only)

To `ssh` to the machine you will need to have a **privileged user environment**  
_See the [production onboarding guide](../process/production_onboarding.html) for details of how to gain access to production environments!_
    - See the linked document for full information on [privileged users](http://w3.the.ibm.com/ecmweb/cybersecurity/itcs300_faqs.html#privilegedusers_auoa)

Be aware, that privilege user environments have a number of severe restrictions imposed on them!
- This is deliberate and is to protect our production environment.
- You must follow the [Production Onboarding process](../process/production_onboarding.html) before your production access will be approved.

Once you are well versed in the restrictions needed to a privileged user environment you can then look to get one set up.

### Reminders
For the production environments, you must be a member of one of:  
`BU044-ALC-IDCC-Production`  
`BU044-ALC-Conductor`  
`BU044-ALC-Conductor-EU`  
_You'll only get approved for EU access if you reside **in** the EU_

All group membership is managed via [AccessHub](https://ibm-support.saviyntcloud.com/ECM/workflowmanagement/requesthome?menu=1)

## Two-factor authentication set-up 

`2FA` authentication is mandatory for all environments.

Consequently, to access a 2FA-enabled OpenVPN you will need your `SOS-IDMgt` ID and password (from AccessHub) and a ISV registered endpoint 

Follow these simple steps to get setup:

1. Ensure you have followed all the pre-reqs and obtained the correct AccessHub roles.
2. Install the ISV application from the Apple or Andriod store. Refer to [IBM Security Verify App setup guide](https://w3.wdc1a.cirrus.ibm.com/#/support/article/w3id_sso_setup_guides/verify?_lang=en) for installation instructions.

Further documentation is available at [https://w3.ibm.com/w3publisher/2faaas-on-w3id-sso](https://w3.ibm.com/w3publisher/2faaas-on-w3id-sso)


## VPN Client options

There are several different VPN Clients which can be installed and configured. It is down to personal choice how you do this but several examples are given below.

Before configuring, you should pull the VPN client config from the following GHE repos:
- [Ubuntu](https://github.ibm.com/alchemy-conductors/openvpn-clients/tree/static/final-dst-automation)
- [RedHat/Fedora](https://github.ibm.com/alchemy-conductors/openvpn-clients/tree/static/final-dst-redhat)

Consult the SRE team if you have any issues with this.
 
### Network Manager setup
[Network Manager](https://en.wikipedia.org/wiki/NetworkManager) is the standard method for the management of network interfaces on Linux, providing a graphical interface and plugins to manage different types of interfaces. It is available on RHEL and Ubuntu.
If you have the `openvpn` plugins installed you can import your OpenVPN connections to the Linux Network Manager.

1. Make sure the `openvpn` plugin is installed:
    - Ubuntu: https://www.cyberciti.biz/faq/linux-import-openvpn-ovpn-file-with-networkmanager-commandline/
    - RHEL: You need to enable the EPEL repositories.

2. RHEL specific
    - `SELinux` requires that certificates be place under `~/.certs`.
    - The configs files (with embedded certificates within them) may need to be placed into ~/.certs.

3. Import the `openvpn` connections following the instructions [here](https://www.cyberciti.biz/faq/linux-import-openvpn-ovpn-file-with-networkmanager-commandline/)

4. Go to Network Manager connections and for each connection type your USAM username. On the password field there is a little icon on the right bottom corner. Click on that and select `Ask for this password everytime`

5. On the same screen click on the `Advanced` Option under Identity and:
    - make sure you are not restricting the max number of routes. Some environments have more than 200 routes.
    - under the `IPv4` tab make sure to select `Use this connection only for resources on its network`. That will prevent the connection from adding a default route and allow you to use multiple OpenVPN connections.

6. You will be prompted for password when connecting to the chosen VPN. Enter your USAM password and wait for the ISV push notification to appear.

### Alternative OpenVPN client Setup
If the Network Manager instructions above don't work for you (or you are not using network manager) do the following.

1. Install OpenVPN client, e.g.
   - on Ubuntu `sudo apt-get install openvpn`.
   - on RHEL  `sudo yum install openvpn`.

2. Run the command (and leave it running) to start the applicable OpenVPN connection for the environment you want to connect with:  
`sudo openvpn --config <environment-name>.conf`  
_You'll need to enter your sudo password, then your `SOS-IDMgt` system ID and password (from USAM)_

### Tunnelblick setup for MacOS

If working using a Mac you can use the Tunnelblick OpenVPN config tool
- Double click the config files you downloaded in the previous instructions and they will be added to your connections list. 
- Edit each config file to enable 2FA by changing from `auth-user-pass /openvpn/ldap-login.txt` to `auth-user-pass`

Tunnelblick will prompt you for access detail when connecting and you should enter your `SOS-IDMgt` username and credentials (from USAM)

## OpenVPN docker-compose Setup
If you frequently need to access many machines from different environments and do not want to keep switching from one vpn to the next, keep reading. This setup will allow you to run every instance of openvpn concurrently allowing access to all machines. For easiest setup, your `/openvpn/` directory should mirror that of [openvpn-clients](https://github.ibm.com/alchemy-conductors/openvpn-clients). Within the repository you will find some scripts and two sub-folders. The single-containers folder will create single containers that will connect to both the paired infra-vpn servers at random (most common). The double-containers folder will create containers that connect to a specific infra-vpn server (used on alchemy-devtest so that connections can be monitored for uptime).

1. Install docker
   - [instructions for Ubuntu](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/)
   - [instructions for MacOS](https://docs.docker.com/docker-for-mac/install/)

2. Install docker-compose
   - on RHEL `sudo pip install docker-compose`
   - on Ubuntu `sudo apt-get install docker-compose`
   - on MacOS see https://docs.docker.com/compose/install/

3. Restart docker once the file is saved.

4. Go to a directory of your choice and run `git clone git@github.ibm.com:alchemy-conductors/openvpn-clients.git`

5. Go into `openvpn-clients`.

6. You can optionally create a `credentials` file inside this folder with this layout:
    ```
    VUSER=your-sso-id
    VPASS=your-sso-password
    ```
    Without this file you will be asked for your credentials for each logon.

7. Now you can run the `launch-vpn.sh`:
    ```
    Usage: ./launch-vpn.sh <start|stop|status|generate> (<single|multi|automation> (<envname>))
      Script must be run with start, stop, status or generate
      By default single containers are used connecting to a random remote.
      If 'multi' is optionally provided, containers using all remotes are used.
      If 'automation' is provided with 'generate', only config files are created.
      for start/stop/status and single/multi you can provide a single environment
      or a prefix to start any matching env, like prod/stage/prestage...
    ```
    Start single containers with `./launch-vpn.sh start`, just DAL09 with `./launch-vpn.sh start single prod-dal09`.  
    By using a prefix you can launch all matching environments, e.g. `./launch-vpn.sh start single prod`.  
    A push notification will be sent on each connection attempt.

8. To show the status run `./launch-vpn.sh status` / `./launch-vpn.sh status single prod-dal09` / `./launch-vpn.sh status single prod`

9. To stop containers run `./launch-vpn.sh stop` / `./launch-vpn.sh stop single prod-dal09` / `./launch-vpn.sh stop single prod`

**Notes:**
- The repository will be updated frequently to reflect the 2FA status for each environment.
- After a git pull you should run `./launch-vpn.sh generate` to update your configuration.
- The script checks if you use RedHat/Fedora automatically and changes the group automatically.
- Previous single/double/combined folders are now reflected as dst-(single/multi/automation)
- You can start `launch-vpn.sh` from any folder. It's not required to be in a specific folder.

## Exemption and Automation Service Accounts

Some automation scripts and services require VPN access but are unable to be associated with ISV for 2FA authentication. These services must be run through dedicated service accounts that may be exempted from two factor requirements. To gain exemption the account must have membership of the following Accesshub group:
- `BU044-ALC-2FA-EXEMPT`
Note that this exemption is only permitted for automation service accounts and not accounts that belong to an individual. If you are using the docker compose scripts described in the previous section and you are in the exemption group then you can omit providing a 2FA approval when logging in (and re-enable `restart: always` if so desired).

## Common Problems

### Scenario: All my VPN logins to all environments fail  
This probably means your 2FA access has been locked, normally the result of too many failed attempts. This can be confirmed by visiting the [2FAaaS Device Enrollment Portal](https://ibm-device-enroll.prod.identity-services.intranet.ibm.com/ibmenroll#/) and logging in with your intranet creds. You'll likely see a `red` banner stating your account is locked.  
To fix this you have these possibilities:  

- Your account will automatically be unlocked after 60 minutes.  
- If you cannot wait for this period of time, raise a helpdesk ticket requesting your account is unlocked. Follow the instructions [here](https://w3.ibm.com/help/#/article/two_factor_auth/2fa_ov).
- If further help/assistance is needed, then contact the IBM 2FA team in slack [#2faaas-os-level-support](https://ibm-argonauts.slack.com/archives/C5VQC63N3).


### Scenario: Not receiving push notification

- Check your phones push notifications settings
- Check your phone is not in a do not disturb mode - this could be blocking you.

### Account password 
Your SOS user may be locked. You can check your SSO userid status and/or reset your password via AccessHub [here](https://password.sos.ibm.com/default.aspx).

## Further Information
If assistance is needed feel free to reach out to the SRE squad via [#conductors](https://ibm-argonauts.slack.com/archives/C54H08JSK) slack channel, for specific help with two factor authentication please ask in [#conductors-2fa](https://ibm-argonauts.slack.com/archives/CC1JS5KRN) slack channel.


Last review: 2024-03-18
Last reviewer: Hannah Devlin  
