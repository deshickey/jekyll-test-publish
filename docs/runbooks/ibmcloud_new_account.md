---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: How to create a new IBM Cloud account for development or production use
service: Conductors
title: Creating a new IBM Cloud account
runbook-name: "Creating a new IBM Cloud account"
link: /ibmcloud_new_account.html
type: Operations
parent: Armada Runbooks

---

Ops
{: .label .label-green}

## Overview

How to create a new IBM Cloud Account for use by the containers tribe. 
Creating a new account must only be performed by Ralph, Hannah or Colin.
The steps for setting up the account can then be followed by any SRE.

Some of the steps require different actions depending on whether the account is being created in production cloud (cloud.ibm.com) or stage cloud (test.cloud.ibm.com).

## Detailed Information

IBM Cloud accounts must only be created after approval. 
Raise a new conductors [team issue](https://github.ibm.com/alchemy-conductors/team/issues/new) and Ralph approval is required.

All IBM Cloud accounts must be owned by a unique functional id. 

## Detailed Procedure

### Create new functional id

Functional id must be created by SRE WW Manager. Add SRE WW Squad Lead as primary administrator.

- Manager needs to create a new functional id using [DRMS](https://w3.ibm.com/tools/drms/index.html?locale=en_US). 
  - See first step in [How to create a new functional id](./ops_functional_id_creation.html) for more informatin. Do not add to w3ID Password Rotation Automation.
  - Add the primary administrator 
- Owning manager and primary administrator will be sent the w3 password via email


### Configure w3id for the new functional id

To be completed by an administrator or manager of the functional id.

Note: It is best to wait 24 hours overnight for the functional id to be added to Outlook directory overnight, and to allow for the password to be changed.


- Add mailbox to personal email (this can only be completed once the functional id has been loaded into Outlook overnight)
  - From the outlook web page [https://outlook.office.com/mail/](https://outlook.office.com/mail/)
  - Click `...` next to Folders
  - Add Shared Folder or Mailbox
  - Enter the email of the functional id

- Create new secret in PIM to store the w3id password
  - Folder: [BU044-ALC-Conductor-WW-Lead-PIM](https://pimconsole.sos.ibm.com/SecretServer/app/#/secrets/view/folder/20001)
  - Use template: BU044-ALC Web Password
  - Secret name: `<emailaddress> w3id` e.g. `IKSProdVPCNetwork2@ibm.com w3id`
  - URL: https://w3idprofile.sso.ibm.com/password/nonperson_id_changepwd_display.wss
  - Username: emailaddress e.g. IKSProdVPCNetwork2@ibm.com
  - password: add the temporary password to the field
  - Notes: add link to issue where the account was requested.
  - Create the secret
  - Change the security settings to require checkout:  Default check out interval (30 minutes) 

- Add w3id MFA on first login to functional id
  - Open a private (incognito) browser 
  - Open w3.ibm.com
  - Prompted for Sign in - choose w3id Credentials
  - Enter functional id email address and temporary password
  - Redirected to w3id on IBM Security Verify. Add the following:
    - IBM Security Verify app for your own phone:
      - Add device
      - Connect your account
      - On phone, open ISV App and scan the QR code. Follow the instructions.

Add extra MFA options listed below, by navigating to the [w3id security settings](https://login.w3.ibm.com/usc/settings/security)
- Email:
    - New email
    -  Add your personal email address: and send code
    -  Validate email using email sent to your personal inbox
- Email:
    - New email
    - Add functional id's email address: and send code
    - Validate email using email sent to shared mailbox
- TOTP:
    - Remove existing 'authenticator app` setting that was added during first login. Note this removes ISV as an authenticator for phone, therefore need to remove ISV and add back again.
    - Follow instructions to [set up mfa for a shared user](./shared_user_ID_login.html#setting-up-mfa-for-a-shared-user), summarised here:
    - Authenticator app Setup
      - Name: "PIM <email> w3id authenticator"
      - Do not download the app, skip to next page
      - Do not scan code. Click "Problem scanning? Enter a code instead" to get the code to copy into PIM (see below)
      - Add account to your authenticator using the code 
      - Test the code.
    - Create new secret in PIM: 
      - Folder: [BU044-ALC-Conductor-WW-Lead-PIM](https://pimconsole.sos.ibm.com/SecretServer/app/#/secrets/view/folder/20001)
      - Use template: BU044-ALC API key
      -  Secret name: `<emailaddress> w3id authenticator setup` e.g. `IKSProdVPCNetwork2@ibm.com w3id authenticator setup`
      - Username: emailaddress e.g. `IKSProdVPCNetwork2@ibm.com`
      - password: code from Authenticator app setup
      - Notes: add link to issue where the account was requested.
      - Create the secret
            
### CLOUD.COM: Create IBM Cloud account using new functional id

To be completed by an administrator or manager of the functional id.

- In private browser, navigate to [registration page](https://cloud.ibm.com/registration)
- Enter functional id's email on registration page
- "Verify your identity" redirects you to `login.ibm.cloud`
- Create an IBM id
  - Takes you to `ibm.com/account/reg`
  - Email: functional id email address 
  - Enter the email of the functional id
  - Redirects to w3id, sign in with w3id userid and password
  - Redirects back to `myibm.ibm.com` with details
  - Country: US, State: Texas, Not a student, IBM
- Redirects back to `cloud.ibm.com` registration page. Select Complete your Account
- Redirects to `cloud.ibm.com/login` firstlogin page
- Continue, takes to Dashboard. IBM Cloud Account is now created.

### TEST.CLOUD.COM: Create IBM Cloud account using new functional id

To be completed by an administrator or manager of the functional id.
These steps are based on the instructions [https://test.cloud.ibm.com/docs/get-coding?topic=get-coding-test-account#create-acct](https://test.cloud.ibm.com/docs/get-coding?topic=get-coding-test-account#create-acct). 
Any difficulties ask in `#atlas-dev-environment` slack channel

- The test.cloud account has to be owned by an email in the form `<functionalid>+testaccount@mail.test.ibm.com`. For example `IKSProdVPCNetwork2+testaccount@mail.test.ibm.com`. Emails sent to this email address will be sent to the inbox of the functional id.
- In private browser, navigate to [test.cloud registration page](https://test.cloud.ibm.com/registration)
- Enter owning email on registration page (see above, and do not use the functional id's email address)
- Create a new secret in PIM:
  - Folder: [BU044-ALC-Conductor-WW-Lead-PIM](https://pimconsole.sos.ibm.com/SecretServer/app/#/secrets/view/folder/20001)
  - Use template: Web Password
  - Secret name: `<owner emailaddress> - IBM Cloud Test` e.g. `IKSProdVPCNetwork2+testaccount@test.mail.ibm.com - IBM Cloud Test`
  - Username: owner emailaddress e.g. `IKSProdVPCNetwork2+testaccount@test.mail.ibm.com`
  - password: generate a new password
  - Notes: add link to issue where the account was requested.
  - Create the secret
- Copy the password generated in the secret to the test.cloud registration page
- Personal Information: Ralph Bateman
- Accept all the terms
- Continue, takes to Dashboard. IBM Cloud Account is now created.


### CLOUD.COM: Initial configuration of IBM Cloud account
- Rename account
  - [Account Settings page](https://cloud.ibm.com/account/settings)
  - Rename account to required name.
  - Copy the account id and paste into issue for our records
- Upgrade account
  - At top of [IBM Cloud dashboard](https://cloud.ibm.com/), click "Upgrade Account"
  - Internal Paid Account
    - Country code: US (897)
    - PACT: For non-prod accounts: AAGC0. For production accounts: TBD
    - Division: 8E
    - Department: 7YL
    - Account Name: Name of the account
    - Purpose of the account: e.g. This account is used by IBM Kubernetes Service development to provision test clusters for continuous tests. 
    - Tenancy: Multi tenant
    - Security Focal,
      - Ralph Bateman
      - ralph@uk.ibm.com
      - 44-1962-818880 (take from w3 people)
    - Requestor information
      - Phone: 44-1962-818880
      - Leave rest as default
    - Click next
    - Agree to all the terms and conditions and certify all the options
    - Click Submit
    - Email sent to manager for approval


- Enable VRF and enable service endpoints

  This can only be performed after the account has been upgraded to a paid account
  - [IBM Cloud account settings](https://cloud.ibm.com/account/settings)
  - Change the following values:
    - Virtual routing and forwarding: On
    - Service endpoint: Enable

### TEST.CLOUD.COM: Initial configuration of IBM Cloud account

- Upgrade account.

  Follow the steps at [Updating (linking) a test account](https://test.cloud.ibm.com/docs/get-coding?topic=get-coding-test-account#update-acct).
  Steps are summarized here:

  - Click `Upgrade Account` on main dashboard.
  - Choose `Personal` account type.
    - Name: Ralph Bateman. 
    - Country: United Kingdom
    - Region: Hampshire
    - Address: SO21 2JN and select single result
    - Telephone: Select United Kingdom. Number 44-1962 818880
    - Confirm billing address is same
  - Credit card: use fake details provided in instructions
    - Credit card number: `4003 6800 0000 0008` or if that doesn't work, try `4111 1111 1111 1111`.
    - Expiration date: Any date in the future
   - Security code: 011
  - Accept terms and account will bu upgraded


- Rename account
  - [test.cloud Account Settings page](https://test.cloud.ibm.com/account/settings)
  - Rename account to required name. 
    Always add a space and ` TEST` at the end of the name. 
  - Copy the account id and paste into issue for our records


### Add Alchemy.Access@uk.ibm.com userid

- Log into account from CLI

  ```
  ibmcloud api test.cloud.ibm.com
  ibmcloud login --sso  
  ```

- Create `global_superadmin` access group.
  See bottom of page for permissions needed

- Invite `Alchemy.Access@uk.ibm.com` to account and add to access group.

  ```
  ibmcloud account user-invite Alchemy.Access@uk.ibm.com
  ibmcloud iam access-group-user-add global_superadmin Alchemy.Access@uk.ibm.com
  ```

- Accept the invite of `Alchemy.Access@uk.ibm.com` to the account

  - Find invitation email in the inbox of `Alchemy.Access@uk.ibm.com`
  - Copy the link in the invitation email and open in incognito browser
  - Log in to `Alchemy.Access@uk.ibm.com` using credentials stored in PIM
  
### Setting up the account

The IBM Cloud account now needs to be configured for compliance and security.

The IBM Cloud account now needs to be onboarded onto security and compliance tooling. 
  
Upgrade to premium support by reaching out to the TAM.

Details to be added.

#### global_superadmin permissions needed

```sh
#!/usr/bin/env bash
ibmcloud target

ACCESSGROUPNAME="$1"

echo "Setting up new access group: $ACCESSGROUPNAME"

read -p "Press [Enter] to continue..."

ibmcloud iam access-group-create "$ACCESSGROUPNAME"  --description "Global superadmin privileges for setting up and managing account"

# Administrator for all account management services
ibmcloud iam access-group-policy-create "$ACCESSGROUPNAME" --roles Administrator --account-management

# Administrator, Manager for all resources in the account
ibmcloud iam access-group-policy-create "$ACCESSGROUPNAME" --roles Administrator,Manager 

# Administrator of all resource groups
ibmcloud iam access-group-policy-create "$ACCESSGROUPNAME" --roles Administrator --resource-type resource-group 
```

#### Setting up a new account with account setup automation 

If a new account uses [account-setup automation](https://github.ibm.com/alchemy-conductors/boundary-account-setup), it is required to configure `Alchemy.Access@uk.ibm.com` as a superadmin. In order to avoid conflict, access-group `global_superadmin` should not be manually created but included in the account setup automation. 

The following access-policies can be applied as the minimum and if additional services are required in a new account, administrator privilege should be granted. 

```
Policy ID:   8a52cb77-e165-4173-ac0e-ed9e9e691732
Roles:       Administrator, Key Manager, Service Configuration Reader, Operator
Resources:
             Service Type   All account management services




Policy ID:   a034465c-a1da-407c-8735-96e5072b814a
Roles:       Manager, Writer, Administrator, Editor, Operator
Resources:
             Service Name   containers-kubernetes




Policy ID:   d20bfa68-baeb-48b7-ab25-75ee40573ece
Roles:       Manager, Administrator, Editor, Service Configuration Reader, Key Manager, SecretsReader
Resources:
             Service Name   secrets-manager




Policy ID:   f62d355e-1634-4275-a51e-d7a1654987e8
Roles:       UserApiKeyCreator, ServiceIdCreator, Administrator
Resources:
             service_group_id   IAM
```

#### Add IBM Cloud account APIKEY into secrets-manager 

Once `Alchemy.Access@uk.ibm.com` is added with sufficient privilege, an IBM Cloud user APIKEY needs to be created and added in the following secrets-manager.

```
IBM Cloud Account: 1185207 - Alchemy Production 
Secrets-manger Instance: iks-access-management-secrets-manager
```
Here is how to add a secret. 
```
Secret type: Arbitrary
Secret group: Default
Secret name: cloud.ibm.com_[account_name] or test.cloud.ibm.com_[account_name]
```

Once the secret is added, IKS SRE automations are ready to use. 


Service Onboarding for test.cloud.ibm.com
---

In preprod environment, some services require explictly onboarding process to add a new account into a service allowlist. Also, in some occassions (eg, owner email suffix @mail.test.cloud.ibm.com is not automatically considered as an internal account), our new account might not be recognised as an internal account so services are not automatically accessible. 

- Key-Protect: KP service requires to submit a request to onboard new account - https://github.ibm.com/kms/customer-issues/issues
- ICD: ICD databases are not available in test.cloud.ibm.com
- resource-controller: if a new account is having an issue with `resource-controller`, need to reach out the service team via the slack channel `#rc-adopters` `C4V9KLLEL`
- Secrets-manager: if a Secrets-manager service provisioning is not available, need to reach out the service team via the slack channel `#secrets-manager-adopters` `C010Z1DQ05N`

In case we need to keep the account from the regular clean up in test.cloud.ibm.com, we need to add our accounts into the following project to be excluded from the cleanup

https://github.ibm.com/cloudlab/staging-cleaner/blob/main/config/config-dal.yaml



