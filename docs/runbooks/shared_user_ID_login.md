---
layout: default
title: Shared user ID login
type: Informational
runbook-name: Shared user ID login
description: Shared user ID login instructions 
category: Armada
service: Privileged Identity Management
tags: Privileged Identity Management, Armada, PIM
parent: Armada Runbooks

---

Informational
{: .label }

## Overview

Shared user ID credentials are stored in Thycotic and in some cases the user will be subject to IBM Cloud MFA (multi-factor auth). This runbook will detail how to access credentials and login with these users. 

## Detailed Information

### Making use of a shared user

Normal use of Thycotic procedures are followed but with the potential dependencies eg. MFA support.

#### Non-MFA shared user

Find the required credentials in [Thycotic](https://pim.sos.ibm.com/) for the given ID and use the **username** and **password** to login.

_NB. This approach should work **as is**, and hence no further action should be required._

#### MFA shared user

For MFA-enabled shared user, a slightly different approach is required, depending on whether **you** have setup MFA on **your** verifier or not.  
_Before using an MFA enabled share user you will need to setup your authenticator_

- Steps to set up your authenticator (only required for "new to you" users):
   1. Find **authenticator** code for the user in question in [Thycotic](https://pim.sos.ibm.com/)  
   _There will be a separate secret for the user ID with "Authenticator code" in the name_
   
   1. Go to your authenticator app of your choice and add a new code.  
   _All the apps I tested will ask you if you want to add using QR or setup code. Select Setup code._
   
   1. Add the details of the:
      - ID name (only has to be meaningful to you)
      - enter the setup code
      - ensure time-based is selected
      
   1. You should be asked to confirm using 6 digit code from the authenticator
   
1. Find the required credentials in [Thycotic](https://pim.sos.ibm.com/) for the given ID and use the **username** and **password** to login.  
_Exactly as per normal, above, and **not** the "xxxxx Authenticator code" version_

1. Respond to the MFA challenge



### Setting up MFA for a shared user

The first time you try to log into IBMcloud as a shared user when MFA has been enabled you will be prompted to set it up.
these instructions tell you exactly what to do and the conventions in place.

the setup 2FA challenge will look like this: https://github.ibm.com/alchemy-conductors/team/issues/9487#issuecomment-26165983

   - **Pre-reqs** You will need the following:
      - access to the shared ID's email  
   _often access is possible through: https://d06ml001.portsmouth.uk.ibm.com/_
      - the owning managers email  
   _they **will** need to be available_

1. for the first verification method, select email and use the email of the shared ID  
you will need to get the one time code sent to that email address (get it from: https://d06ml001.portsmouth.uk.ibm.com/ )

1. for the seccond verification, select email and use the owning managers email address  
_the manager/owner will need to check their mail and send you the one time code_

1. lastly, an authenticator QR code will be provided along with a **long string** code, but **DO NOT USE THE QR code!**

   Instead... 
      - _**NOTING the following**_:
         - moment you verify, this code will disappear!
         - there is a time limit to verify the authenticator  
      _hence copy down the string to store in thycotic shortly, then set up the time based authenticator using it before adding to thycotic!_
   
   1. Create a new thycotic entry, in the same thycotic folder as the original secret, appending "Authenticator code"  
   For example, if the ID's password is stored in thycotic as:  
   `alchcond@uk.ibm.com - IBMid`  
   then store the authenticator code in a new secret,  
   `alchcond@uk.ibm.com - IBMid Authenticator code`
   
   1. Store the **long string** (from below the QR code) in the new thycotic secret's password field  
   _this is the code that people will need to put into their autenticator apps_
   
   1. add the following note to the secret:
      ```
      Used for setting up a 2FA TOTP client on your phone
      Runbook: https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/shared_user_ID_login.html
      ```
