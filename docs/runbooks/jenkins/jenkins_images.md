---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: How to update/pull the images that Jenkins uses onto the individual Jenkins slaves.
service: Jenkins
title: How to update images on the Jenkins slaves
runbook-name: "How to update images on the Jenkins slaves"
link: jenkins/jenkins_images.html
type: Informational
grand_parent: Armada Runbooks
parent: Jenkins
---

Informational
{: .label }

## Overview

What follows is the process to update docker container images used by Jenkins as node labels

## Detailed Information

Jenkins runs all of its jobs in Docker containers. That means that when we want to add some new functionality or update some packages in the images (e.g. java 7 -> java 8), we need to follow these steps until the images end up in Jenkins:

  1. Raise a pull request against the [pipeline-build git repo](https://github.ibm.com/alchemy-conductors/pipeline-build/) with the changes.
  2. Merge the PR.
  3. Build the images using the [Build_Docker_Images](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Conductors-Jenkins/job/Build_Docker_Images/) job.
  4. Get those images downloaded to the appropriate slaves using the steps below.

### want to test?

If there is a need to test the Dockerfile, eg a brand new Node Label is in the process of being setup then this job [Canary_Infrastructure_dockerbuild_artifactory](https://alchemy-conductors-jenkins.swg-devops.com/viewI/Conductors/job/Conductors/job/Conductors-Jenkins/job/Canary_Infrastructure_dockerbuild_artifactory/) can be used

**BUT** first, make sure the image was pulled by passing it as a parameter in this job [Pull-slave-images](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Jenkins/job/Pull-slave-images/)
  
## Jenkins instances

At the moment of writing this runbook, we have the following Jenkins instances:

  * [Conductors Jenkins](https://alchemy-conductors-jenkins.swg-devops.com/)
  * [Containers Jenkins](https://alchemy-containers-jenkins.swg-devops.com/)
  * [Testing Jenkins](https://alchemy-testing-jenkins.swg-devops.com/)

The steps for updating the images in the two instances are different because we have a nice Ansible setup in Hursley, which does not exist in the US instance. However, both methods will basically pull down all of the images Jenkins uses within that respective instance. If there has been a new type of image created (e.g. someone wants an image with PHP in it), then it will need to be added to the job.

## Updating images in the Jenkins instances

Updating the images for **all** Jenkins instances can be done via the [Pull-slave-images](https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Conductors-Jenkins/job/Pull-slave-images/) job. You simply need to provide the tag for the images as a parameter. The default is 'latest'

If you have some new image to add, look in the job configuration.

## Escalation

  * @interrupt in #conductors
  * @taas_squad in #taas-jenkins-help