--- 
layout: default
title: Introduction to AI Assistant
type: Informational
runbook-name: "Introduction to AI Assistant (ai-contextual-help)"
description: Introduction to AI Assistant (ai-contextual-help)
category: AI Assistant
service: AI Assistant
tags: ai, assistant
link: docs/runbooks/ai-assistant/ai-assistant-escalation-policy.html
grand_parent: Armada Runbooks
parent: AI Assistant
---

Informational
{: .label }

## Overview

IBM Cloud's AI assistant, which is powered by IBM's Watsonx, is designed to help you learn about working in IBM Cloud and building solutions with the available catalog of offerings.

This service does not provide business critical functionality.  All systems will work with or without this (no dependencies on this service).

## Detailed Information

For detailed information you can find more information in the [documentation](https://cloud.ibm.com/docs/overview?topic=overview-ask-ai-assistant){:target="_blank"}.

The service is deployed to the Dreadnought account `dn-prod-s-cpapi-extended`.  It is deployed on a single zone cluster per region.

Production is currently deployed to

- Washington DC ( us-east )
- Sydney ( au-syd )
- Frankfurt ( eu-de )

The global hostname for the service is: `ai-assistant.cloud.ibm.com`

### Documentation Roadmap

- Networking information: [Link](./operations/networking.html)
- Healthcheck URLs: [Link](./alerts/ai-assistant-dependencies.html)
- Monitoring and Alerting: [Link](./alerts/ai-assistant-alerts.html)
- Dependency Listing: [Link](./alerts/ai-assistant-dependencies.html)
- Secret Management: [Link](./operations/secret-rotation/Secret-Management.html)

## Further Information

### Current Team

#### Scrum Master

Falk Posch <Falk.Posch@de.ibm.com>

#### Security Focal

Ricardo Matty <Ricardo.Matty@ibm.com>

#### Development Manager

Jörg Erdmenger <joerg.erdmenger@de.ibm.com>

#### BCDR Focal

Sergey Dmitriev <svd@de.ibm.com>

#### Core Development Team

- Jenifer Schlotfeldt <jschlot@us.ibm.com> ( Architect )
- Oliver Rau <oliver.rau@de.ibm.com> ( Architect )
- Mark Duquette <mark.duquette@us.ibm.com> ( DevOps / SRE )
- Vitaly Meytin <VITALYM@il.ibm.com> ( Performance )

- Alex Carlucci <alexc@ca.ibm.com>
- Beate Jakobs <beate.jakobs@de.ibm.com>
- Cadan Ojalvo <Cadan.Ojalvo@il.ibm.com>
- Dimitrij Pankratz <DIPA@de.ibm.com>
- Izidor Jager <JAGER@de.ibm.com>
- Michelle Kaufman <mtompki@us.ibm.com>
- Nitzan Nissim <NITZANN@il.ibm.com>
- Oliver Then <oliver.then@de.ibm.com>
- Susanne Betsch <BETSCH@de.ibm.com>

Full team: <https://test.cloud.ibm.com/docs/ai-assistant?topic=ai-assistant-team>

#### Product Management

Greg Effrein <greg.effrein@us.ibm.com>

### Additional Links

- [AI Assistant Wiki](https://github.ibm.com/ibmcloud/ai-contextual-help/wiki/AI-Assistant-Runbook){:target="_blank"}
- [Customer Documentation](https://cloud.ibm.com/docs/overview?topic=overview-ask-ai-assistant){:target="_blank"}
- [AI Assistant Internal Documentation](https://test.cloud.ibm.com/docs/ai-assistant?topic=ai-assistant-what-is)
