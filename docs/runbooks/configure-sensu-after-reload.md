---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: How to reconfigure a Sensu system after OS reload to a new Ubuntu image
service: Infra
title: How to reconfigure a Sensu system after OS reload to a new Ubuntu image
runbook-name: "How to reconfigure a Sensu system after OS reload to a new Ubuntu image"
link: /sre-infra-sensu-upgrade-u20.html
type: Operations
parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview
This runbook provides the steps to reconfigure a Sensu system after OS reload to a new Ubuntu image.
  
  
## Detailed Information
As part of Infrastructure systems migration from Ubuntu18 to Ubuntu20, this runbook is created to provide steps for Sensu systems reconfiguration.


## Detailed Procedure
1. Get the  list of Sensu systems for the given Softlayer Account <br> 
   Example: Sensu01 & 02 <br>
2. Identity the Master [eg: consider it as Sensu01] <br>
    1. Ssh to each sensu system to run the command “ip addr show | grep bond” <br>
    2. Only on Maser the command will return an output as shown below <br>
    3. Keep a note of the Master <br>
3. Login to both the Sensu system’s Uchiwa dashboard: <br>
    1. Connect to OpenVPN for the region <br>
    2. Uchiwa link `http://<PRIVATE-IP-OF-SENSU>:3000/uchiwa/#/clients` <br>
    3. Verify that on Master there are more entries when compared to non-master (in some cases no entries present) <br>
4. Raise a train request for stage & prod sensu upgrades (1 train per region in a day):
```
Squad: SRE
Title: Upgrade Sensu to Ubuntu20 and perform reconfiguration
Environment: us-south
Details: <NAMES OF THE SENSU Systems>
Risk: low
PlannedStartTime: now
PlannedEndTime: now + 8h
Ops: true
BackoutPlan: SRE will work on blackout plan
CustomerImpact: LOW
ValidationRecord: N/A 
PipelineName: N/A
PipelineVersion: N/A
ServiceEnvironment: Production
ServiceEnvironmentDetail: N/A
Audience: Private
```
5. Perform OS reload on non-master sensu system by selecting the Ubuntu20 image: <br>
  (a) Login to `cloud.ibm.com`. Select appropriate Softlayer Account based on Sensu system [for Dev=659397,Stage=1858147,Prod=531277] <br>
  (b) Click on `Navigation Menu`, select `Classic Infrasctructure` –> `Device List` and enter the Sensu name/IP <br>
  (c) Click on the Sensu device listed in the `Device List` <br>
  (d) In the Sensu device page, goto `Actions` –> select `OS Reload` option <br>
  (e) In the `OS Reload page` edit Operating System option and select `Ubuntu Linux 20.04 LTS Focal Fossa(64 bit)` <br>
  (f) In Extra features: <br>
      (f.1) for `Provision script`, select the region specific entry (Example: "B1 Stage" for Stage) <br>
      Refer to [this page](https://github.ibm.com/alchemy-conductors/bootstrap-one/blob/master/README.md) for more info about the selecting an appropriate option/script. <br>
      <a href="images/OS-Reload.png">
      <img src="images/OS-Reload.png" alt="OS Reload Extra Feature options" style="width: 600px;"/></a>
       <br>
  (g) If any issue with OS Reload (stuck/not connected etc) raise a Softlayer ticket. <br>
      After its been fixed, re-run the OS reload again to make sure that the bootstrap worked ok. <br>
  (h) ssh to the sensu system to verify that the ssh is allowed. If not, STOP the process and report in  #conductors-for-life channel for bootstrap help <br>
6. After OS reload, run the below Jenkins Job with appropriate input params <br>
   https://alchemy-conductors-jenkins.swg-devops.com/job/Conductors/job/Conductors-Monitoring/view/ansible-sensu-uptime/job/ansible-sensu-uptime-deploy/ <br>
   (a) Select the right environment from dropdown menu <br>
   (b) Select `DEPLOY_TYPE=site.yml` <br>
   (c) Select `MASTER_NODE_NAME` to non-master sensu system [eg: Sensu02 - after this JJ, Sensu02 becomes Master] <br>
   (d) If JJ fails then report in #conductors-for-life channel tagging India SRE squad <br>
7. Once the job is completed, login to the machine to see if docker containers are up and running: <br>
     Containers include: jenkins_httpclient_1, jenkins_nginx_1, jenkins_prodtok02carrier1master01_1 (also displays other region containers too),
                         jenkins_sensuserver_1, jenkins_grafana_1, jenkins_redis_1, jenkins_rabbitmq_1 and jenkins_graphite_1 <br>
8. Verify the sensuserver docker logs for any errors, inside: <br>
   ` $ sudo docker exec -it jenkins_sensuserver_1 bash` <br>
   ` root@ddb0302ad6f9:/# cat /var/log/sensu-server.log` <br>
   If any errors, report in #conductors-for-life channel tagging India SRE squad <br>
9. Repeat the steps from 5 to 8 on Sensu01/non-master: <br>
   [current master would be Sensu02] <br>
    1. Make sure to select appropriate MASTER_NODE_NAME [Sensu01 which is currently non-master] <br>
    2. Run the Jenkins Job mentioned in the above Step#5 with appropriate input parameters <br>
10. Verify Sensu systems are configured properly <br>
    1. Login to Uchiwa dashboard to verify the master and non-masters are properly set [repeat step#3] <br>
    2. Try to login to Prometheus dashboard for the region. Should be able to login to it. If not, report in #conductors-for-life channel tagging India SRE squad
    <br>

  
## RabbitMQ SSL Certificate validation and update
1. Details of RabbitMQ SSL enablement are discussed [here]( https://github.ibm.com/alchemy-conductors/sensu-uptime/tree/master/docker/rabbitmq)
2. Periodic Compliance checks reports any impending certificate expiry. From a local shell user can check this by running the following command against an active sensu server ( _say_ `stgiks-dal10-infra-sensu-03` ) here. In the example below the Certificate is valid till `Jul  3 03:59:59 2025 GMT`
```
jthomas@nila:~$ echo | openssl s_client -connect 10.95.115.195:5671 2> /dev/null | openssl x509 -noout -enddate | cut -d= -f2
Jul  3 03:59:59 2025 GMT
jthomas@nila:~$
```
3. If the certificate is approching expiry date, we need to check the [link](https://ibmca-prod.dal.cpc.ibm.com:9443/cybersecurity/ibmcert/web/certificates.do) and request for a certificate. On the request page, upload a locally created certificate (using `openssl` command; for eg: `openssl genrsa -out server.pem 2048` , where `server.pem` is the certificate can uplaod to the above provided link.) Step 1 above have a list of various `openssl` commands to create and validate certificates.
4. Submitting certificate request required manager approval. Once approved, submitter received an email from `ibmcapki@us.ibm.com` contains the certificate download  links. Download the certificate and update [here](https://github.ibm.com/alchemy-conductors/sensu-uptime/tree/master/docker/rabbitmq/ssl) by raising a PR.
5. Deploy `sensu-server` using the Jenkins job described in Step 6 under **Detailed Procedure** above
  
## Escalation paths
Slack channels: <br>
#conductors-for-life
  
