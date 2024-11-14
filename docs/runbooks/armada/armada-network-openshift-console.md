---
layout: default
title: ROKS - Openshift Console
runbook-name: "ROKS - Openshift Console"
tags: ROKS openshift network troubleshooting
description: "ROKS - Openshift Console"
service: armada-network
link: /armada/armada-network-openshift-console.html
type: Troubleshooting
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Troubleshooting
{: .label .label-red}

## Overview

This runbook describes common problems customers have while trying to connect to and use the openshift console and how to resolve them

## Example Alerts

This is a runbook the support team or SREs can use when a customer can not connect to or use their openshift console.  It is not tied to any specific alerts

## Investigation and Action

If the user can not access the openshift console, here are some things to check.

### Check that the user is using the right URL

Customer tickets should already have the: `ibmcloud ks cluster get -c <CLUSTER_NAME>` output.  If not, ask for it as part of the "must gather" list here https://github.ibm.com/ACS-PaaS-Core/MustGathers/blob/master/Kubernetes/Networking/networking.md that the ACS team has for IKS/ROKS Networking.  Make sure the customer is using the "Public Service Endpoint URL" entry as the console URL.  If the cluster is private service endpoint only, this entry will be the private URL.  Also make sure this entry has the `-e` in it.

### Check the Health of the Ingress for the Customer Cluster

The customer ticket should already have the: `ibmcloud ks cluster get -c <CLUSTER_NAME>` output.  If not, ask for it as part of the "must gather" list here https://github.ibm.com/ACS-PaaS-Core/MustGathers/blob/master/Kubernetes/Networking/networking.md that the ACS team has for IKS/ROKS Networking.  The output should show valid values in all the ingress fields.  If not, ask the customer to refer to the various Ingress and Routers Troubleshooting docs: [https://cloud.ibm.com/docs/openshift?topic=openshift-ingress-status](https://cloud.ibm.com/docs/openshift?topic=openshift-ingress-status)

### Check Health of Ingress and Console pods

Run get-master-info on the cluster, search for "CLUSTER PODS" in the output, and verify that the `openshift-ingress/router-default` pods and the `openshift-console/console` pods are Running and don't have a lot of restarts.  If they aren't running or have a lot of restarts, ask the Ingress team to investigate (or the ingress team can provide a link to a runbook or other docs to put here)

### Check LoadBalancer for Ingress/Router

Run get-master-info, search for "CLUSTER SERVICES", and find the openshift-ingress/router-default LoadBalancer service, verify that it has an EXTERNAL-IP
1. If a Classic cluster
    - EXTERNAL-IP should be a portable IP, and must be a public IP (i.e. NOT a 10.x.x.x IP).  We don't support accessing the Openshift Console via private router in ROKS on Classic
    - Look for two `ibm-system/ibm-cloud-provider-ip-<PORTABLE_IP>-...` pods
    - Make sure both of these pods are in Running state
        - If only one node in the VLAN the service is in, then one should be Running, other should be Pending
        - If only one node in the VLAN is tainted with the `dedicated=edge` taint, then one should be in Running, other should be in pending
