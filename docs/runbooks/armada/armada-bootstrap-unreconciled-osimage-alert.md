---
layout: default
description: How to resolve unreconciled osimage alerts 
title: armada-bootstrap-unreconciled-osimage-alert - How to resolve unreconciled osimage alerts
service: armada-bootstrap
runbook-name: "armada-bootstrap-unreconciled-osimage-alert - How to resolve unreconciled osimage alerts"
tags:  armada, armada-bootstrap
link: /armada/armada-bootstrap-unreconciled-osimage-alert.html
type: Alert
parent: Armada
grand_parent: Armada Runbooks
---

Alert
{: .label .label-purple}

## Overview
This runbook contains steps to take when debugging bootstrap unreconciled os image alerts

## Example Alert(s)

~~~~
labels:
  alert_key: armada-infra/armada-bootstrap-metadata-alert
  alert_situation: armada_bootstrap_unreconciled_osimage_alert
  service: armada-bootstrap
  severity: warning
annotations:
  description: Armada bootstrap unreconciled os image alert firing
~~~~

## Actions to take

This alert means that there is an issue with the image our classic workers specify on provision or reload.

1. Determine the provider for the flavor

    Check whether the provider is `softlayer` or `g2`.

2. Check LogDNA

    Take a look in the armada-cluster logs and check if one of these error messages can be found relating to the flavor. To do this, go to the affected region's LogDNA, use `default-view` in `CLUSTER-SQUAD`, search for the statement `ErrorUnreconciledOSImage "level":"error"` and look at the `msg` field.


    Errors looking up the specified image template:

    - `Image specified by name not found`

    - `No image ID provided`

    - `Image template not found for global identifier`

    - `Multiple image templates found for global identifier`

    Errors with the specified image template found:

    - `The found image template does not have the expected global identifier`

    - `The found image template does not have an ID set`

    Take note of the image guid, which will look something like [this](https://github.ibm.com/alchemy-containers/armada-bootstrap/blob/develop/scripts/armadaansibleversionedboms/boms/1.28/1.28.2_1533/provisioninfo_softlayer_virtual_UBUNTU_20_64_25GB#L2).

3. Check if that image exists.

    - For `softlayer`: 
      - Check if the global image exists through `ibmcloud sl image detail <image-guid>`. Make sure status is Active and visibility is Public.
        Example: 
    ```
    slcli image detail 02a188a1-093f-40ab-8eec-fd50b4e5f043

    :....................:......................................................................................................................................................................:
    :               name : value                                                                                                                                                                :
    :....................:......................................................................................................................................................................:
    :                 id : 12805620                                                                                                                                                             :
    :  global_identifier : 02a188a1-093f-40ab-8eec-fd50b4e5f043                                                                                                                                 :
    :               name : UBUNTU_20_04_64_25GB_CONTAINER_SERVICE_0.0.81                                                                                                                        :
    :             status : Active                                                                                                                                                               :
    : active_transaction :                                                                                                                                                                      :
    :            account : 1185207                                                                                                                                                              :
    :         visibility : Public                                                                                                                                                               :
    ```
    - For `g2`:
      - Check if the image exists in the SRE accounts. 
        - We have automation to do this, follow step 1 here to verify vpc images: https://github.ibm.com/alchemy-containers/armada-bootstrap-squad/blob/master/Informational/promotions/Testing/testing-steps.md#production-testing

4. If all the images exists, open an issue with bootstrap [here](https://github.ibm.com/alchemy-containers/bootstrap-squad/issues/new) to investigate during normal business hours. 

5. If the image does not exist, raise a pCIE and escalate to armada-bootstrap:
    - Impact is, in the region the alert is triggering in, that operating system will not be able to be provisioned for the provider it is alerting on. 
      - For example: `Region: jp-tok, Provider: g2, OperatingSystem: Ubuntu20. VPC IKS Clusters worker provisioning issues in region jp-tok are impacted.`
    - Provide information on the infrastructure provider and the error message being seen.


## Escalation Policy
Please follow the [escalation guidelines](./armada-bootstrap-collect-info-before-escalation.html) to engage the bootstrap development squads.
