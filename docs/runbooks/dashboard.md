---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: Runbook needs to be updated with description
service: Runbook needs to be updated with service
title: Alchemy Dashboard documentation
runbook-name: Alchemy Dashboard documentation
link: /dashboard.html
type: Archival
parent: Armada Runbooks
---

Archival
{: .label .label-red}

This document provides information on the Alchemy dashboard. It includes dashboard structure, dashboard git projects, dashboard builds, dashboard systems, and actions to take when the dashboard is not responding.


## Overview
The Alchemy dashboard acts as a proxy server to access information about running systems, services, and applications. These include infrastructure logs via kibana, Uptime and Sensu events, and logmet logs and metrics via kibana and grafana. The dashboard provides this access without requiring the user to have specific VPN access, and in some cases login credentials, to these resources. General access to the dashboard is controlled via an IBM Bluegroup.

## Detailed Information

### Dashboard git projects
The foundation of the Alchemy dashboard is based on code obtained from the Internet of Things group. The dashboard makes use of the following git projects during it's build and deploy process:

* dashboard-build - build component for the Alchemy dashboard.
* dashboard-image-jekyll - jekyll component for the Alchemy dashboard
* dashboard-image-base-ubuntu - base ubuntu component for the Alchemy dashboard
* dashboard-image-apache - Apache component for the Alchemy dashboard
* dashboard-image-monitoring - dashboard component for the Alchemy dashboard
* documentation-pages - runbook and html components for the Alchemy dashboard
* dashboard-vpn - VPN component for the Alchemy dashboard

### Dashboard hosts and containers
Multiple versions of the the Alchemy dashboard are hosted on two systems located in Hursley. The Alchemy dashboard itself is a docker container and uses other containers for VPN connections. The systems and containers are listed below:

* alchemy-devtest.hursley.ibm.com - this system hosts the devtest and staging Alchemy dashboards.
	* monitoring-dashboard-dev - Alchemy devtest dashboard container - https://alchemy-devtest.hursley.ibm.com:10443
	* monitoring-dashboard-staging - Alchemy staging dashboard container - https://alchemy-staging.hursley.ibm.com		
	* vpndal09 - VPN container for connecting to Production-DAL09 and Staging-DAL09
	* vpnlon02 - VPN container for connecting to Production-LON02
	* vpnbeta - VPN container for connecting to Devtest-DAL09
* alchemy-prod.hursley.ibm.com - this system hosts the production Alchemy dashboard.
	* monitoring-dashboard-production - Alchemy production dashboard container - https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/process
	* vpndal09 - VPN container for connecting to Production-DAL09 and Staging-DAL09
	* vpnlon02 - VPN container for connecting to Production-LON02
	* vpnbeta - VPN container for connecting to Devtest-DAL09

### Dashboard builds
The following builds under Conductors in Jenkins can be used to deploy an Alchemy dashboard:

* Build-Dashboard-New - this job can build any dashboard on supported hosts and can use different git branches for certain projects
* Build-Dashboard-Production-Master - this job builds the Alchemy production dashboard on alchemy-prod.hursley.ibm.com. It is invoked via a webhook when a push is done to the git documentation.pages project and uses just master branches.
* Build-Dashboard-Staging-Master - this job builds the Alchemy staging dashboard on alchemy-devtest.hursley.ibm.com. It is invoked via a webhook when a push is done to the git documentation.pages project and uses just master branches.

### Important files and directories within the dashboard git projects
The following files and directories contain key information for the dashboard and are updated frequently when changes need to be made to the dashboard:

* iotcloud.image.monitoring-dashboard
	* deploy-monitoring-dynamic.xml - the ant build file used by the Jenkins dashboard builds
	* Dockerfile - sets the list of endpoint servers as environment variables and sets up Apache files in the dashboard container
	* run.sh - adds VPN routes and starts Apache in the container
	* sites/default-ssl.conf - the Apache configuration file that specifies the proxies
	* ssl/ - directory containing the SSL certificates