2. If VPC Cluster
    - EXTERNAL-IP should be a hostname for the LBaaS created in the customer account
    - If the customer cluster has ONLY a private service endpoint (no public service endpoint), so the console url has `private` in it, then use `nslookup <EXTERNAL_ADDRESS_HOSTNAME>` to verify that EXTERNAL-IP hostname resolves to two IPs that are in the same VPC as the cluster
    - If the customer cluster has a public service endpoint, meaning the console url is the public one (so the console url doesn't have `private` in it), then use `nslookup <EXTERNAL_ADDRESS_HOSTNAME>` to verify this resolves to two public IPs

If any of these are not the case, follow one of these runbooks to troubleshoot the LoadBalancer:
    - Classic Cluster: [Classic LoadBalancer Troubleshooting Runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-network-load-balancer-troubleshooting.html)
    - VPC Cluster: [VPC LoadBalancer Troubleshooting Runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/armada-network-vpc-load-balancer-troubleshooting.html)

### Error Message in Web Browser "An authentication error occurred"

If the customer logs in with their user/password and 2FA code, and then gets a page that displays the error "An authentication error occurred", then one cause could be that the customer has set up IAM with an IP allowlist.  Customers can go into their IBM Cloud account and specify a list of IPs that are allowed to contact IAM (i.e. to log in to their cloud account).  If the customer sets this, they must also add the IP CIDRs for all our control plane workers for the carrier/tugboat their master is on.  These are documented here: https://github.com/IBM-Cloud/kube-samples/tree/master/iam-firewall-ips  It is the oauth pods that are running in the customer master need to be able to access IAM on behalf of the customer as described in step 4 of the "Detailed Openshift Console Network Flows" section below.

If the customer tries to log into the Openshift console, but after entering their user/password and 2FA code, gets an error "An authentication error occurred. " when they are redirected to the `https://cXXX-e.<region>.containers.cloud.ibm.com:<OAUTH_NODEPORT>/oauth2callback/IAM?state=...&code=...` URL, then this could be the problem.  This can be checked by running a get-master-info for the cluster, and looking at the oauth pod logs in the customer master.  Search the get-master-info for something like the following:

~~~
MASTER CONTROL PLANE CONTAINER LOGS: (oauth-openshift-...

...
E0305 20:48:38.349606       1 errorpage.go:28] AuthenticationError: Invalid status code (401): 401 Unauthorized
~~~

The `401 Unauthorized` usually means an IAM Allowlist is blocking the request.  If there is some other error, then it probably isn't the allowlist.

### Check Status of the Ingress and Console Operators

Run `oc get clusteroperators` using get-master-info or ask the customer to run it, and make sure that the Ingress and Console operators have Available set to True, and Progressing and Degraded set to False.  If either of those are not fully available, use the below to ensure that the necessary connections are allowed

#### VPC
1. Follow https://cloud.ibm.com/docs/openshift?topic=openshift-vpc-security-group to check the customer's worker security groups
2. Follow the VPC LoadBalancer Troubleshooting doc https://cloud.ibm.com/docs/openshift?topic=openshift-vpc_ts_lb to ensure the VPC LoadBalancer that handles the Openshift Console traffic is allowing traffic through its Security Group.  Note I have documentation issue https://github.ibm.com/alchemy-containers/documentation/issues/8546 open to improve these docs.

#### Classic

The following egress from cluster worker/pods must be allowed:

1. Openshift Console pods and the cluster workers must have access to the IBM Control Plane IPs to connect to Oauth, see the VPC docs here: https://cloud.ibm.com/docs/openshift?topic=openshift-vpc-security-group#worker-node-public-service-endpoint for how to get those IPs and OAuth NodePort
2. Openshift Console Operator and Ingress Operator pods and the cluster workers must have access to the public LoadBalancer for the Ingress/Router in order to do health checks.  To get that IP, see the VPC docs here: https://cloud.ibm.com/docs/openshift?topic=openshift-vpc-security-group#vpc-security-group-loadbalancer-outbound

### For Private Only VPC Clusters, Check that VPN has the Correct Routes

From the system/client running the web browser the customer is using to connect to the Openshift console, make sure they can connect to the following.

1. The "Public Service Endpoint URL", which in the `cluster get` output should look like: `https://cXXX-e.private.<region>.containers.cloud.ibm.com:<APISERVER_NODEPORT>`  This resolves to one of several private CSEs in IBM Cloud.  Note that the client must be able to access both the apiserver nodeport as well as the oauth nodeport, which will both be in the 30,000 - 32,767 port range.
2. The Openshift console URL, which should look like: `https://console-openshift-console.<CLUSTER_SPECIFIC_INFO>.<region>.containers.appdomain.cloud/`  The part after `console-openshift-console.` can be found in the `cluster get` output labeled: `Ingress Subdomain`.  This is the URL to the Openshift cluster private LoadBalancer that exposes the cluster Ingress/routes, and resolves to several private IPs in the customer's VPC.  It needs to be accessible from the client to destination port 443.
3. Various public IBM Cloud IAM and login URLs (*.iam.cloud.ibm.com and login.ibm.com).  These resolve to a large number of IPs, and they need to be accessible to destination port 443.

The first two URLs resolve to private IPs inside IBM Cloud, so the client system needs to either be running inside IBM Cloud with access to the customer's VPC, or must have a VPN or other private connection into IBM Cloud and the customer's VPC.  The URLs in the third item are public, so the client system needs public internet access. We do not have a good way to specify all the IPs that these public IAM/2FA URLs use, and right now these must be contacted over the public network.  So the customer needs to allow public egress from their client system they are running the web browser on to all IPs for destination port 443, or they need to be able to filter access to these by hostname.

### For All Classic clusters, and Public Service Endpoint VPC Clusters, Ensure Client Access

From the system/client running the web browser the customer is using to connect to the Openshift console, make sure they can connect to the following.

1. The "Public Service Endpoint URL", which in the `cluster get` output should look like: `https://cXXX-e.<region>.containers.cloud.ibm.com:<APISERVER_NODEPORT>`  Note that the client must be able to access both the apiserver nodeport as well as the oauth nodeport, which will both be in the 30,000 - 32,767 port range.
2. The Openshift console URL, which should look like: `https://console-openshift-console.<CLUSTER_SPECIFIC_INFO>.<region>.containers.appdomain.cloud/`  The part after `console-openshift-console.` can be found in the `cluster get` output labeled: `Ingress Subdomain`.  This is the URL to the Openshift cluster public LoadBalancer that exposes the cluster Ingress/routes.  For VPC clusters it resolves to several public IPs for the VPC LBaaS.  For Classic clusters resolves to a single public portable IP that is assigned to one of the cluster workers.  It needs to be accessible from the client to destination port 443.
3. Various public IBM Cloud IAM and login URLs (*.iam.cloud.ibm.com and login.ibm.com).  These resolve to a large number of IPs, and they need to be accessible to destination port 443.

The URLs in the third item are public, so the client system needs public internet access. We do not have a good way to specify all the IPs that these public IAM/2FA URLs use, and right now these must be contacted over the public network.  So the customer needs to allow public egress from their client system they are running the web browser on to all IPs for destination port 443, or they need to be able to filter access to these by hostname.

To troubleshoot, an IBM support person, SRE, or developer can try to access the customer's console URL.  It should at least get you to the User/Password prompt (but don't try to log in, that might just log/audit a failed login attempt that would bother the customer).  If you can get to the User/Password prompt, that lets you know at least the basics are working

