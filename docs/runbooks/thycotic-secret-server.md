---
layout: default
description: Details how conductors use Thycotic's Secret Server to manage access to priviledged accounts
title: Thycotic Secret Server
service: conductors
runbook-name: "Thycotic Secret Server"
tags: alchemy, thycotic, secret, server
link: /thycotic-secret-server.html
type: Informational
parent: Armada Runbooks

---

Informational
{: .label }

## Overview
- This runbook details how to use and manage Thycotic's Secret Server

## Detailed Information

### Login using creds managed by Secret Server
- Go to [Thycotic](https://pimconsole.sos.ibm.com/SecretServer)
- Select domain `sso.ad.isops.ibm.com` on the login page, and use your SOS IDMgt id to login. 
- Once inside, go to `Tools->Launcher Tools->Web Password Filler` and follow directions.
- Go to the website that you would like to log in to.
- When prompted for the password, click the bookmark created in the step above.

### Add a new secret for a website
- Login to [Thycotic](https://pimconsole.sos.ibm.com/SecretServer).
- Select appropriate folder to create the secret in from the left panel.
- On the home page, select the dropdown under Create Secret.
- Select Web Password.
- Fill in required info, and click save. URL should be the url where the login is. Secret Policy = No Policy, Site = Local
- Ensure the secret has `Require Check Out` set to `Yes`.
- Go to the login page and click the bookmark to test the secret config. If it is not working, select Edit from the Thycotic form that appeared on the page. You may have to manually configure the username, password, and login buttons. Known issue: If it is a non-standard login, one that does not contain all three fields on a single page, you will not be able to configure the login button.

### Edit existing secret
- Select the containing folder of the secret.
- Click the secret, then click Edit.

### Logs
- Complete logs for secret activity are provided via email. Please contact #sos-pim if you would like to receive these emails. Currently the conductor squad leads and the conductor global lead are receiving these emails: `[SecretServer] Scheduled Report - BU044 ALC Secret Activity Today`, `[SecretServer] Scheduled Report - BU044 ALC Accessed Secrets Weekly`,`[SecretServer] Scheduled Report - BU044 ALC Folder Permissions Weekly`
- Alternatively, you can also look at activity for an individual secret by going to [Thycotic](https://pimconsole.sos.ibm.com/SecretServer), selecting the secret, then selecting "View Audit".

## Further Information
- Slack [#conductors](https://ibm-argonauts.slack.com/messages/C54H08JSK) for further info on this topic
