---
layout: default
description: How to diagnose security compliance issues with Armada workers.
title: How to diagnose security compliance issues with Armada workers.
service: armada-bootstrap
runbook-name: "How to diagnose security compliance issues with Armada workers"
tags: alchemy, armada, worker, security, compliance, patch, nessus, qradar, health, check, healthcheck
link: /armada/armada-worker-compliance-issues.html
type: Informational
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview
This runbook describes how the SRE team should diagnose incoming tickets relating to security compliance issues with Armada worker images, such as:

- Failing health checks
- Nessus vulnerability findings
- Missing patches
- Workers not reporting BigFix status
- Workers not sending logs to QRadar

It's important to understand that the status of an Armada worker due to a combination of:

1. How the Armada worker image was originally built by the Armada Bootstrap squad.
2. Whether the Armada worker image was successfully installed onto the worker.
3. How the `ibmcloud csutil` tool that installs the SOS compliance tooling has modified the worker.
4. Whether the SOS compliance tools are functioning correctly and report the right status.
5. How the team that owns the worker may have modified it, for example by deploying Kubernetes daemonsets or privileged containers that change the underlying worker at the OS level.

For this reason, identifying the root cause of a compliance issue can be complex. This runbook describes some steps to follow to help identify root cause.

## Detailed Information

Here is the procedure for the Armada SRE squad to follow to diagnose Armada worker compliance issues. The expectation is that the SRE squad will take these steps, with the goal of filtering out noise caused by user error so that we only send genuine issues to Armada bootstrap, Security Focal or other Armada squads.

The term "user" relates to the Armada-based service reporting the issue.

1. Label the incoming issue with the `Armada-Worker-Compliance` label so that such issues can be tracked.

2. First, validate that the user is on the latest worker version. Ask the user to supply evidence of `bx cs workers CLUSTERNAME` output or screenshots of the UI panels showing the worker version string. A worker version string is something like `1.9.8_1517` where the first prefix is the Kubernetes version and the suffix is a unique number. Here is an example:

    ```
    ID                                                 Public IP        Private IP      Machine     Type   State    Status   Zone    Version   
    kube-hou02-pab5e14ad00b4d4ee8b3c2abd67134a392-w1   173.193.99.228   10.77.159.109   free               normal   Ready    hou02   1.9.8_1517* 
    ```

    Note the presence of the asterisk after the version indicating that this worker is not at the latest version. Any workers not at the latest version should first be upgraded.

3. BigFix lags in detecting changes. The user must wait at least 24 hours after making any worker node change before reporting an issue with the worker version to SRE.
    - In the interim, we recommend the user opens a GHE issue in their own local repository to track the issue first, as this can be used as evidence of the date of awareness for audit purposes while waiting for BigFix to update.
    - The user may also wish to open an exception to cover themselves for any temporary non-compliance until the issue is resolved. Each service must have a Security Focal who is responsible for doing so; in the first instance the user's Security Focal would be expected to do that.

4. What has the user done to change the workers, e.g. using SSH login or deploying daemonsets or privileged containers to alter the worker itself? They should provision an additional worker without applying any custom changes to demonstrate that the issue is reproducible on an unmodified worker. Although we should not reject issues solely because a modification was made, issues found to be caused by the user's modifications to a worker are the user's responsibility and will not be supported by the Armada teams.

5. In most cases, as advised above, the user should seek an exception through their Security Focal to cover the non-compliance for a temporary period. It is also recommended that the user raises their own GHE ticket in their local GHE repository to demonstrate early awareness for audit purposes.

6. Review the Common Issues section below and take the appropriate steps for the type of issue reported. If the problem appears to be a genuine issue not caused by user error then handle appropriately.

7. For any issue not identified in the Common Issues section below, if you need futher guidance please discuss with the Armada Security Focal in the #sre-compliance Slack channel.

## Common Issues

### Failing health check

