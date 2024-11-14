---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: Covers the way squads should organize their jobs on Jenkins in order to easily be granted access to their jobs.
service: Jenkins
title: Jenkins Squad Security
runbook-name: "Jenkins Squad Security"
link: jenkins/jenkins_squad_security.html
type: Operations
grand_parent: Armada Runbooks
parent: Jenkins
---

Ops
{: .label .label-green}

## Overview

This runbook is meant for squads requesting access to the Alchemy Jenkins instances

## Detailed Information

At the moment, there any many squads using the same Jenkins instance and this might
be causing some unexpected issues. In order to prevent accidents (e.g. modifying
or running jobs belonging to other squads), we will be restricting access for each squad
to only what is necessary.

By default, everybody who is logged in will only be able to browse through the jobs,
but without any extra access. Each squad will be give full access to a specific folder,
where jobs and sub-folders can be created and organized as needed. Unfortunately,
Jenkins does not allow access set based on tabs, which would have made things easier.


### Jenkins instances

At the moment of writing this runbook, we have the following Jenkins instances:

  * [Conductors Jenkins](https://alchemy-conductors-jenkins.swg-devops.com/)
  * [Containers Jenkins](https://alchemy-containers-jenkins.swg-devops.com/)
  * [Testing Jenkins](https://alchemy-testing-jenkins.swg-devops.com/)

## Detailed Procedure

1. All members of a squad should be members of a specific bluegroup, so create one if you don't already have it.

2. Each squad should create a top-level folder where all their jobs and sub-folders can be moved.

    1. In order to create a folder, go to the appropriate Jenkins as listed above
    2. Go to the tab where you want your folder to be created.
    3. On the left-hand side menu, click on the New Item option.
    4. Pick "Folder" from the list of checkboxes and pick a name in the "Item Name" field.
    5. Your folder should now be created in the tab you chose.

3. Move all the jobs/folders required by your squad in the folder created in step (2). For each job/folder you need moved:

    1. Click on the job/folder.
    2. On the left-hand side menu, you should have a "Move" option. Click it.
    3. Pick the folder you created in step (2) and click "Move".

4. Open a [GHE Conductors/Team issue](https://github.ibm.com/alchemy-conductors/team/issues/new?template=jenkins_enquiry.md) stating 

    1. The bluegroup of your squad. (step 1)
    2. The folder that you own. (step 2)
