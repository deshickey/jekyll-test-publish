---
layout: default
description: "Armada - Using Jenkins to test with the advanced-e2e framework"
title: "Armada - Using Jenkins to test with the advanced-e2e framework"
runbook-name: "Armada - Using Jenkins to test with the advanced-e2e framework"
service: armada
tags: cruiser, worker, node, access, login, alchemy, armada, containers, kubernetes, pod, test, testing, end-to-end, e2e, advanced-e2e, test suite, jenkins
link: /armada/advanced-e2e-jenkins-testing.html
type: Informational
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }


# Testing Armada using Jenkins to run the advanced-e2e test framework

The [advanced-e2e](https://pages.github.ibm.com/alchemy-containers/advanced-e2e) test framework provides support for testing Armada using a variety of test suites. The framework can also be easily extended by implementing additional test cases, test suites, or providing existing test cases given they follow some basic requirements. The common usage of the framework is using an existing test suite to perform deployment verification of a new environment, perform verfication during the kubernetes upgrade process, and to provide an instrument to execute the existing PVG integration tests outside of the PVG pipeline.


## Overview

This runbook provides details on how to use the [advanced-e2e Jenkins job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/advanced-e2e-test/) to test Armada. Details on [Running a test suite](#running-a-test-suite), including [Simplified execution and options](#simplified-execution-and-options) and [Advanced configuration](#advanced-configuration), along with [Supported test suites](#supported-test-suites) are provided below.

<!---(NOTE-cjschaef-: This runbook doesn't make sense to have a '## Detailed Information' section, so we skip it)--->


## Running a test suite

Running a test suite is rather simple, but a number of options provided by the Jenkins job can allow you to customize your testing significantly as well. If the job does not provide enough customization or options, you should reference the [Armada - Testing with the advanced-e2e framework](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/advanced-e2e-testing.html) runbook about running the framework locally instead.


### Simplified execution and options

Provided you have access you can create a new [Jenkins build of advanced-e2e](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/advanced-e2e-test/build?delay=0sec). The primary options you must provide to run are the [TEST_REGION](#test_region) and [TEST_SUITE](#test_suite). Further options are also available, and all are explained below.


#### ADVANCED_E2E_RELEASE

The [advanced-e2e release](https://github.ibm.com/alchemy-containers/advanced-e2e/releases) to use during testing. Typically you will want to use the **latest** stable release, but you can specify a certain release, or simply **master** to use the latest code. But be warned, using **master** may be less stable than an actual release.


#### TEST_REGION

The Bluemix/CS region to perform testing in. Specific datacenters are pre-selected in each region, so as to provide the proper arguments during cluster creation.


#### TEST_SUITE

The [test suite](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/test_suites.md) to execute. Please keep in mind a select number of test suites are supported by the Jenkins job due to the limitation of test suites that create clusters versus those that use existing clusters. You can see more information in the [Supported test suites](#supported-test-suites) section.


#### KUBE_VERSION

The Kubernetes version to use when creating a new cluster. The version must be in [semantic form](https://semver.org/) and include a **MAJOR** and **MINOR** version. A **PATCH** level (i.e., 1.9.x) can also be provided, but keep in mind that specific version must be valid in the given region, or the test will fail to create a cluster. You can also provide a build level (i.e., 1.9.6_xxxx) version, but again that must be valid in the given region.

**NOTE:** If you are using the [kube versions test suite](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/test_suites.md#kubernetes-versions) you must supply a **PATCH** level version (*x.y.z*) for the test to successfully run. Simply a **MINOR** or a build level version will cause failure.


#### CLEANUP_CLUSTER

This option determines whether the cluster will be automatically removed after a test run. By default, the cluster is only deleted after a successfully test and is left if part of the test suite fails. Using this flag (checked), you can force the cluster to be removed regardless of the test suite results.


#### CONFIG_OVERRIDES

This is an advanced option which provides an extremely large amount of customization. I typically don't recommend modifying this unless you have experience with the advanced-e2e framework. See the [Advanced configuration](#advanced-configuration) section for more details about this option.


### Advanced configuration

For advanced configuration of the advanced-e2e framework, you can provide a JSON formatted value to the [CONFIG_OVERRIDES](#config_overrides) option to override any default or existing [advanced-e2e configuration](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/orcus_configuration.md). This can be handy if you wish to use a different datacenter, vlans, number of worker nodes, test suite timeout, test cluster name, etc. than those provided in the default [configuration](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/etc/orcus/orcus.conf). Each of these values is overridden just prior to execution, so you can, if desired, override any of the other Jenkins options mentioned above.

When providing your overrides, specify each option as a key-value pair within a section. If you do not format the JSON properly, the job will fail prior to performing any test setup. A few examples are provided below. Please keep in mind, unnecessary whitespace can be a killer.

```
# override the default test suite timeout
{"test_suite":{"test_suite_timeout_seconds":"4800"}}

# override the test cluster name, location (datacenter), and number of workers
{"test_case":{"test_cluster":"my_new_test_cluster"},"armada_cruiser":{"location":"tok02","workers":"5"}}

# override the unsupported versions expected to be found in production
# this is used as part of the 'kube versions test suite'
# https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/test_suites.md#kubernetes-versions
{"armada":{"unsupported_versions":"1.5.4,1.5.6,1.7.6,1.7.11"}}
```

## Supported test suites

For now, only a certain set of test suites are supported by the Jenkins job. Specifically, these are test suites which perform a login to Bluemix/CS and create a new cluster to use during testing. Support to use an existing cluster (which can be significantly faster and helpful) for testing is being investigated, but the complexity may be more than desired. But keep your fingers crossed...

Please reference the [test suites](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/test_suites.md) documentation for the current list of test suites and detailed information about each test suite, although not all are supported, as mentioned above with regard to creating/existing clusters.

<table border="2" cellpadding="10">
  <tr>
    <th>Suite</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><a href="https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/orcus/plugins/armada_cruiser_test_suite.py">armada cruiser test suite</a></td>
    <td>Runs a suite of test cases against a new cruiser cluster, <a href="https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/test_suites.md#armada-cruiser">test suite info</a></td>
  </tr>
  <tr>
    <td><a href="https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/test_suites/armada_deprecated_test_suite.py">armada deprecated</a></td>
    <td>Runs a suite of test cases verifying functionality of deprecated versions of Kubernetes in Armada, <a href="https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/test_suites.md#armada-deprecated">test suite info</a></td>
  </tr>
  <tr>
    <td><a href="https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/test_suites/armada_patrol_test_suite.py">armada patrol test suite</a></td>
    <td>Runs a suite of test cases against a new patrol cluster, <a href="https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/test_suites.md#armada-patrol">test suite info</a></td>
  </tr>
  <tr>
    <td><a href="https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/test_suites/armada_preprod_cruiser_test_suite.py">armada pre-prod cruiser test suite</a></td>
    <td>Runs a suite of test cases against a new cruiser cluster in a pre-production environment, <a href="https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/test_suites.md#armada-preprod-cruiser">test suite info</a></td>
  </tr>
  <tr>
    <td><a href="https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/test_suites/bash_cruiser_test_suite.py">bash cruiser test suite</a></td>
    <td>Runs any provided bash script tests cases against a new cruiser cluster, <a href="https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/test_suites.md#bash-cruiser">test suite info</a></td>
  </tr>
  <tr>
    <td><a href="https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/test_suites/kube_version_test_suite.py">kube version</a></td>
    <td>Runs the <a href="https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/test_cases/test_kubernetes_versions.py">kubernetes versions test case</a> against all Armada regions (designed to be run alone), <a href="https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/test_suites.md#kubernetes-versions">test suite info</a></td>
  </tr>
  <tr>
    <td><a href="https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/test_suites/smoke_test_suite.py">smoke test suite</a></td>
    <td>Runs <b>smoke</b> tests against a new cruiser cluster, <a href="https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/test_suites.md#smoke-tests">test suite info</a></td>
  </tr>
</table>


## Further reading

Additional information about the advanced-e2e framework and testing can be found in the [advanced-e2e](https://github.ibm.com/alchemy-containers/advanced-e2e) repository:

- Primary [advanced-e2e runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/advanced-e2e-testing.html)
- Project [Github pages](https://pages.github.ibm.com/alchemy-containers/advanced-e2e)
- Project [README](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/README.md)
- Description of [test suites](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/test_suites.md)
- Description of [test cases](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/test_cases.md)
- [Implementation details](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/README.md#implementing)
- Release notes in [CHANGELOG](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/CHANGELOG.md)
- Description of [configuration](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/orcus_configuration.md)
- Description of [deployment templates](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/deployment_templates.md)
- Additional [tools README](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/tools/README.md)
- [Presentation materials](https://github.ibm.com/alchemy-containers/advanced-e2e/tree/master/docs/slides)