1. Is it a known issue listed on [this SOS wiki page](https://w3-connections.ibm.com/wikis/home?lang=en#!/wiki/W50576e433cea_4fbb_84ed_ec8a855405e4/page/Armada%20Healthcheck%20Exceptions)? If so we have exceptions in place and they can ignore it, although we should check [here](https://w3.sos.ibm.com/inventory.nsf/health_check_exceptions.xsp?c_code=armada) to ensure the necessary exceptions are correctly defined in the SOS tools. If a missing exception is identified, raise an issue in https://github.ibm.com/alchemy-conductors/alcatraz/issues/ (or move the incoming GHE issue to there) and inform the Armada Security Focal.

2. Is there reason to believe the issue is a false positive? If so, follow [these instructions](https://w3-connections.ibm.com/wikis/home?lang=en#!/wiki/W50576e433cea_4fbb_84ed_ec8a855405e4/page/How%20to%20file%20a%20false%20positive).

    Note: use [running commands on worker nodes runbook](./armada-run-commands-on-workers.html) to safely gain access to IKS worker nodes.

### Nessus vulnerability finding

1. Pay close attention to the IP address and port number of the finding. Also each IP address can be of a different type: in the SOS inventory each IP could be:
    - BEN = back-end network, the primary private IP of the worker
    - FEN = front-end network, the primary public IP of the worker
    - IMM = IPMI controller management IP (bare metal workers only)

2. For a finding on an IMM IP, this is due to the IPMI controller used to manage reboots and provide emergency KVM Console access to the machine and has nothing to do with the Armada worker image. The IPMI firmware of many devices has known security vulnerabilities, in fact SoftLayer often provision machines with outdated firmware. Consider upgrading the IPMI firmware (note: this will cause a machine outage of 2-3 hours) and also consider what IPMI functions are needed by the user. See [this wiki page](https://w3-connections.ibm.com/wikis/home?lang=en#!/wiki/W50576e433cea_4fbb_84ed_ec8a855405e4/page/Common%20Scan%20Findings%20%26%20Solutions) for more details about common IPMI findings and recommended actions.

3. If the finding relates to ports 30000-32767 then this is a NodePort belonging to something that the user is running on the worker and has nothing to do with the Armada worker image. Refer to the [Armada documentation](https://console.bluemix.net/docs/containers/cs_nodeport.html#nodeport) for more details about NodePorts. The user must identify what is running on the NodePort and take appropriate action as per the Nessus output.

4. For other findings, run `kubectl get services --all-namespaces=true` and check the output to identify what is listening. Match the External IP and port number to the details in the Nessus finding.
    - Services in the `kube-system` namespace were set up by Armada on the user's behalf. Ask in the #armada-users Slack channel for directions.
    - Services in the `ibm-kubeprofile-system` namespace were set up by the `bx csutil` tool on the user's behalf. Ask in the #sos-armada Slack channel for directions.
    - Most other services are likely to belong to the user and are the user's responsibility.

### Missing patch

Important notes:

1. At the time of writing (August 2018) there is a known issue where the frequency of release of Armada worker images doesn't align with the ITSS patch deadline requirements.

2. There is also a known issue where BigFix does not correctly report patch severity for Ubuntu (which is the basis for the Armada worker images). As a result, most Ubuntu patches end up classified as Medium risk and are due within 14 days (or less for FFIEC systems).

These issues are actively under review between Armada and the Compliance and Audit Readiness team, however there is no quick fix on the horizon. At present the Armada team expect to release a new image at least once per month but cannot guarantee anything more frequent.

With this being the case, the user will likely need to seek an exception through their Security Focal to cover any short-term non-compliance until the broader issues can be resolved.

### Workers not reporting BigFix status

1. Ensure that `bx csutil` has been run to onboard the cluster in question.

2. Even if previously run, try re-running `bx csutil` to see if this fixes it.

3. BigFix can take up to 24 hours to return results. Wait at least 24 hours after (re)running `bx csutil` for results to arrive.

4. If still no results, discuss in the #sos-armada Slack channel. The team there will be able to advise where to raise any follow-up GHE issues.

### Workers not sending logs to QRadar

1. Ensure that `bx csutil` has been run to onboard the cluster in question.

2. Even if previously run, try re-running `bx csutil` to see if this fixes it.

3. BigFix can take up to 24 hours to return results. Wait at least 24 hours after (re)running `bx csutil` for results to arrive.

4. If still no results, discuss in the #sos-armada Slack channel. The team there will be able to advise where to raise any follow-up GHE issues.

## More Help
If SRE suspect an issue with the `bx csutil` security compliance onboarding tool, discuss in the #sos-armada Slack channel. The team there will be able to advise where to raise any follow-up GHE issues.

If SRE suspect an issue with how the Armada worker image is built, discuss in the #armada-bootstrap Slack channel. Follow-up GHE issues can be raised in https://github.ibm.com/alchemy-containers/armada-bootstrap/issues/ provided we have done sufficient analysis to indicate that the problem lies in the image itself.

If SRE need guidance on handling an issue, ask in the #sre-compliance Slack channel.