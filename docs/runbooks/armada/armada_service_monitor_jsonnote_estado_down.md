--- 
layout: default 
title: kubernetes uptime/health monitoring tool for estado / jsonnote is down
type: Troubleshooting 
runbook-name: "armada_service_monitor_jsonnote_estado_down.md"
description: what to do if the health/uptime reporting service to bluemix/estado goes down.
service: armada-ops
failure:  
playbooks: 
link: /armada/armada_service_monitor_jsonnote_estado_down.html
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Symptoms
Someone from bluemix will tell us via slack of email that our service has gone down in estado bluemix monitoring.
If Kubernetes/prometheus is NOT down (I'm sure you will know if it is) then most likely it is a problem with our health monitoring service.

* `armada-ops-avail` is the servce that queries prometheus for provisioning and consumption metrics.
* it then posts these metrics (every minute) to a service called `jsonnote.mybluemix.net`
* independently, `estado.ng.bluemix.net` polls `jsonnote` for this information

## Issue
uptime monitoring from estado [http://estado.ng.bluemix.net/internalstatus](http://estado.ng.bluemix.net/internalstatus) or jsonnote [https://jsonnote.mybluemix.net/?key=containers-kubernetes](https://jsonnote.mybluemix.net/?key=containers-kubernetes) has stopped for kubernates.
this means that from the high level view executive dashboard for the whole of bluemix, containers-kubernetes seems to be down - this is bad!

### How can the issue be verified?
the uptime service (`armada-ops-avail`) is living in a container here:
`alchemy-prod.hursley.ibm.com`

running `sudo docker ps -a | grep armada-service-monitor` will list it as something like:

    18df9b461d02        alchemyregistry.hursley.ibm.com:5000/alchemy_sensu/armada-service-monitor   "/service-monitor -s"    6 seconds ago       Up 6 seconds                                       armada-service-monitor

if it is not running, it will need to be restarted - see [restarting the service](#restarting-the-service)

if it IS running - check the logs with: 
`sudo docker logs  armada-service-monitor`

you will see output like:

    ### Publish status result 
    "{
      "service": "containers-kubernetes",
      "version": 1,
      "timestamp": "2017-03-28 16:32:55.843149649 +0000 UTC",
      "debug": "sender: aea0470df98b",
      "health": [
        {
          "plan": "us-south",
          "status": 0,
          "serviceInput": "sum( delta(ingress_endpoint_rtime_count { handler=~\"_v1_.*\" , status=~\"2..\"} [30m] ))",
          "serviceOutput": "Unexpected status query result \"\"",
          "responseTime": 0
        }
      ],
      "provision": [
        {
          "plan": "us-south",
          "status": 0,
          "serviceInput": "sum(delta(ingress_endpoint_rtime_count{method=\"POST\", handler=\"_v1_clusters\", status=\"201\"}[30m]))",
          "serviceOutput": "Unexpected status query result \"\"",
          "responseTime": 0
        }
      ]
    }"
    ### to service-monitor
    ]
    2017-03-28 16:32:57.146702554 +0000 UTC [Publish to JSON Note url https://jsonnote.mybluemix.net ( 201 Created ), succeeded with body {"status": "ok"}]


if the serviceOutput is an error message (rather than a number) then the server cannot connect to the production services - most likely the VPN has failed on alchemy-prod.hursley.ibm.com.  To recover see: (recovering VPN)[#recovering-VPN]

if the last timestamp is a long time ago (IE more than a minute old - summer time might make this an hour different from running 'date') then the container has hung somehow.. to recover see: (killing the service)[#killing-the-service] 


## What PD incidents might occur?
hard to tell what will happen, we are unlikely to get paged directly, but someone from bluemix might shout at us..

## killing the service 
*If the service needs to be restarted, kill it with: 
`sudo docker kill  armada-service-monitor`
*delete the container
`sudo docker rm armada-service-monitor`

*get the images, then delete armada-service-monitor
`sudo docker images`

    REPOSITORY                                                                  TAG                 IMAGE ID            CREATED             SIZE
    alchemyregistry.hursley.ibm.com:5000/conductors/nginx-dashboard             766                 2d97c3b93996        About an hour ago   446.1 MB
    alchemyregistry.hursley.ibm.com:5000/conductors/nginx-dashboard             765                 0bec87ad5f9f        18 hours ago        446.1 MB
    alchemyregistry.hursley.ibm.com:5000/alchemy_sensu/armada-service-monitor   latest              94da21946062        11 days ago         6.733 MB
    alchemyregistry.hursley.ibm.com:5000/alchemy/estado-feed                    latest              a6fad16effac        2 weeks ago         6.732 MB
    alchemyregistry.hursley.ibm.com:5000/alchemy/quota-app                      49                  76650750d799        7 weeks ago         463.6 MB
    alchemyregistry.hursley.ibm.com:5000/alchemy/openvpn                        latest              a976864b37ec        13 months ago       7.789 MB

*delete the image:
`docker rmi -f $(docker images|awk '/armada-service-monitor/ { print $3}')`

*then proceed to [restarting the service](#restarting-the-service)


## restarting the service 

if it is not running, it needs to be restarted with: 
`docker run -d --name armada-service-monitor alchemyregistry.hursley.ibm.com:5000/alchemy_sensu/armada-service-monitor`

you can check that its running by looking at the logs: 
`sudo docker logs  armada-service-monitor`

## recovering VPN 
the VPN Access is managed through a container running on `alchemy-prod.hursley.ibm.com`, we just need to restart it with:
    `docker restart openvpn-prod-dal09`
it should restart immediately.

## Escalation
escalate to #armada_ops channel in slack

for GHE issues, raise them here: [https://github.ibm.com/alchemy-containers/armada-ops-avail/issues](https://github.ibm.com/alchemy-containers/armada-ops-avail/issues)

## Further reading
the repository is here: https://github.ibm.com/alchemy-containers/armada-ops-avail