### Calico Policies for Classic Cluster Workers

If the customer uses Calico policies to restrict access to the classic workers or to the console or ingress pods, they need to allow:

1. Ingress to tcp port 443 on the public worker interface for each worker
2. Ingress to the openshift-console/console and openshift-ingress/router-default pods
3. The Egress connections mentioned above in "Check Status of the Ingress and Console Operators"

## Detailed Openshift Console Network Flows

Here are the connections that are made in order to log in to the Openshift Console.  This is meant as a guide for more detailed troubleshooting if the above steps do not reveal the problem.

1. User tries to access the URL for the console, which is something like the following (with `.private` after the `cXXX-e` part if the cluster is VPC and private service endpoint only):
    - Prod (private service endpoint only VPC cluster): `https://cXXX-e.private.<region>.containers.cloud.ibm.com:<APISERVER_NODEPORT>`
    - Prod (all others): `https://cXXX-e.<region>.containers.cloud.ibm.com:<APISERVER_NODEPORT>`
    - Stage: `https://cXXX-e.containers.test.cloud.ibm.com:<APISERVER_NODEPORT>`
2. The fact that the url uses the `-e` after the cXXX tugboat designation signals for Openshift to use a "real" cert (signed by a valid CA) instead of using the self-signed cert.  I believe this is specified in the openshift-api deployment yaml
    - Stage: Note that for stage it doesn't use a cert signed by a valid CA, so you will get a warning about an untrusted certificate, in firefox it will be: "Warning: Potential Security Risk Ahead".  The details will say "Firefox does not trust console-openshift-console.....us-south.stg.containers.appdomain.cloud because its certificate issuer is unknown, the certificate is self-signed, or the server is not sending the correct intermediate certificates.  Error code: SEC_ERROR_UNKNOWN_ISSUER".  Choose to "Accept the Risk and Continue"
