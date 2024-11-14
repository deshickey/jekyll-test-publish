---
layout: default
title: "IBM Cloud Event Notifications serviceverify"
runbook-name: "IBM Cloud Event Notifications serviceverify"
description: "Runbook to verify the service functionlity and dependencies, and how to handle incidents if verification fails"
category: Event Notifications
service: Event Notifications
tags: event-notifications
link: /event-notifications/en-serviceverify.html
type: Informational
grand_parent: Armada Runbooks
parent: Event Notifications
---

Informational
{: .label }

## Overview
# Runbook to verify the service functionlity and dependencies, and how to handle incidents if verification fails

## Service Health End-Points Verification Steps
## Detailed Information
1. Confirm the health end points of the region displays as Live.  To confirm this, access the health end point of the region mentioned below. 

End points of various regions are - 
* Sydney (au-syd) - https://au-syd.event-notifications.cloud.ibm.com/api-gateway/status
* Dallas (us-south) - https://us-south.event-notifications.cloud.ibm.com/api-gateway/status
* London (eu-gb) - https://eu-gb.event-notifications.cloud.ibm.com/api-gateway/status
* Frankfurt (eu-de) - https://eu-de.event-notifications.cloud.ibm.com/api-gateway/status
* Madrid (eu-es) - https://eu-es.event-notifications.cloud.ibm.com/api-gateway/status
* BNPP (eu-fr2) - https://eu-fr2.event-notifications.cloud.ibm.com/api-gateway/status
* Toronto (ca-tor) - https://ca-tor.event-notifications.cloud.ibm.com/api-gateway/status
* Osaka (jp-osa) - https://jp-osa.event-notifications.cloud.ibm.com/api-gateway/status
* Tokyo (jp-tok) - https://jp-tok.event-notifications.cloud.ibm.com/api-gateway/status


Verify the overall_health is Up by clicking on the above link


If the overall Health is not Live, then please follow the [escalation steps](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/event-notifications/en-escalation-policy.html) to engage the service team.

## Dependencies Verification Steps

1. Go to the [IBM Cloud status page](https://cloud.ibm.com/status?selected=status) to check the status of the component IBM Cloud Platform.
   Note: If there is an issue with a particular region and red exclamation point will show under the status. A green check mark indicates the platform is working as expected. Using the > to the left of the component name you can also see a list of notifications relating to the platform. Look for any notifications which are currently open or being investigated.
2. Check for any open CIE (Customer Impacting Events) for the environment impacted by using @ciebot cie list 
3. Escalate to the service team if any of the dependencies has a open CIE.

## Service Provisioning Verification Steps

If dependencies are working well, verify the service provisioning steps.
1. Login to [IBM Cloud](https://cloud.ibm.com)
2. Navigate to the [IBM Cloud Event Notifications Service provisioning page](https://cloud.ibm.com/catalog/services/event-notifications)
3. Select the region impacted to provision a instance in that specific region. 
4. Click create button to create the instance.  
5. If provisioning the instance fails, retry to verify once again.  If instance provisioning fails, even in the second attempt, then please follow the [escalation steps](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/event-notifications/en-escalation-policy.html) to engage the service team.


## Service Functionality Verification Steps

If the service provisioning worked well, continue to view the dashboard and perform the below steps to verify if the service functionality works well.

1. Click on the Topics navigation.  Since this is a new instance, an empty Topics page would be displayed.
2. Click on Create button in the topics navigation.  In the side popup, fill in any alphabetical strings for name & description. Click on the "Create" button on the popup.
 
3. Once created, the page should display the newly created collection.  

4. With the above steps completed successfully, it is a confirmation that the service is functioning as expected. Resolve the incident with appropriate details of service functioning as expected.   
5. If any of the steps fails, then please follow the [escalation steps](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/event-notifications/en-escalation.html) to engage the service team.


## How do I send notifications to a phone number?

 1. IBM Source needs to be integrated with the event notifications service 
 2. SMS destination is available out of the box
 3. Create Topic with conditions (Event Type, Event SubType or Severity).
 4. Creat Subscription with Topic created in step 3 with IBM Cloud SMS Service
 5. Send notifications using below curl
  
```
 curl --location --request POST 'https://us-south.event-notifications.test.cloud.ibm.com/event-notifications/v1/instances/<EN Guid>/notifications' \
--header 'Authorization: Bearer <Your EN Bearer Token>' \
--header 'Content-Type: application/json' \
--data-raw '{

    "specversion" : "1.0",
    "source": "<your source Id registered with EN Instance>",
    "id":"1234-1234-sdfs-234",
    "time" : "2018-04-05T17:31:00Z",
    "type":"com.ibm.cloud.imfpush.certificate_manager_custom:certificate_expiring_in_88",

    "subject":"12345678", 
    "severity":"HIGH",
    "message_text":"Hi Welcome to the IBM Cloud",
    "message_subject":"Findings on IBM Cloud Security Advisor",
    "message_html_body":" \"Hi  ,<br/>Certificate expiring in 90 days.<br/><br/>Please login to <a href=\"https: //cloud.ibm.com/security-compliance/dashboard\">Security and Complaince dashboard</a> to find more information<br/>\" ",
    "message_default_short":"Security findings in your IBM Cloud Account. Login to cloud console to find more information",
    "message_default_long":"Certificate expiring in 88 days. Please login to cloud console to find more information",
    "datacontenttype" : "application/json",
    "data": {
            "findings": [
            {
                "severity": "LOW",
                "provider": "cert-mgr"
            }
        ]
    }
}'
```

## How do I send notifications to to a mail id?

 1. IBM Source needs to be integrated with the event notifications service 
 2. Email destination is available out of the box
 3. Create Topic with conditions (Event Type, Event SubType or Severity).
 4. Creat Subscription with Topic created in step 3 with IBM Cloud Email Service
 5. Send notifications using below curl
 ```
 curl --location --request POST 'https://us-south.event-notifications.test.cloud.ibm.com/event-notifications/v1/instances/<EN Guid>/notifications' \
--header 'Authorization: Bearer <Your EN Bearer Token>' \
--header 'Content-Type: application/json' \
--data-raw '{

    "specversion" : "1.0",
    "source": "<your source Id registered with EN Instance>",
    "id":"1234-1234-sdfs-234",
    "time" : "2018-04-05T17:31:00Z",
    "type":"com.ibm.cloud.imfpush.certificate_manager_custom:certificate_expiring_in_88",

    "subject":"12345678", 
    "severity":"HIGH",
    "message_text":"Hi Welcome to the IBM Cloud",
    "message_subject":"Findings on IBM Cloud Security Advisor",
    "message_html_body":" \"Hi  ,<br/>Certificate expiring in 90 days.<br/><br/>Please login to <a href=\"https: //cloud.ibm.com/security-compliance/dashboard\">Security and Complaince dashboard</a> to find more information<br/>\" ",
    "message_default_short":"Security findings in your IBM Cloud Account. Login to cloud console to find more information",
    "message_default_long":"Certificate expiring in 88 days. Please login to cloud console to find more information",
    "datacontenttype" : "application/json",
    "data": {
            "findings": [
            {
                "severity": "LOW",
                "provider": "cert-mgr"
            }
        ]
    }
}'
```
## How do I send notifications to a custom email?

We have published a blog on this topic. Please refer to it at https://www.ibm.com/blog/enhancing-customer-experience-streamlining-orders-with-custom-email-notifications-in-ibm-cloud/

## How do I send notifications to a SMS destination?

We have published a blog on this topic. Please refer to it at https://cloud.ibm.com/docs/monitoring?topic=monitoring-tutorial-en-sms&locale=pt-BR
