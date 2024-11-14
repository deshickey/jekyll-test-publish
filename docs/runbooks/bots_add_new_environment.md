---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: How to add an new environment to bots
service: Conductors
title: How to add an new environment to bots
runbook-name: "How to add an new environment to bots"
link: /bots_add_new_environment.html
type: Operations
parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview

Runbook provides information on adding a new environment to bots.

## Detailed Information

We need to add new environment to the bots so we can raise train, continue patching the new environment.

## Detailed Procedure

### Igor
Add primary DC to armadaRegionToAptServerMapping map in [alchemy-conductors/smith-trigger-service](https://github.ibm.com/alchemy-conductors/smith-trigger-service/blob/master/remote/machineaccess.go)

### service-now-api
Update [service-now-api](https://github.ibm.com/alchemy-conductors/service-now-api/blob/master/api.go) to add new region. [Example](https://github.ibm.com/alchemy-conductors/service-now-api/pull/44/files)

### elba
Update [alchemy-conductors/elba](https://github.ibm.com/alchemy-conductors/elba) to add new region. [Example](https://github.ibm.com/alchemy-conductors/elba/pull/203/files)  
Also pull service-now-api changes. Command `go get github.ibm.com/alchemy-conductors/service-now-api@master` and `go mod tidy`

### fat-controller
Update [fat-controller](https://github.ibm.com/sre-bots/fat-controller/blob/master/types/type.go) to add new region. [Example](https://github.ibm.com/sre-bots/fat-controller/pull/351/files)  
Also pull elba changes. Command `go get github.ibm.com/alchemy-conductors/elba@master` and `go mod tidy`

### underling-easyconfig
Update [sre-bots/underling-easyconfig](https://github.ibm.com/sre-bots/underling-easyconfig) to add new region. [Example](https://github.ibm.com/sre-bots/underling-easyconfig/pull/43/files)  
Also pull elba changes. Command `go get github.ibm.com/alchemy-conductors/elba@master` and `go mod tidy`

### sodium
Update [sodium](https://github.ibm.com/sre-bots/sodium/blob/master/cmd/sodium/exampleConfig.hjson) to add new region. [Example](https://github.ibm.com/sre-bots/sodium/pull/540/files)  
Also pull underling-easyconfig changes. Command `go get github.ibm.com/sre-bots/underling-easyconfig@master` and `go mod tidy`

### seer
Update [seer](https://github.ibm.com/alchemy-conductors/seer/blob/master/hubmanager/manager.go) to add new region. [Example](https://github.ibm.com/alchemy-conductors/seer/pull/68/files)

### smith-trigger-service
Update [alchemy-conductors/smith-trigger-service](https://github.ibm.com/alchemy-conductors/smith-trigger-service) to add json files. [Example](https://github.ibm.com/alchemy-conductors/smith-trigger-service/pull/4571/files)  
Also pull elba, service-now-api and underling-easyconfig changes.  
Command:  
```
go get github.ibm.com/alchemy-conductors/service-now-api@master
go get github.ibm.com/alchemy-conductors/elba@master
go get github.ibm.com/sre-bots/underling-easyconfig@master
go mod tidy
```
### chlorine
Update [sre-bots/chlorine](https://github.ibm.com/sre-bots/chlorine). [Example](https://github.ibm.com/sre-bots/chlorine/pull/774/files)  
Also pull elba, smith-trigger-service and underling-easyconfig changes.  
Command:  
```
go get github.ibm.com/alchemy-conductors/elba@master
go get github.ibm.com/alchemy-conductors/smith-trigger-service@master
go get github.ibm.com/sre-bots/underling-easyconfig@master
go mod tidy
```
### smith-red-pill
Update [smith-red-pill](https://github.ibm.com/alchemy-conductors/smith-red-pill/blob/master/configurations/prodTestConfig.json) to add new region. [Example](https://github.ibm.com/alchemy-conductors/smith-red-pill/pull/180/files)  
Also pull elba, smith-trigger-service and underling-easyconfig changes.  
Command:  
```
go get github.ibm.com/alchemy-conductors/elba@master
go get github.ibm.com/alchemy-conductors/smith-trigger-service@master
go get github.ibm.com/sre-bots/underling-easyconfig@master
go mod tidy
```
### smith-red-pill-creds
Update [alchemy-1337/smith-red-pill-creds](https://github.ibm.com/alchemy-1337/smith-red-pill-creds) to add new region. [Example](https://github.ibm.com/alchemy-1337/smith-red-pill-creds/pull/66/files)
### chlorine-bot-creds
Update [alchemy-1337/chlorine-bot-creds](https://github.ibm.com/alchemy-1337/chlorine-bot-creds) to add new region. [Example](https://github.ibm.com/alchemy-1337/chlorine-bot-creds/pull/84/files)

### Deployment

Contact relevant person or in `#conductors-for-life` channel to find out how and when to deploy these changes in bots.

## Help needed?

Ask for help in `#conductors-for-life` channel