3. That URL returns the cert, and then redirects the browser to the URL for the openshift router/ingress LoadBalancer for the customer's cluster:
    - Prod: `https://console-openshift-console.<CLUSTER_SPECIFIC_INFO>.region.containers.appdomain.cloud/`
    - Stage: `https://console-openshift-console.<CLUSTER_SPECIFIC_INFO>.us-south.stg.containers.appdomain.cloud/`
    - This openshift console URL is for a k8s LoadBalancer (either Classic LBV1 in-cluster Loadbalancer, or VPC LBaaS, depending on the cluster type)
    - The load balancer sends traffic to the openshift-ingress/router-default pods
    - The router-default pods send the traffic to the openshift-console/console pods to handle the actual request
4. The console pods do the following:
    - Calls the apiserver's `/.well-known/oauth-authorization-server` endpoint (can mimic this with `kubectl get --raw /.well-known/oauth-authorization-server`) which returns content like:

       ~~~
       "issuer": "https://cXXX-e.<region>.containers.cloud.ibm.com:<OAUTH_NODEPORT>",
       "authorization_endpoint": "https://cXXX-e.<region>.containers.cloud.ibm.com:<OAUTH_NODEPORT>/oauth/authorize",
       "token_endpoint": "https://cXXX-e.<region>.containers.cloud.ibm.com:<OAUTH_NODEPORT>/oauth/token",
       ~~~

    - If the cluster public endpoint is enabled those will be public endpoints as shown. If the cluster is VPC and its public endpoint is disabled (i.e. private service endpoint only) those will be private endpoints like: `https://cXXX-e.private.<region>.containers.cloud.ibm.com:<OAUTH_NODEPORT>/...`
    - The console pod calls the token_endpoint and if the call to the token_endpoint is made successfully, and the user is already logged in, it will show the openshift console
        - If the user needs to log in to the openshift console, this code will generate the redirect in the next step.
        - If the token_endpoint can not be reached, then the browser will show an error.  This call to the token_endpoint can be a problem with public + private service endpoint clusters if console pods do not have access to the internet (i.e. if the customer added some private-only classic workers, is restricting egress to that public URL, or added VPC workers in a subnet without a public gateway).  In those cases the console pod can't get to that Oauth Nodeport, and the console pod logs will show something like what is below.  To resolve this the customer must make sure all their workers have access to this public URL.

       ~~~
       2021-02-18T22:30:40Z auth: error contacting auth provider (retrying in 10s): request to OAuth issuer
       endpoint https://c100-e.us-south.containers.cloud.ibm.com:32185/oauth/token failed:
       Head https://c100-e.us-south.containers.cloud.ibm.com:32185: net/http: request canceled while waiting
       for connection (Client.Timeout exceeded while awaiting headers)
       ~~~

5. Assuming step 4 works (oauth NodePort) and the customer has not logged in from this browser recently, this redirects the web browser again several times, eventually to the login.ibm.com page, which asks for the user's credentials in order to log them in to the openshift console.  The chain of redirections (which all must be accessible from the client web browser) is something like:
    - Prod:
        - `https://c101-e.jp-osa.containers.cloud.ibm.com:31876/oauth/authorize?client_id=console&redirect_uri=...`
        - `https://iam.cloud.ibm.com/identity/authorize?client_id=kubernetes-openshift&redirect_uri=...`
        - `https://identity-3.us-south.iam.cloud.ibm.com/identity/authorize?client_id=kubernetes-openshift&response_type=code&scope=openid&redirect_uri=...`
        - `https://login.ibm.com/oidc/endpoint/default/authorize?client_id=...&state=initiating_transaction_id_...&nonce=...&response_type=code&redirect_uri=...`
        - `https://login.ibm.com/authsvc/mtfim/sps/authsvc?PolicyId=urn:ibm:security:authentication:asf:basicldapuser&Target=...`
    - Prod VPC Private Service Endpoint Only:
        - `https://c100-e.private.us-east.containers.cloud.ibm.com:30958/oauth/authorize?client_id=console&redirect_uri=...`
        - same redirects as other Prod clusters, see the list above
    - Stage:
        - `https://c100-e.containers.test.cloud.ibm.com:30243/oauth/authorize?client_id=console&redirect_uri=...`
        - `https://iam.test.cloud.ibm.com/identity/authorize?client_id=kubernetes-openshift&redirect_uri=...`
        - `https://identity-1.us-south.iam.test.cloud.ibm.com/identity/authorize?client_id=kubernetes-openshift&response_type=code&scope=openid&redirect_uri=...`
        - `https://login.ibm.com/oidc/endpoint/default/authorize?client_id=...&state=initiating_transaction_id_...&nonce=...&response_type=code&redirect_uri=...`
        - `https://login.ibm.com/authsvc/mtfim/sps/authsvc?PolicyId=urn:ibm:security:authentication:asf:basicldapuser&Target=...`