* documentation.pages
	* index.html - dashboard home page
	* view.html - the view html page which contains the supported environments
	* assets/ - contains resources (json, images, css, js, etc.) for the Learn section of the dashboard
	* assets/json/runbook-list.json - provides information about runbooks
	* assets/json/troubleshooting.json - provides information on troubleshooting runbooks
	* docs/runbooks - containes the runbook markdown files
* dashboard-vpn
	* Dockerfile - installs the ArrayNetworks VPN client
	* runVPN.sh - sources the vpnDetails.sh file to set credentials and starts the array_vpnc64 VPN client

### Important files and directories that reside on the dashboard host systems
The following files and directories currently reside on the dashboard host systems:

* /home/jenkins - user that is used by Jenkins to push docker images to the host dashboard systems. No password access, only ssh key access.
* /home/jenkins/launch-alchemy-dashboard-prod.sh - script invoked by Jenkins to start the dashboard containers on alchemy-prod.hursley.ibm.com
* /home/jenkins/launch-alchemy-dashboard-dev-staging.sh - script invoked by Jenkins to start the dashboard containers on alchemy-devtest.hursley.ibm.com
* /home/jenkins/restartdb.sh - script invoked by jenkins user crontab to restart dashboard containers
* /home/jenkins/dashboard.cron.file - invoked by Jenkins job to create the jenkins user crontab
* /home/jenkins/image-cleanup.sh - script invoked by jenkins user to remove unused docker images (not implemented yet in crontab)
* /opt/dashboard/get_tokens.js - javascript invoked in Apache configuration file to perform login to logmet
* /opt/dashboard/get_sensu.js - javascript invoked in Apache configuration file to perform login to Sensu
* /home/jenkins/executive-dashboard/ - contains files belonging to the executive dashboard
* /home/jenkins/environment-1337/ - contains files belonging to the executive dashboard

### Dashboard not responding
The following are actions to resolve issues when the Alchemy dashboard is not responding:

* If someone reports that a specific service (such as Uptime or Kibana/Logs) in the dashboard is not responding, this usually indicates a VPN connection has dropped. This causes the VPN container for this environment to stop, though this may take a few minutes. The jenkins user crontab will notice the stop container and restart all dashboard containers. To address the issue immediately take the following steps:
  * Verify the service cannot be reached on the dashboard.
  * Execute the Jenkins job [Restart-Dashboard-VPN-Containers](http://alchemy.hursley.ibm.com:8080/view/Conductors/job/Conductors/job/Conductors-Dashboard/view/Maintenance%20/job/Restart-Dashboard-VPN-Containers/) to restart the VPN containers. Leave the DASHBOARD_SYSTEM parameter set to the default value (alchemy-prod) to restart the production dashboard containers (this parameter can also be set to alchemy-devtest which restarts the devtest and staging dashboard containers).
  * Verify the service can be accessed in the dashboard.
* If the Alchemy dashboard itself cannot be launched or the step above does not work, do the following:
  * For the production dashboard execute the Jenkins job [Build-Dashboard-Production-Master](http://alchemy.hursley.ibm.com:8080/view/Conductors/job/Conductors/job/Conductors-Dashboard/job/Build-Dashboard-Production-Master/) to rebuild the production dashboard. Use the default parameters specified. When the build completes verify the [production dashboard](https://alchemy-dashboard.containers.cloud.ibm.com) can be launched.

### Work items
The following are work items that need to be done (required) or work items for future investigation (future):

* Obtain valid IBM internal certificates for the dashboard sites (completed)
* Implement crontab for old image removal (completed)
* Implement local build for dashboard (required)
* Move files containing credentials from host to 1337 project and have them pushed down (future)
* Improve Sensu console processing, including Chrome support (future)
* Support additional environments (maybe allow environment selection from home page) (completed)
* Improve visual display of button drop down list (future)
* Add Alert Notification to the Alchemy dashboard - task 99435 (future)
* Change VPN image to use openVPN (done except for stage/prod)
* Move dashboard projects to GHE (complete)
