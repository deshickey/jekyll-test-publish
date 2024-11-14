---
layout: default
title: Production Onboarding
type: Process
parent: Policies & Processess
---

Process
{: .label .label-green}

# Overview

Before getting access to production systems, employees must satisfy some security and compliance requirements. We are audited in order to reassure customers that it's safe to store their sensitive data in our services. This process is to ensure that we meet the required standards.

For example, we must comply with the US Health Insurance Accountability and Portability Act (HIPAA) and potential access to Protected Health Information (PHI).

## Process

1. Copy and paste the table below into an email, answering each question:

    | Action        | Response       |
    | ------------- |:-------------:|
    | 1.  Reviewed the IBM [IT Security Standard](https://pages.github.ibm.com/ciso-psg/main/standards/itss.html) and the [HIPAA Addendum](https://pages.github.ibm.com/ciso-psg/main/supplemental/hipaa.html).| (Y/N)|
    | 2.  Confirm that both you and your workstation satisfy the [privileged user requirements](./privileged_user_procedure.html).| (Y/N)|
    | 3.  Complete the required training in YourLearning before raising access requests. It is mandatory to complete all courses listed in the policy links below, before requestion access to production systems <br /><br /> a. Security Awareness Training - [https://pages.github.ibm.com/ibmcloud/Security/policy/AT-Policy.html#security-awareness-training](https://pages.github.ibm.com/ibmcloud/Security/policy/AT-Policy.html#security-awareness-training) <br /><br /> b. HIPAA training [https://pages.github.ibm.com/ibmcloud/Security/guidance/role-based-training.html#hipaa-training](https://pages.github.ibm.com/ibmcloud/Security/guidance/role-based-training.html#hipaa-training) <br /><br /> c. Role Based Training (Complete all applicable courses based on your role) - [https://pages.github.ibm.com/ibmcloud/Security/policy/AT-Policy.html#role-based-training](https://pages.github.ibm.com/ibmcloud/Security/policy/AT-Policy.html#role-based-training)|(Y/N)|
    | 4.  Confirm that you have access to policy repository: [IBM Cloud Platform Security Policy](https://pages.github.ibm.com/ibmcloud/Security/policy/Security-Policy.html)|(Y/N)|
    | 5. Confirm that you have access to the [local process repository](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/).|(Y/N)|
    | 6. Confirm that you will keep all personal secret authentication information confidential (e.g. passwords, API keys) and keep any group shared secret authentication information solely within the members of the group.|(Y/N)| 
    | 7.  **Acknowledgement:** When accessing production servers that contain ePHI / HIPAA data, no customer data is to be exported off of production servers.  A log file (or snapshot) can be stored in a temp encrypted location on the production server until the problem ticket is closed. Once the ticket is closed, remove all ticket related data with an IBM approved disposal tool/method.|(Y/N)|
    | 8.  **Acknowledgement:** When you no longer require production access (via transfer, new role, terminating IBM), you must complete [offboarding processes](./production_offboarding.html) including confirming that no customer PHI existed on your workstation or all customer PHI has been removed by an IBM approved disposal tool. You are advised to bookmark the offboarding process for future reference.|(Y/N)|

2. The email must be sent as follows, filling out the values in `this format` with the right ones for you:
    - **To field:** `HIPAA Focal Name` (note: refer to the link below for the contact name)
    - **CC field:** `Your Manager's Name`, `Your Compliance Focal Name`, HDEVLIN@uk.ibm.com, colin_thorne@uk.ibm.com
    - **Subject:** Onboarding Checklist for `Your Name`

    Note: For the names of the WCP HIPAA Focal and Service Compliance Focal, see the [security and compliance focals list](./security_compliance_focals.html).

## Where to get help

For policy questions, refer to the `#wcp-compliance` Slack channel.

Otherwise, contact your [Service Compliance Focal](./security_compliance_focals.html) or ask in the `#argonauts-security` Slack channel.

## Reviews

Last review: 2024-07-01 Last reviewer: Hannah Devlin, Next review due by: 2025-07-01
