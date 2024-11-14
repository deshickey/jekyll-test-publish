---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: Jenkins ImagePull Secret Rotation
service: Jenkins
title: Jenkins ImagePull Secret Rotation
runbook-name: "Jenkins ImagePull Secret Rotation"
link: jenkins/jenkins-imagepull-secret-rotation.html
grand_parent: Armada Runbooks
parent: Jenkins
---

Informational
{: .label }

## Overview

This document contains the steps to rotate the imagePull secrets used on Jenkins on Kubernetes (Jonk) for IKS Jenkins Clusters.


## Detailed Information

### Create new Artifactory Token.
1. Setup your authenticator app for alconbld@uk.ibm.com
(use [Thycotic to get password](https://pimconsole.sos.ibm.com/SecretServer/app/#/secrets/54951/general) - refer to [documentation](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/shared_user_ID_login.html#making-use-of-a-shared-user))

2. Login to https://na.artifactory.swg-devops.com using alconbld@uk.ibm.com (use [w3 password from Thycotic](https://pimconsole.sos.ibm.com/SecretServer/app/#/secret/27710/general))

3. Navigate to [user_profile](https://na.artifactory.swg-devops.com/ui/admin/artifactory/user_profile) and Click On `Generate an Identity Token`. Copy it.

### Update the Token Value at Required Places.
1. Update [alchemy-conductors-jenkins JFROG_ACCESS_TOKEN_GENERATING_TOKEN](https://pimconsole.sos.ibm.com/SecretServer/app/#/secret/88188/general) value in Thycotic. Make sure to update the `Notes` Section with new `Renewed Date` and
`Expiry Date`.

2. Update the credential [alconbld-sre-jenkins-JFROG_ACCESS_TOKEN_GENERATING_TOKEN](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/credentials/store/folder/domain/_/credential/alconbld-sre-jenkins-JFROG_ACCESS_TOKEN_GENERATING_TOKEN/update) in Jenkins.
  - Click on `Change Password` and update with new value.
  - Update `Description` with new expiry date.

### Update and Rotate the Secret for `namespace-credential-injection` job.
- Update the secret credential value in all 3 jenkins instances with newly created token, and trigger `namespace-credential-injection` job for each.

1. Testing Jenkins Instance :
- Update the `Password` value in [artifactory-readonly-apikey-testing](https://alchemy-testing-jenkins.swg-devops.com/manage/credentials/store/system/domain/_/credential/artifactory-readonly-apikey-testing-Feb-2024/update) and `save` it.
- Trigger [namespace-credential-injection](https://alchemy-testing-jenkins.swg-devops.com/job/jenkins-configuration/job/namespace-credential-injection/) Job.
- Set the `Label Expression` to `dockerbuild18-deploy-squad-base-taas-cluster-large` in [test-build-images-labels](https://alchemy-testing-jenkins.swg-devops.com/job/Conductors/job/test-build-images-labels/configure) or set it to any other used label from [labelsdashboard](https://alchemy-testing-jenkins.swg-devops.com/labelsdashboard/) and trigger that job to confirm that it's able to pull images with new secret.

2. Containers Jenkins Instance :
- Update the `Password` value in [artifactory-readonly-apikey-us-east](https://alchemy-containers-jenkins.swg-devops.com/manage/credentials/store/system/domain/_/credential/artifactory-readonly-apikey-us-east-Feb-2024/update) and `save` it.
- Trigger [namespace-credential-injection](https://alchemy-containers-jenkins.swg-devops.com/view/All/job/jenkins-configuration/job/namespace-credential-injection/) Job.
- Set the `Label Expression` to `dockerbuild-local-fix-18-taas-cluster` in [test-jonk1](https://alchemy-containers-jenkins.swg-devops.com/view/Conductors/job/ConductorTestFolder/job/test-jonk1/configure) or set it to any other used label from [labelsdashboard](https://alchemy-containers-jenkins.swg-devops.com/labelsdashboard/) and trigger that job to confirm that it's able to pull images with new secret.

3. Conductors Jenkins Instance :
- Update the `Password` value in [artifactory-readonly-apikey-conductors](https://alchemy-conductors-jenkins.swg-devops.com/manage/credentials/store/system/domain/_/credential/artifactory-readonly-apikey-conductors-Feb-2024/update) and `save` it.
- Trigger [namespace-credential-injection](https://alchemy-conductors-jenkins.swg-devops.com/view/all/job/jenkins-configuration/job/namespace-credential-injection/) Job.
- Set the `Label Expression` to `auditree-without-vpn-taas-cluster` in [test-any-label-image](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/IKS-BASTION/job/test-any-label-image/configure) or set it to any other used label from [labelsdashboard](https://alchemy-conductors-jenkins.swg-devops.com/labelsdashboard/) and trigger that job to confirm that it's able to pull images with new secret.


### Rotate the Jenkins Pull Secret using newly created Token.
- We have created [jenkins-imagepull-secret-rotate](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Conductors-Infrastructure/job/jenkins-imagepull-secret-rotate/) Job that is used to rotate the imagePull Secrets in Jenkins Clusters.

- There are 2 Jenkins Clusters present in `Alchemy Support Account`. [Build the Job](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Conductors-Infrastructure/job/jenkins-imagepull-secret-rotate/build?delay=0sec) by selecting the cluster from drop-down for both clusters one by one.
  - jenkins-privileged-us-east (cev4g5fw0vk2tu320510) - Us-East Jenkins Cluster.
  - jenkins-privileged (ccrfe9qf0i5no3ufe40g) - Frankfurt Jenkins Cluster.

- [jenkins-imagepull-secret-rotate](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Conductors-Infrastructure/job/jenkins-imagepull-secret-rotate/) Job is used to rotate the secrets as per below.
1. jenkins-privileged-us-east (cev4g5fw0vk2tu320510)
  - `secret-kube-containers-jenkins-on-cluster-us-east-new` in `kube-containers-jenkins` namespace
  - `secret-kube-conductors-jenkins-on-cluster-us-east-new` in `kube-conductors-jenkins` namespace

2. jenkins-privileged (ccrfe9qf0i5no3ufe40g)
  - `secret-kube-testing-jenkins-on-cluster-frankfurt-new` in `kube-testing-jenkins` namespace
  - `secret-kube-containers-jenkins-on-cluster-frankfurt-new` in `kube-containers-jenkins` namespace
  - `secret-kube-conductors-jenkins-on-cluster-frankfurt-new` in `kube-conductors-jenkins` namespace

#### New pull secret is valid for 90 days only. Set a Remainder 1 week before the expiry date and make sure to follow this Runbook again before it expires.

### Further Information
Jenkins instances:
  * [Conductors Jenkins](https://alchemy-conductors-jenkins.swg-devops.com/)
  * [Containers Jenkins](https://alchemy-containers-jenkins.swg-devops.com/)
  * [Testing Jenkins](https://alchemy-testing-jenkins.swg-devops.com/)

## Escalation

  * @interrupt in #conductors
  * @taas_squad in #taas-jenkins-help