6. After entering the user id and password, if 2 Factor Authentication (2FA) is needed, it redirects several more times before getting to where the user needs to enter their 2FA code.  The chain of redirections is something like this:
    - Prod:
        - `https://login.ibm.com/oidc/endpoint/default/authorize?qsId=...&client_id=...`
        - `https://identity-1.us-south.iam.cloud.ibm.com/oidc/callback/IBMid?code=...`
        - `https://identity-2.us-south.iam.cloud.ibm.com/ui/mfa-authenticate.jsp`
    - Stage:
        - `https://login.ibm.com/oidc/endpoint/default/authorize?qsId=...&client_id=...`
        - `https://identity-1.us-south.iam.test.cloud.ibm.com/oidc/callback/IBMid?code=...`
        - `https://identity-2.us-south.iam.test.cloud.ibm.com/ui/mfa-authenticate.jsp`

7. Once the 2FA code is entered, it redirects a few more times and eventually back to the Openshift Console page:
    - Prod:
        - `https://c101-e.jp-osa.containers.cloud.ibm.com:31876/oauth2callback/IAM?state=...&code=...`
        - `https://c101-e.jp-osa.containers.cloud.ibm.com:31876/oauth/authorize?client_id=console&redirect_uri=https%3A%2F%2Fconsole-openshift-console...&response_type=code&scope=user...`
        - `https://console-openshift-console.<CLUSTER_SPECIFIC_INFO>.<region>.containers.appdomain.cloud/`
    - Prod VPC Private Service Endpoint Only:
        - `https://c101-e.private.jp-osa.containers.cloud.ibm.com:31876/oauth2callback/IAM?state=...&code=...`
        - `https://c101-e.private.jp-osa.containers.cloud.ibm.com:31876/oauth/authorize?client_id=console&redirect_uri=https%3A%2F%2Fconsole-openshift-console...&response_type=code&scope=user...`
        - `https://console-openshift-console.<CLUSTER_SPECIFIC_INFO>.<region>.containers.appdomain.cloud/`
    - Stage:
        - `https://c100-e.containers.test.cloud.ibm.com:30243/oauth2callback/IAM?state=...&code=...`
        - `https://c100-e.containers.test.cloud.ibm.com:30243/oauth/authorize?client_id=console&redirect_uri=https%3A%2F%2Fconsole-openshift-console...&response_type=code&scope=user...`
        - `https://console-openshift-console.<CLUSTER_SPECIFIC_INFO>.us-south.stg.containers.appdomain.cloud/`

8. If all goes well you will end up at the Openshift Console

## Suggestion For Troubleshooting all the URL Redirection

There are several URL redirection actions involved in a successful connection to the Openshift Console as described above.  If you or a customer are having problems figuring out which one is the problem, here is a way to see a list with each redirection to try to figure out which one fails.

1. Use Firefox and open a new "Private Window" so no cookies or other shared credentials are around that might already have login info to IBM Cloud
2. Type about:config in the URL box, then search for the `devtools.netmonitor.persistlog` config value and set it to `true`
3. Open a second tab, use F12 in that tab which should open debugging window in the bottom part of the screen.
4. Select the network tab in the debugging , and click the "trash" icon to clear the list
5. If you are trying to connect to a private service endpoint only VPC ROKS cluster Openshift Console, make sure you are connected to a VPN for your VPC
6. Try to connect to the openshift console via the console URL, typically it is something like: `https://c111-e.[private.]us-east.containers.cloud.ibm.com:31864/console`
7. If you are prompted for your IBM password, 2FA, etc, just enter it as you normally would
8. Check the list of redirects in the debugging window at the bottom to see if you can see where they finally stop/fail
9. Once you are done, type about:config in the URL box again, search for the `devtools.netmonitor.persistlog` config value and set it back to `false`

## Escalation Policy

If the problem appears to be with the ROKS Ingress, escalate to the ingress team.  If the problem appears to be related to the LoadBalancer in front of the Ingress, then escalate to the Network team.
