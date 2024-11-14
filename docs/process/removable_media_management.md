---
layout: default
title: Removable Media Device Management
type: Process
parent: Policies & Processess
---

Process
{: .label .label-green}

# Removable Media Device Management

## Scope

This process applies to the following squads:

- Argonauts SRE squads
- Argonauts Network Intelligence Squad
- All IBM Cloud Kubernetes Service squads
- All IBM Cloud Container Registry squads

## Overview

The term "Removable media" means any portable storage device, including but not limited to:

- CDs or DVDs
- External hard drives
- USB flash drives

Removable media exposes IBM and its customers to security risks of data loss and breach of confidentiality. Removable media can be easily lost or stolen.

IBM is working to reduce its usage of removable media as described [here](https://w3.ibm.com/help/#/article/usb_drive_risk_reduction) so that writing to removable media will be prohibited unless an approved exception exists. In general, the recommendation is to use:

- [Box@IBM](https://w3.ibm.com/help/#/article/use_box) to share files across your own devices and collaborate with colleagues
- [Code42 CrashPlan](https://w3.ibm.com/help/#/article/crashplan_overview) to back up your computer

There are some known exceptions where removable media is still valid. This process describes:

1. How we will manage the risks of removable media for the exceptional cases where we still use a removable media device (referred to as a "Device" in this document).
2. The requirements for managing Devices.
3. The role of the Custodians who will be responsible to ensure that the process is followed.

## Requirements

1) Every Device must be ordered from an approved IBM supplier through an approved IBM procurement tool such as [Buy on Demand (Bond)](http://w3.ibm.com/procurement/buyondemand). Nobody may use removable media obtained by any unapproved means.

2) Every Device must be managed by a Custodian and should normally remain in a Custodian's possession, unless it is software/firmware installation media which is read-only: read-only installation media can be kept by individual employees but it should be kept in a locked storage unit when not in use.

3) A Removable Media Inventory ("Inventory") must be maintained to record:
    - What Devices exist
    - The location of the locked storage unit where the Device is kept by default when not on loan to an employee
    - Who has possession of each Device (and the history of who had possession over time)
    - A high-level description of the type of data stored on the device, including the name of the owner of any data which is specific to one employee. Here are some examples:
        - Empty.
        - Mac OS operating system boot image.
        - Virtual machine backup of Fred Bloggs' Ubuntu 16.04 development environment.

4) Every Device must be stored at an IBM office location at all times and never removed from the IBM site. The only exception is when the Device is at the end of its life, when it must first be erased and then sent for disposal in accordance with IBM secure disposal policies.

5) Every Device must be kept physically secure at all times. A Device must never be left unattended unless stored in a locked storage unit:
    - a locked cupboard
    - a locked desk drawer
    - a locked safe
    - a locked office belonging to one employee (note: badge-locked open-plan areas are not sufficiently secure)

6) Multiple people have may have access to a locked storage unit, but each of them must be designated a Custodian for every Device stored in that locked storage unit. This allows for cover in case someone needs access to a Device when one Custodian is absent. Where multiple Custodians manage Devices, each Custodian is individually responsible for recording any loans and returns that they process in the Inventory.

7) Devices must *never* be used to store:

    - Any data owned by a customer, or supplied to IBM by a customer.

    - Electronic Payment data, or e-payment data, as defined in [FIN 180](https://w3-03.ibm.com/ibm/documents/corpdocweb.nsf/ContentDocsByTitle/Corporate+Instruction+FIN+180).

    - Personal data of any kind, regardless of whether or not it is sensitive personal data. As a special case for convenience of backups, an employee's IBM work email address or intranet ID are allowed to be stored provided any associated secrets are either omitted or encrypted as described below.

    - The following types of data, unless strongly encrypted in accordance with [ITSS]  (https://pages.github.ibm.com/it-standards/main/2015/01/24/itss.html#51-data-encryption) using an ITSS acceptable algorithm and the data needed for decryption is not stored on the same Device:
        - IBM Confidential data
        - Secrets (e.g. passwords, tokens, API keys etc.) that allow access to any production systems or data

    **Attention:** Pay particular attention to logs and database records extracted from production systems into development virtual machines, where the VM is backed up. The recommendation is not to download such data into a VM, but if you must do so then take appropriate steps to prevent them being backed up, e.g. store them in an encrypted filesystem which is regularly emptied and always empty that directory before taking any backups.

8) Every employee must at all times comply with IBM policies, processes and procedures when following this process. Nothing in this process overrides any other corporate requirements.

## Custodians

A media custodian ("Custodian") is a named person who is responsible for at least one removable media Device.

Every Custodian must:

1) Maintain accurate, complete and current records in the Inventory of all Devices for which the Custodian is responsible, in the location and format specified in this process.

