---
layout: default
title: New Service Endpoint for carrier
type: Operations
runbook-name: "New SE for Carrier"
description: How to create a service endpoint for carriers
category: Armada
service: Carrier
tags: alchemy, armada, mis, service-endpoint
link: /carrier_new_se.html
parent: Armada Runbooks
---

Ops
{: .label .label-green}

## Overview

Private Service Endpoints are used to enable communication between customer cruisers and our masters across the private network without going over public.


## Detailed Information

We have several accounts and have set up APIKeys to be able to list / manage / create SEs in those various accounts.

As you need to use the private address of the HA-Proxy of the carrier they must be created in the correct accounts.


## Detailed Procedure

I'm going to just dump all this here for now and this needs tidying..
Use the APIKEYs stored in Thycotic at \BU044-ALC\BU044-ALC-Conductor\Service Endpoint ServiceIDs

Ensure you are using the correct one for the region that you want the new SE created in.

WARNING!!!
THere are a number of scripts that I will put in a repo, but they must be used carefully, as they have no safety net in them currently and I need to add that in.
https://github.ibm.com/alchemy-conductors/carrier-service-endpoints

To use this you need to export the correct APIKEY for the region.

## Automation

None so far
