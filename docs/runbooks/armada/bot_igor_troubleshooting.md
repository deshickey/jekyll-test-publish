---
layout: default
description: "Debugging Igor bot (SRE) issues"
title: "Debugging Igor bot (SRE) issues"
runbook-name: "Debugging Igor bot (SRE) issues"
service: armada
tags: alchemy, armada, containers, kubernetes, pod
link: /armada/bot_igor_troubleshooting.html
type: Informational
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Introduction 

Igor is a helpful bot that automates common tasks performed by conductors.
The intention is that he takes the boring tasks that people would otherwise have to spend a reasonable amount of time on, 
and he will perform them the same every time, giving better feedback and consistency than a conductor performing them.

## Overview
Igor can be talked to via DM or in a channel he is a member of (eg `#conductors`) If a ser requests Igor to dosomething, he will raise a prod (or stage) train asking for permission from conductors before proceeding.

Once the train is approved, Igor will then trigger and perform the action requested.

As igor performs steps, he will DM the original requestor to tell them what he is doing.

Whenever he is passed a list of machines in a single request to act on, he will act on them individually, one at a time, in the order originally specified.

If multiple trains/requests from Igor are approved at the same time, Igor will work on them concurrently - in separate threads.

## Detailed Information

The main symptom of Igor not working is he stops responsing on Slack.
The best way to get his attention is with the command `@igor_bot help`. If he does not respond to this, there is something wrong.

Igor logs ALL the messages he sends to users in the chanel: `#bot-igor-logging`  Take a look there to see if he has done anything recently - or if he seems to be dead.

## If he is dead:
Igor is currently hosted as a container on `alchemy-prod.hursley.ibm.com` (there are plans to move to a hosted kubernetes cruiser)
log onto that machine (most conductors can do that) and look at his container:


then get the logs:

`sudo docker logs -t -f  igor-bot`
take the last few pages of his logs and raise an issue in: `https://github.ibm.com/sre-bots/igor/issues`
so that the issue can be fixed.
(also - send a DM to `@cam` or slack `@conductors-uk` in the `#condctors` channel and they will look at it)


## Restart Igor:
ssh on to: `alchemyprod.hursley.ibm.com`

find out the igor container ID:
`sudo docker ps | grep igor_bot`


run the command
`sudo docker start <container ID>`


 Wait for igor to connect back to slack - his status will turn green - this takes less than a minute.


he should then respond to `@igor-bot help` requests