2) Ensure that each Device is physically labeled to uniquely identify it within the Inventory. The identifier should contain the name of the area or squad plus a number to make it unique, e.g. "SRE 001".

3) Ensure that the label for each Device is legible and firmly attached, replacing the label as necessary to ensure it remains legible.

4) Process all requests to borrow a Device as described below.

5) Process all returned Devices as described below.

6) Ensure that each Device is erased and disposed when no longer required as described below.

7) Report any lost or stolen Device via the [IBM Security Incident Reporting](http://w3.ibm.com/security) process as soon as possible after becoming aware of the loss. Also:
    - The Custodian's own manager and the Security Focal must be informed.
    - The Inventory Device record must be moved to the `Devices Missing` state and a comment added to describe details of the loss and information about the Security Incident raised.

## Appointment of Custodians

SRE Management will appoint at least one Custodian per IBM office location. Each Custodian will be a relatively senior employee such as:

- A manager
- An area lead
- A squad lead

SRE Management will maintain an up-to-date [list of Custodians](https://github.ibm.com/alchemy-conductors/compliance-removable-media-inventory/blob/master/README.md).

### Cover for absences

It is recommended to have more than one Custodian per IBM office location, to provide cover for absences.

More than one Custodian may have access to the same secure storage unit where Devices are kept, provided that everyone with access to the secure storage unit is appointed as a Custodian.

## Inventory

1) Custodians must keep Inventory records in [this GitHub repository](https://github.ibm.com/alchemy-conductors/compliance-removable-media-inventory#boards?repos=416837).

2) There must be one GitHub issue per Device (the "Inventory Device record"):

    a) The issue title must clearly state the unique ID of the Device, matching the Device label. The unique ID should be followed by a brief description of the device e.g. type, storage capacity and any distinctive markings such as a model number. For example: `EXAMPLE001 - 256GB USB Drive Red JF780`.

    b) The issue body must clearly state:

    - Custodian Name: The name of the Custodian(s) responsible for the Device
    - Secure Storage Location: The location of the locked storage unit where the Device is kept by default when not on loan to an employee
    - Type of Data Stored: A high-level description of the type of data stored on the device, including the name of the owner of the data if the data is specific to one employee

    c) The history of loans and returns of each Device must be recorded by comments on the corresponding issue.

    d) The current status of the Device must be indicated by moving the issue into a ZenHub pipeline:
    - Devices On Order (optional: the Device has been ordered - can be used to track pending Bond orders)
    - Devices With Custodians (the Device is locked in a locked storage unit under the control of a Custodian)
    - Devices On Loan (the Device is on loan to an employee)
    - Devices Pending Disposal (the Device is going to be disposed of, and is awaiting erasure and secure disposal)
    - Devices Missing (the Device is suspected lost or stolen and a security incident has been reported)
    - Closed (the Device has been disposed of securely, or it has been lost/stolen and the associated security incident has been closed)

## Transition to this Process

1) SRE Management will appoint the Custodians, record them [here](https://github.ibm.com/alchemy-conductors/compliance-removable-media-inventory/blob/master/README.md) and grant them access to that GitHub repository.

2) All employees in scope will hand over any Devices to their local Custodian. Software/firmware installation media can be kept by individual employees if it's read-only, but it should be kept in a locked storage unit.

3) Custodians will create an Inventory record for each Device and will label each Device uniquely as per the requirements of this process.

4) Custodians will confirm to SRE Management that all Devices have been recorded in the Inventory and are securely stored.

5) SRE Management will inform all employees in scope that this process must be followed at all times. All future removable media Devices purchased must be ordered and managed in accordance with this process.

