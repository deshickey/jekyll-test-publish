---
playbooks: [<NoPlayBooksSpecified>]
layout: default
title: Privileged Access Gateway(PAG) - Break the glass scenarios
type: Informational
runbook-name: "Privileged Access Gateway(PAG) - Break the glass scenarios"
description: "Privileged Access Gateway(PAG) - Break the glass scenarios"
service: Conductors
link: /docs/runbooks/pag/pag_break_the_glass_scenarios.html
grand_parent: Armada Runbooks
parent: PAG
---

Informational
{: .label }

# Break the glass scenarios for Privileged Access Gateway(PAG) installation in FS Cloud

## Overview

This Document is used when GP VPN is not available, PAG endpoints are not accessible, IAM ID login failure due to IAM verification down.

The breakout Glass scenario would leverage Chlorine interactive mode, SL VPN and openVPN

## Detailed Information

### Scenario 1 - Chlorine Interactive

If GP VPN is not working:

#### Slackbot

    1. Go to **Slack**
    2. Add _Chlorine bot (Igorina) (SRE)_ by searching for Chlorine in the search bar if not already done
    3. Use _interactive_ mode to issue commands to run on an instance  
        **Example:** `interactive prod-ams03-carrier1-master-01 outage:0m`
    4. This opens interactive session with the machine for *30 mins*. Some example commands are:

        ```bash
        kubectl <cmd> <args> [ | grep <string> ]
        kubx-kubectl <clusterid> <cmd> <args>
        armada-get-cordoned-nodes  [| grep <string>]
        ```

    5. Type `help interactive` to get list of all commands that can be use in interactive mode.
    6. Type `help` to get list of all commands/modes supported by the bot

Information on accessing EU nodes from slackbot can be found in this [runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/conductors_eu_cloud_iks.html)

### Scenario 2 - SL VPN Access

To access VSI and BM with Softlayer VPN, please follow [runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/kvm_access.html)

### Scenario 3 - OpenVPN access
This scenario is where production env access is required from OpenVPN. Change Request (CHG) needs to be created and approved
1. Prod CHG
    1. [ServiceNow](https://watson.service-now.com/)
    1. Navigate to **Change** > **Create New**
    1. select **Normal, Emergency, or Standard** changes
    1. Get approval of CHG from # cfs-prod-trains

2. Prod Ops CHG
    ```
    PROD TRAINS OPS Template:
    Squad: operations
    Title: Promote <microservice>:<build> to prod
    Environment: <Region list stage-us-south etc>
    Details: |
    Update microservice <insert microservice name here>
    <description of change >
    Risk: <high, med or low>
    PlannedStartTime: <YYYY-MM-DD HH:MM -ZZZZ or 2018-04-23 10:30 -0500>
    PlannedEndTime: <2018-04-23 10:30 CST or 2018-04-23 10:30 GMT or now + 30m >
    Ops: true
    BackoutPlan: <description of what the plan is if the deploy goes badly>
    ```
3. Use Tunnelblick to connect to the respective environment. Refer this [link](https://github.ibm.com/alchemy-conductors/team/wiki/Connect-to-nodes-and-tugboat-from-a-mac-using-tunnelblick-and-DUO) for Tunnelblick and DUO install, setup.

4. Select the environment which you want to connect
   <br />
   <a href="../images/conductors/tunnelblick.png"><img src="../images/conductors/tunnelblick.png" style="width: 300px;"/></a>
5. Enter SOS ID username and password, 

6. Look for prompt in ISV app in your mobile and choose Approve

7. A successful connection will look like as below,
   <br />
   <a href="../images/conductors/tunnelblick_success.png"><img src="../images/conductors/tunnelblick_success.png" style="width: 300px;"/></a>

8. Open a terminal and enter the appropriate login creds as below,
   ```
   $ ssh 10.221.95.117 # if localusername is same as SOS ID:
   $ ssh <SOS_ID>@10.221.95.117 # if NOT,
   ```
   <br />
   <a href="../images/conductors/tunnelblick-conn-server.png"><img src="../images/conductors/tunnelblick-conn-server.png" style="width: 500px;"/></a>

## Reference

### Open a support ticket

Engage the Bastion team for support by opening a ServiceNow ticket

1. Open the ServiceNow webpage: [ServiceNow Queue](https://watson.service-now.com/ess_portal?id=sc_cat_item&sys_id=b0c4fefcdbe75b0072583c00ad96199e&sysparm_category=3375fa30db2b5b0072583c00ad9619e3%23)
2. Fill in the following details  
   *Assignment Group:* `Infrastructure Security and Protection`  
   *Severity:* `Sev - 1`  
   *C_Code:* `BMX`  
   *Short Description:* `The title of your problem e.g. IAM is down, not able to authenticate to bastion`  
   *Description:* `Please provide your account number, a briefly description of your environment and of your problem`  
   *Add to watchlist:* `The people you want to have into the loop (they will receive an email notification)`
3. Click on **Submit**
