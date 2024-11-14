---
layout: default
description: "[Informational] Addon - ALB OAuth Proxy"
title: "[Informational] Addon - ALB OAuth Proxy"
runbook-name: "[Informational] Addon - ALB OAuth Proxy"
service: armada
tags: armada, addon, kubernetes, alb, ingress, oauth, proxy
link: /armada/armada-addon-alb-oauth-proxy.html
type: Informational
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

The IBM Cloud Kubernetes Service (IKS) introduces the ALB OAuth Proxy Addon to provide a solution that integrates the [IBM Cloud App ID](https://www.ibm.com/cloud/app-id) and the Kubernetes Ingress controller based [ALB](https://cloud.ibm.com/docs/containers?topic=containers-managed-ingress-about) (Application Load Balancer). It lets customers to use the services of IBM Cloud App ID to authenticate the HTTP/HTTPS requests that are handled by the IKS ALBs.

## Detailed Information

The addon is supported on IKS clusters with Kubernetes version 1.16 or newer.

The pre-requisite of the functionality is that the customer creates an IBM Cloud App ID service instance as described [here](https://cloud.ibm.com/docs/appid?topic=appid-getting-started#create). The IBM Cloud App ID service name must start with a letter, end with a letter or digit, and have as interior characters only letters, digits, and hyphen. 

The user can manage her IBM Cloud App ID service instances [here](https://cloud.ibm.com/catalog/services/app-id)

The IBM Cloud App ID service instance must be configured with a redirect URL that must have the following schema:
`https://<domain of the protected service>/oauth2-<App_ID_service_instance_name>/callback`

The customer shall bind the IBM Cloud App ID service instance to the Kubernetes cluster with the following command: 

`ibmcloud ks cluster service bind --cluster <cluster ID> --namespace <target namespace> --service <App ID Service instance name> `

The result is a Kubernetes Secret that has the name `binding-<App ID Service instance name>` in the `<target namespace>`.

The ALB OAuth Proxy Addon watches the Ingress resources in the Kubernetes cluster via the Kubernetes API. The ALB OAuth Proxy Addon functionality is triggered when the user adds the following annotation to an Ingress resource of hers:

`nginx.ingress.kubernetes.io/auth-url: https://$host/oauth2-<App_ID_service_instance_name>/auth`

Note! The only variable in the value of the addon is the `<App_ID_service_instance_name>` part. Everything else shall be configured literally as shown above.

If this annotation appears on an Ingress resource the ALB OAuth Proxy Addon looks for the previously created binding Secret in the namespace of the Ingress resource. 

The ALB OAuth Proxy Addon uses the following information from the binding Secret:

    oauthServerURL
    clientId
    secret

The ALB OAuth Proxy Addon creates a new Secret in the namespace of the Ingress resource. The new Secret has a name like `oauth2-<App ID Service instance name>`. This new Secret contains the configuration of the OAuth2-Proxy deployment which is created as the next step.

The ALB OAuth Proxy Addon creates an [OAuth2-Proxy](https://github.com/oauth2-proxy/oauth2-proxy) Kubernetes Deployment in the namespace of the Ingress. The new Secret is configured as a Volume in the Deployment, so the OAuth2-Proxy process can read it as its config file. The new Deployment has a name like `oauth2-<App ID Service instance name>`.

The ALB OAuth Proxy Addon creates a Kubernetes Service that points to the OAuth2-Proxy Deployment in the namespace of the Ingress. The ALB OAuth Proxy Addon creates a new Ingress resource that points to this new Kubernetes Service in the namespace of the original Ingress. Both the new Service and the new Secret are created with the name like `oauth2-<App ID Service instance name>`.

For possible Ingress annotation configurations please check the docs where we explain multiple options: [Adding App ID authentication to apps](https://cloud.ibm.com/docs/containers?topic=containers-comm-ingress-annotations#app-id-auth).

## Deploying as an Addon

To check whether the ALB OAuth Proxy addon is enabled for this cluster, run:

```
ibmcloud ks cluster addon ls --cluster <CLUSTERID>
```

To enable or disable addon for this cluster, run:
```
ibmcloud ks cluster addon <enable|disable> alb-oauth-proxy --cluster <CLUSTERID>
```

## Troubleshooting
 
After installing the addon, the following components shall exist in the cluster:
  - a Custom Resource Definition called `oauthproxyversions.cloud.ibm.com`
  - a Custom Resource called `oauth2-proxy-version`
  - a Cluster Role called `addon-alb-oauth-proxy`
  - a Cluster Role Binding called `addon-alb-oauth-proxy`
  - a Service Account called `addon-alb-oauth-proxy`
  - a Deployment and a corresponding Pod called `addon-alb-oauth-proxy`
The Deployment shall have a single Pod.
If you are experiencing that the ALB OAuth Proxy Addon pod is not in a Running state, please check the following:
  - the cluster nodes are in a good condition, up and running and are joined to the cluster
  - the CPU, memory and disk usage of the node where the pod could not start
  - in case of `ImagePullBackoff` state, the registry credentials in the `kube-system` namespace
  - get-master-info job

Run the [get-master-info](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-get-master-info/) job and look for the `ALB OAUTH-PROXY ADDON` section for a summary on related resources:

```
ALB OAUTH-PROXY ADDON

ALB OAUTH-PROXY VERSION=1.0.0_165

ALB OAUTH-PROXY ADDON RESOURCES:
NAMESPACE     NAME                                         READY   STATUS    RESTARTS   AGE   IP               NODE             NOMINATED NODE   READINESS GATES
kube-system   pod/addon-alb-oauth-proxy-65f58cd75f-6hpqx   1/1     Running   0          11m   172.30.136.197   10.140.250.149   <none>           <none>

NAMESPACE     NAME                                    READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS              IMAGES                                          SELECTOR
kube-system   deployment.apps/addon-alb-oauth-proxy   1/1     1            1           7h50m   addon-alb-oauth-proxy   icr.io/obs/alb-oauth-proxy/operator:1.0.0_165   addonmanager.kubernetes.io/mode=Reconcile,app=addon-alb-oauth-proxy,name=addon-alb-oauth-proxy

NAMESPACE     NAME                                               DESIRED   CURRENT   READY   AGE     CONTAINERS              IMAGES                                          SELECTOR
kube-system   replicaset.apps/addon-alb-oauth-proxy-65f58cd75f   1         1         1       11m     addon-alb-oauth-proxy   icr.io/obs/alb-oauth-proxy/operator:1.0.0_165   addonmanager.kubernetes.io/mode=Reconcile,app=addon-alb-oauth-proxy,name=addon-alb-oauth-proxy,pod-template-hash=65f58cd75f
kube-system   replicaset.apps/addon-alb-oauth-proxy-6f9dd4bbdf   0         0         0       7h50m   addon-alb-oauth-proxy   icr.io/obs/alb-oauth-proxy/operator:1.0.0_152   addonmanager.kubernetes.io/mode=Reconcile,app=addon-alb-oauth-proxy,name=addon-alb-oauth-proxy,pod-template-hash=6f9dd4bbdf

ALB OAUTH-PROXY ADDON SERVICEACCOUNTS:
NAMESPACE     NAME                    SECRETS   AGE
kube-system   addon-alb-oauth-proxy   1         

ALB OAUTH-PROXY ADDON CLUSTERROLES:
NAME                    AGE
addon-alb-oauth-proxy   

ALB OAUTH-PROXY ADDON CLUSTERROLEBINDINGS:
NAME                    AGE
addon-alb-oauth-proxy   

ALB OAUTH-PROXY ADDON CUSTOMRESOURCEDEFINITIONS:
NAME                               CREATED AT
oauthproxyversions.cloud.ibm.com

ALB OAUTH-PROXY ADDON CUSTOMRESOURCES (OAUTHPROXYVERSIONS.CLOUD.IBM.COM):
NAMESPACE     NAME                   AGE
kube-system   oauth2-proxy-version   

INGRESS RESOURCES TO BE PROCESSED BY ALB OAUTH-PROXY ADDON:
test/tea: https://$host/oauth2-testappid/auth

SECRETS TO BE PROCESSED BY ALB OAUTH-PROXY ADDON:
test/binding-testappid

RESOURCES CREATED BY ALB OAUTH-PROXY ADDON:
NAMESPACE   NAME                                    READY   STATUS    RESTARTS   AGE     IP              NODE             NOMINATED NODE   READINESS GATES
test        pod/oauth2-testappid-559fbb5d6f-h945j   1/1     Running   0                                                   <none>           <none>
test        pod/oauth2-testappid-559fbb5d6f-rj54r   1/1     Running   0                                                   <none>           <none>

NAMESPACE   NAME                       TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE     SELECTOR
test        service/oauth2-testappid   ClusterIP                    <none>        4180/TCP           app=oauth2-testappid

NAMESPACE   NAME                               READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS     IMAGES                                                         SELECTOR
test        deployment.apps/oauth2-testappid   2/2     2            2                   oauth2-proxy   registry.ng.bluemix.net/armada-master/oauth2_proxy:v5.1.0-46   app=oauth2-testappid,app.kubernetes.io/component=oauth2-proxy-instance,app.kubernetes.io/managed-by=addon-alb-oauth-proxy,app.kubernetes.io/name=oauth2-testappid,app.kubernetes.io/part-of=test.testappid,app.kubernetes.io/version=

NAMESPACE   NAME                                          DESIRED   CURRENT   READY   AGE     CONTAINERS     IMAGES                                                         SELECTOR
test        replicaset.apps/oauth2-testappid-559fbb5d6f   2         2         2               oauth2-proxy   registry.ng.bluemix.net/armada-master/oauth2_proxy:v5.1.0-46   app=oauth2-testappid,app.kubernetes.io/component=oauth2-proxy-instance,app.kubernetes.io/managed-by=addon-alb-oauth-proxy,app.kubernetes.io/name=oauth2-testappid,app.kubernetes.io/part-of=test.testappid,app.kubernetes.io/version=,pod-template-hash=559fbb5d6f
test        replicaset.apps/oauth2-testappid-5f794f7b5c   0         0         0               oauth2-proxy   registry.ng.bluemix.net/armada-master/oauth2_proxy:v5.1.0-46   app=oauth2-testappid,app.kubernetes.io/component=oauth2-proxy-instance,app.kubernetes.io/managed-by=addon-alb-oauth-proxy,app.kubernetes.io/name=oauth2-testappid,app.kubernetes.io/part-of=test.testappid,app.kubernetes.io/version=,pod-template-hash=5f794f7b5c

INGRESSES CREATED BY ALB OAUTH-PROXY ADDON:
NAMESPACE   NAME               HOSTS          ADDRESS        PORTS     AGE
test        oauth2-testappid   mydomain.com                   

SECRETS CREATED BY ALB OAUTH-PROXY ADDON:
NAMESPACE   NAME               TYPE     DATA   AGE
test        oauth2-testappid   Opaque   1      
```

### Possible issues
1. Problems with the addon Deployment or Pod

Use the `kubectl describe` command to interrogate the detailed description of the Deployment and the Pod and look for the detailed problem description in those in their `Conditions`. Try to mitigate the problem. For example, if the container image of the addon cannot be pulled from the container registry check that the container registry secret is available in the kube-system namespace.

2. Missing addon resources

If any of the addon related resources listed here is missing, try to disable and then re-enable the addon with the `ibmcloud ks cluster addon disable|enable` commands. It is safe to execute the addon disable/enable procedure, because the resources (Ingresses, Secrets) that are created and managed by the addon are not deleted when the addon is enabled/disabled.
The addon related resources are:
  - a Custom Resource Definition called `oauthproxyversions.cloud.ibm.com`
  - a Custom Resource called `oauth2-proxy-version`
  - a Cluster Role called `addon-alb-oauth-proxy`
  - a Cluster Role Binding called `addon-alb-oauth-proxy`
  - a Service Account called `addon-alb-oauth-proxy`
  - a Deployment and a corresponding Pod called `addon-alb-oauth-proxy`

3. Missing resources that should have been generated by the addon

The addon generates and manages Kubernetes resources during its operation. Such Kubernetes resources are: Ingress, Service, Secret, Deployment. All the resources has the same naming rule: their names look like `oauth2-<App_ID_service_instance_name>`. All the resources are created in the namespace of the Ingress resource which triggers the creation of these resources. If any of these resources is missing, please try to restart the addon pod with the `kubectl delete pod` command. It is safe to delete the addon pod, because the resources (Ingresses, Secrets) that are created and managed by the addon are not deleted when the addon is enabled/disabled. Once the addon pod is up and running again it should execute a full reconciliation procedure, during which it shall generate the missing resources and it shall update the existing resources.

## Escalation Policy

Once the initial investigation is performed if there are still errors:

1. Create a GHE Issue against [armada-frontdoor](https://github.ibm.com/alchemy-containers/armada-frontdoor/issues/) and provide results from the investigation.
1. Also, inform the armada-ingress squad about the problem via slack in [#armada-ingress](https://ibm-containers.slack.com/archives/armada-ingress) with the GHE issue link.

Please collect the following information and attach that to the GHE ticket:
- [get-master-info](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/armada-deploy-get-master-info/)
- the logs of the addon pod collected with the `kubectl logs` commmand
- the logs of the OAuth2-Proxy Deployment which is misbehaving collected with the `kubectl logs` commmand
- the logs of the ALBs collected with the `kubectl logs` commmand
- the description of the addon Deployment collected with the `kubectl describe deploy addon-alb-oauth-proxy -n kube-system` command
- the description of the OAuth2-Proxy Deployments collected with the `kubectl describe deploy` command
- the content of the `nginx.conf` file from the ALB pods collected with the `kubectl exec <ALB_pod_name> -n kube-system -c ingress-nginx -- cat /etc/nginx.conf` command
- the Ingress descriptions collected with the `kubectl describe ingress <Ingress_name> -n <Ingress_Namespace> -o yaml` comamnd
- the Service descriptions collected with the `kubectl describe service <Service_name> -n <Service_namespace> -o yaml` command
- the ConfigMaps created to configure the OAuth2-Proxy Deployments with the `kubectl get configmap <ConfigMapName> -n <ConfigMap_Namespace> -o yaml` command
- the OAuthProxyVersion custom resource interrogated with the `kubectl get oauthproxyversion oauth2-proxy-version -n kube-system -o yaml` command
- the Service Account of the addon interrogated with the `kubectl get serviceaccount addon-alb-oauth-proxy -n kube-system -o yaml` command
- the Cluster Role of the addon interrogated with the `kubectl get serviceaccount addon-alb-oauth-proxy -o yaml` command
- the Cluster Role Binding of the addon interrogated with the `kubectl get clusterrolebinding addon-alb-oauth-proxy -o yaml` command
