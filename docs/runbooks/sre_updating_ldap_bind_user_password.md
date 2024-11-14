---
layout: default
description: Runbook detailing how to update the LDAP Bind User(s) (bindbu044-*) password(s)
service: "Infrastructure"
title: How to update the LDAP Bind User passwords
runbook-name: Runbook detailing how to update the LDAP Bind User(s) (bindbu044-*) password(s)
link: /sre_updating_ldap_bind_user_password.html
type: Troubleshooting
failure: ["Runbook needs to be Updated with failure info (if applicable)"]
playbooks: [<NoPlayBooksSpecified>]
parent: Armada Runbooks

---

Troubleshooting
{: .label .label-red}

## Overview

How to change and then update the relevant tools when the `bindbu044-*` user passwords are about to expire.

The password needs to be reset every 365 days.

## What are these userids used for?

Connected to the `alchcond` functional id are a number of SOS users:

```
bindbu044
bindbu044-dev
```

The LDAP bind user is used by all of ALC and ALC_FR2 machines, to authenticate to LDAP servers.

The user credentials are currently stored in [armada-secure](https://github.ibm.com/alchemy-containers/armada-secure/blob/master/secure/conductors/dev/bootstrap-one-server.yaml#L18-L19) (with similar entries in the other regional files under [armada-secure/tree/master/secure/conductors](https://github.ibm.com/alchemy-containers/armada-secure/tree/master/secure/conductors))

There are two secrets:
```
    data:
      LDAP_AUTH_TOKEN: (( grab $BOOTSTRAP_ONE_LDAP_AUTH_TOKEN_MAIN_YYYYMMDD_64 ))
      LDAP_AUTH_TOKEN_ALTERNATE: (( grab $BOOTSTRAP_ONE_LDAP_AUTH_TOKEN_ALTERNATE_YYYYMMDD_64 ))
```

The `LDAP_AUTH_TOKEN` is the password of the `bindbu044` user.

The `LDAP_AUTH_TOKEN_ALTERNATE` is the password of the `bindbu044-dev` user.

The cluster-updater service then makes the secrets available, and they are consumed by the [bootstrap-one-server](https://github.ibm.com/alchemy-conductors/bootstrap-one-server#adding-new-secrets) microservice, which runs in multiple clusters in the Alchemy Support 278445 account.

The secrets are put into the [secrets.env](https://github.ibm.com/alchemy-conductors/bootstrap-one-server/blob/5125365ee6b366f48a0ad1b3f4e0700edce71131/etc/secrets.env#L7-L8) file.

The secret is configured on each machine via the `ldap_auth_token` parameter to the bootstrap-one ansible in [run.sh](https://github.ibm.com/alchemy-conductors/bootstrap-one/blob/60a5e13d78797571985482ac8a65e4551e2f745c/scripts/run.sh#L26)

[bootstrap-one](https://github.ibm.com/alchemy-conductors/bootstrap-one/blob/9fc4652b121b184850573935b06c012f330972d7/playbooks/roles/usam/templates/sssd.conf.j2#L51) then places the `ldap_auth_token` value into `/etc/sssd/sssd.conf`


## Example alerts

- [#65803287 Users with password expiry approaching or locked out identified](https://ibm.pagerduty.com/incidents/Q1PR11FCB4NXKU)

We will receive a pagerduty alert when the ID is about to expire.

## Initial actions

**This procedure will take a couple of weeks to fully complete, and must be started as soon as possible.**

Raise a [Conductors team ticket in GHE with the relevant template](https://github.ibm.com/alchemy-conductors/team/issues/new?assignees=&labels=interrupt&projects=&template=password_rotation_ldap_bind_user.md&title=Users+with+password+expiry+approaching+or+locked+out+identified+-+ldap_bind_user) to track the password update.


## Detailed information

We must process the ID reset in a timely manner or risk issues with VPN connections in our bots.

## Investigation and Action

The alert will bring you to this page. Review which user password(s) are about to expire and rotate them one-by-one.

## Reset and update the password 

_**Careful planning is required as the process will involve re-deploying armada-secure and bootstrap-one-server.**_


The two secrets (`LDAP_AUTH_TOKEN` and `LDAP_AUTH_TOKEN_ALTERNATE`) are made available to allow for password updates to be made on a rolling basis:
- Usually **only one of the two secrets is active at any time**. For example say that `LDAP_AUTH_TOKEN` for `bindbu044` is currently active.
- The **other** secret (`LDAP_AUTH_TOKEN_ALTERNATE` for `bindbu044-dev` in this example) is updated (when it gets close to its expiry)
- The secret must be updated in armada-secure. This takes time to get approved and to promote - **at least some days**. [Example](https://github.ibm.com/alchemy-containers/armada-secure/pull/8725)
- Once the new secret in armada-secure has been rolled out to all regions, we can then start to update bootstrap to use the new value.
- Make the relevant changes to bootstrap-one and bootstrap-one-server to start introducing the **newly changed** secret.
  - Update the `ldap_auth_user` value in bootstrap-one to be the other user (`bindbu044-dev` in this example)
  - Update the [run.sh](https://github.ibm.com/alchemy-conductors/bootstrap-one/blob/60a5e13d78797571985482ac8a65e4551e2f745c/scripts/run.sh#L26) script to change from `-e ldap_auth_token="${LDAP_AUTH_TOKEN}"` to `-e ldap_auth_token="${LDAP_AUTH_TOKEN_ALTERNATE}"` (or vice versa, as appropriate).  [Example](https://github.ibm.com/alchemy-conductors/bootstrap-one/pull/904)
  - Merge and promote the change to bootstrap-one; then create the bootstrap-one-server change per the [README](https://github.ibm.com/alchemy-conductors/bootstrap-one#promotion).
  - As the change rolls out from dev to prod, both the old (still valid) username/password combination and the new username/password combination are in use at the same time. This will take **at least 1 week** to fully roll out.
- When rollout completes and all ALC/ALC_FR2 machines are fully bootstrapped, then the old password is no longer in use. It may be rotated next time and repeat the swapping process.


## Escalation policy

If you are unsure then raise the problem further with the SRE team.

Discuss the issues seen with the SRE team in `#conductors-for-life` or `#sre-cfs` if you have access to these private channels.

There is no formal call out process for this issue.