## Borrowing a Device

1) An employee wishing to write data to a Device must first obtain an exception via the [CISO Process](https://w3.ibm.com/help/#/article/usb_drive_risk_reduction). The vice president within your reporting line, your Business Unit Information Security Officer (BISO), and the Corporate Information Security Office (CISO) must approve your request. The employee must upload evidence of their exception approval to the [removable media exception tracking repository](https://github.ibm.com/alchemy-conductors/compliance-removable-media-exceptions).

2) The employee must ask a Custodian based at the same IBM site to borrow a device. The employee must:
    - be a member of the same tribe as the Custodian (e.g. Argonauts) so that our management retain authority over the Device, and
    - have an approved CISO exception with evidence uploaded in the [removable media exception tracking repository](https://github.ibm.com/alchemy-conductors/compliance-removable-media-exceptions) (if the employee is going to write data to the USB device)

3) The Custodian must select a suitable Device and locate the Inventory Device record ([GitHub issue](https://github.ibm.com/alchemy-conductors/compliance-removable-media-inventory#boards?repos=416837)).

4) The Custodian must add a comment to the Inventory record as follows, supplying the correct name and date:

    ```
    New loan:
    - Who is borrowing the Device:
    - Intended use of the Device:
    - Expected return date:
    ```

    This must be done by adding a new comment at the time of the loan so that the comment timestamp records when the Device was borrowed.

5) The Custodian must move the Inventory Device record into the `Devices On Loan` state (ZenHub Pipeline).

6) After the Inventory is updated, the Custodian will provide the Device to the employee.

## Returning a Device

1) When a Device is returned to a Custodian, the Custodian must record the following in the Inventory Device record ([GitHub issue](https://github.ibm.com/alchemy-conductors/compliance-removable-media-inventory#boards?repos=416837)), supplying the correct name:

    ```
    Returned:
    - Who is returning the Device: 
    ```

    This must be done by adding a new comment at the time of the return so that the comment timestamp records when the Device was returned.

2) The Custodian must also update the high-level description of the data now stored on the Device, if the type of data stored has changed while the Device was on loan. A newer copy of the same data does not require an update.

3) If the Device was not returned by the original borrower, the Custodian must also record the reason why a different employee returned it. The Custodian must inform their own manager and the [Security Focal](./security_compliance_focals.html) of such cases.

4) The Custodian must return the Device to the designated locked storage unit listed in the Inventory. The Device may be returned to a different locked storage unit provided the Custodian updates the Inventory Device record to specify the new location.

5) The Custodian must move the Inventory Device record to the `Devices With Custodians` state (ZenHub Pipeline).

## Disposal of a Device

1) When a Device is no longer required, the Custodian must render the data unreadable in accordance with [NIST SP 800-88 Appendix A](https://ws680.nist.gov/publication/get_pdf.cfm?pub_id=50819).

2) The Custodian must then send the Device for disposal in accordance with IBM secure disposal policies. The Custodian must update the Inventory Device record to status `Devices Pending Disposal`.

3) After disposal is complete and confirmed, the Custodian must update the Inventory Device record to `Closed` state and record a comment to describe the method of disposal and the fact that disposal is complete.

## Reviews

1) This process will be reviewed annually.

2) SRE Management will review periodically (at least annually) the [list of Custodians](https://github.ibm.com/alchemy-conductors/compliance-removable-media-inventory/blob/master/README.md) and the [Inventory Device records](https://github.ibm.com/alchemy-conductors/compliance-removable-media-inventory/issues#boards?repos=416837) to ensure that:
    - The list of Custodians is accurate and up-to-date, and
    - Every Device has an assigned Custodian who is on the Custodian list

3) SRE Management will ensure that an annual reminder of this process is sent to all employees in scope.

4) Custodians will perform an annual revalidation of their Devices and Inventory records as directed by SRE Management. The revalidation must satisfy the requirements of the [ITSS HIPAA Addendum](https://pages.github.ibm.com/it-standards/main/2017/02/07/hipaa_v2.html).

### Reviews

Last review: 2024-07-23 Last reviewer: Hannah Devlin Next review due by: 2025-07-22
