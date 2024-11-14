---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: Runbook needs to be updated with description
service: Runbook needs to be updated with service
title: Kill slackbot processes
runbook-name: Kill slackbot processes
link: /kill_slackbots.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

## If a slackbot is acting up:

1.	Log into the alchemy-devtest.hursley.ibm.com machine. If you do bot have access, it can be applied for on itim.

1.	Login as sudo

1.	docker ps

1.	Issue the command "docker rm -f <name of slackbot process>". For example "docker rm -f glados-slack-bot".

