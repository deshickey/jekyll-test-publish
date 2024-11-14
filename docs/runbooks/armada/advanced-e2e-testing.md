---
layout: default
description: "Armada - Testing with the advanced-e2e framework"
title: "Armada - Testing with the advanced-e2e framework"
runbook-name: "Armada - Testing with the advanced-e2e framework"
service: armada
tags: cruiser, worker, node, access, login, alchemy, armada, containers, kubernetes, pod, test, testing, end-to-end, e2e, advanced-e2e, test suite
link: /armada/advanced-e2e-testing.html
type: Informational
playbooks: []
failure: []
parent: Armada
grand_parent: Armada Runbooks
---

Informational
{: .label }


# Testing Armada with the advanced-e2e test framework

The [advanced-e2e](https://pages.github.ibm.com/alchemy-containers/advanced-e2e) test framework provides support for testing Armada using a variety of test suites. The framework can also be easily extended by implementing additional test cases, test suites, or providing existing test cases given they follow some basic requirements. The common usage of the framework is using an existing test suite to perform deployment verification of a new environment, perform verfication during the kubernetes upgrade process, and to provide an instrument to execute the existing PVG integration tests outside of the PVG pipeline.

**NOTE: There is an issue with running the test framework locally when attempting log to files ([logging_handlers=file](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/orcus_configuration.md#logger)). You may need to manually create the */var/log/orcus* directory and give it the proper permissions/ownership prior to testing. A solution to this issue isn't ideal and it is recommended to run the [docker container](#docker-container) rather than running locally.**


## Overview

This runbook provides instructions on [installation/build](#installationbuild), [setup and configuration](#setup-and-configuration), [running a test suite](#running-a-test-suite), and some links to [further reading](#further-reading).


<!---(NOTE-cjschaef-: This runbook doesn't make sense to have a '## Detailed Information' section, so we skip it)--->


## Testing with Jenkins

Rather than setting up and running the advanced-e2e framework locally, you can also utilize the [advanced-e2e Jenkins job](https://alchemy-containers-jenkins.swg-devops.com/job/Containers-Runtime/job/advanced-e2e-test/) instead. The options are much more limited, but it can be a quick option to running a test suite against a certain region. You can find more details in the [advanced-e2e Jenkins runbook](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/advanced-e2e-jenkins-testing.html) on using the job.


## Installation/Build

There are multiple ways to install the advanced-e2e framework. This will depend on how you wish to execute the tests, but the quickest way is to use the [install tool](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/tools/install_orcus.sh) (info in [tools README](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/tools/README.md)).

**NOTE: Although multiple releases are mentioned throughout this document, it is best to use the most recent [release](https://github.ibm.com/alchemy-containers/advanced-e2e/releases) when running tests.**


### Local virtualenv

Before using the [install tool](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/tools/install_orcus.sh), you will first want to setup a virtual envionrment to install the framework in. However, it is very important to remember that you will need some additional components in order to run locally, see the [requirements](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/README.md#requirements) for more information.

```bash
# create a virtual environment
advanced-e2e$ virtualenv orcus_testing
# activate the virtual environment
advanced-e2e$ . orcus_testing/bin/activate
# install the framework
advanced-e2e$ tools/install_orcus.sh
```


### Docker container

Another common usage for the framework is running it inside a docker container. In order to do this, you can pull an existing image from the IBM registry for a [tagged release](https://github.ibm.com/alchemy-containers/advanced-e2e/releases) of the framework (documentation on the [advanced-e2e releases](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/CHANGELOG.md)).

```bash
# login to the US South registry, you may need to run as 'sudo'
$ ibmcloud cr login registry.ng.bluemix.net
...
# pull down the 'v2.4.0' release (but check for newer releases) of the framework from the US South registry, you may need to run as 'sudo'
$ docker pull registry.ng.bluemix.net/armada/advanced-e2e:v2.4.0
```

You can find instructions for running the docker image in the [Examples](#examples) section below. You can also build a docker image locally, after cloning the repository locally:

```bash
# clone the repo locally
$ git clone git@github.ibm.com:alchemy-containers/advanced-e2e.git
$ cd advanced-e2e
# build the local code (with or without your local changes), you may need to run as 'sudo'
advanced-e2e$ make builddocker
```

Additional information about installing the framework is provided in the [README](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/README.md#install) file too.

## Setup and configuration

Once you have the framework installed locally, or have downloaded the docker image, you will want to make sure you check/modify the configuration for the framework to execute the tests how you want to. If you have a copy of the configuration file already and simply wish to use that instead of defaulting to the configuration file included in the repository or docker image, you can provide it as a CLI [argument](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/README.md#arguments) when starting the tests.

```bash
advanced-e2e$ orcus/main.py --config /home/syadmin/my_files/my_orcus.conf ...
```

Or you can mount it to a docker container image where ever you would like and also specify its location, if not a default location.

```bash
# mount a volume to the docker container containing your configuration file (/home/sysadmin/my_files/my_orcus.conf)
advanced-e2e$ docker -it run -v /home/sysadmin/my_files:/orcus/config ...
bash# orcus/main.py --config /orcus/config/my_orcus.conf ...
```

You can find more information about the configuration setting and values in the [configuration doc](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/orcus_configuration.md).


## Running a test suite

Once you have the framework installed/built/downloaded and configured how you like, you should then be ready to run a test suite. A test suite provides a significant amount of automation and configuration setup for its suite of test cases. The most significant difference you will find with the existing test suites is whether a new cluster is created at run time by the test suite, or one is already expected to be ready for testing.

One other item to keep in mind is where the framework expects to find the **test cases**. You can either provide the path to the test cases as **test_cases_location** in the [test suite](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/orcus_configuration.md#test_suite) section of the [orcus configuration](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/etc/orcus/orcus.conf). Or you can provide an override as an argument to the CLI command (shown below):

```bash
# this is typically only necessary when running tests locally without using a docker container
advanced-e2e$ orcus/main.py --test_cases_path test_cases test_suites/armada_cruiser_test_suite.py
```

If you would like a complete e2e test process, you will find the test suites that create clusters more useful, but because of this creation process, it will take significantly longer for the test suites to run. Because of this, you may need to allocate more time for a test suite (and possibly test cases) to complete. You can do this by providing a **suite_timeout** [argument](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/README.md#arguments) or by modifying the **test_suite_timeout_seconds** value in the [configuration file](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/orcus_configuration.md#test_suite).


### Cluster creating suites

Some existing test suites which will create a new cluster, wait for the cluster to be ready for testing, run the specified test cases, and then delete the cluster are listed here:

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
    <td><a href="https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/test_suites/smoke_test_suite.py">smoke test suite</a></td>
    <td>Runs <b>smoke</b> tests against a new cruiser cluster, <a href="https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/test_suites.md#smoke-tests">test suite info</a></td>
  </tr>
</table>

In order for these suites to create a new cluster during the test, you will need to supply some credentials and configuration. See the values provided in the [armada](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/orcus_configuration.md#armada) and [armada_cruiser](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/orcus_configuration.md#armada_cruiser) configuration sections as they are used for performing the proper logins and cluster creation.

The framework is currently configured to pull the login password from a YAML file, for the use specified in the same section (truncating the email extension from the user name). As such the **leet_path** file should have a <i><b>USERNAME</b>_PASSWORD</i> value in the YAML file to obfuscate the password during testing (see the **_login** function in the [armada test case](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/orcus/plugins/armada_test_case.py). Another option is to use Vault for storing the credentials by providing a vault user path and setting the configuration value to **use_vault**.


#### Examples

Examples of running the framework for cluster creating suites (when run locally, you should provide the **test_cases_path** unless you have already configured it in the [orcus configuration](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/etc/orcus/orcus.conf):

```bash
# run local and bump the suite timeout since we expect 20-40 minutes for cluster creation
advanced-e2e$ orcus/main.py --suite_timeout=3600 --test_cases_path test_cases test_suites/armada_cruiser_test_suite.py

# run local and create a patrol cluster and test
advanced-e2e$ orcus/main.py --suite_timeout=3600 --test_cases_path test_cases test_suites/armada_patrol_test_suite.py

# use a docker container to run a test suite, you may need to run as sudo
# we mount volumes to provide credentials and also to keep log files (when *logging_handler* logs to files)
$ docker run -it -v /credentials/secrets.yml:/credentials/secrets.yml -v /var/log/orcus:/var/log/orcus --name cruiser_test_suite registry.ng.bluemix.net/armada/advanced-e2e:v2.2.2 /bin/bash -c "orcus/main.py --suite_timeout=3600 test_suite/armada_cruiser_test_suite.py"

# use a docker container, but attach to the container to run commands from within it
$ docker run -it -v /credentials/secrets.yml:/credentials/secrets.yml -v /var/log/orcus:/var/log/orcus --name patrol_test_suite registry.ng.bluemix.net/armada/advanced-e2e:v2.1.0 /bin/bash
```


### Existing cluster suites

Other test suites, which expect an existing cluster, for which you need to provide the path to your kubernetes configuration file and the name of the cluster you wish to test. The test cluster name should be provided in the [test_suite](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/orcus_configuration.md#test_suite) section of the framework configuration file. The **KUBECONFIG** path should be provided in the [shell_envars](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/orcus_configuration.md#shell_envars) section of the configuration file.

For these other test suites, you will also need to make sure you have successfully logged into the Bluemix and Container Service services, as some tests expect to run Bluemix and/or Container Service commands to collect data. See the [prerequisites](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/README.md#prerequisites) for more information about this.

<table border="2" cellpadding="10">
  <tr>
    <th>Suite</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><a href="https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/orcus/plugins/armada_test_suite.py">armada test suite</a></td>
    <td>Runs a suite of test cases against an existing cruiser cluster, provided the cluster name and <b>KUBECONFIG</b>, <a href="https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/test_suites.md#armada">test suite info</a></td>
  </tr>
  <tr>
    <td><a href="https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/test_suites/minimal_test_suite.py">minimal test suite</a></td>
    <td>Runs a minimal suite of test cases against an existing cruiser cluster, provided <b>KUBECONFIG</b>, <a href="https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/test_suites.md#minimal-tests">test suite info</a></td>
  </tr>
  <tr>
    <td><a href="https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/test_suites/paid_test_suite.py">paid test suite</a></td>
    <td>Runs a suite of test cases designed for a <b>paid</b> cluster, provided <b>KUBECONFIG</b>, <a href="https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/test_suites.md#paid-tests">test suite info</a></td>
  </tr>
</table>


You can run these suites following the same [examples](#examples) as those provided in the [Cluster creating suites](#cluster-creating-suites) section, except you should not need to bump the **suite_timeout** so high. You will also need to make sure you have completed the [prerequisites](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/README.md#prerequisites) as well.

```bash
# configure desired cluster to interact with
ibmcloud ks cluster config --cluster <cluster>

# make sure you are logged into Bluemix and Container service plugin
ibmcloud login ...
ibmcloud ks init ...

# run local tests against existing cluster
advanced-e2e$ orcus/main.py --test_cases_path test_cases orcus/plugins/armada_test_suite.py
```


### Additional test suites

These are additional test suites designed to run without a cluster. A majority of these require the same setup and configuration seen with the [cluster creating suites](#cluster-creating-suites), specifically having the Bluemix and container service configured.

<table border="2" cellpadding="10">
  <tr>
    <th>Suite</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><a href="https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/test_suites/armada_deprecated_test_suite.py">armada deprecated</a></td>
    <td>Runs a suite of test cases verifying functionality of deprecated versions of Kubernetes in Armada, <a href="https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/test_suites.md#armada-deprecated">test suite info</a></td>
  </tr>
  <tr>
    <td><a href="https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/test_suites/kube_version_test_suite.py">kube version</a></td>
    <td>Runs the <a href="https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/test_cases/test_kubernetes_versions.py">kubernetes versions test case</a> against all Armada regions (designed to be run alone), <a href="https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/test_suites.md#kubernetes-versions">test suite info</a></td>
  </tr>
</table>

In order for these suites to create a new cluster during the test, you will need to supply some credentials and configuration. See the values provided in the [armada](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/orcus_configuration.md#armada) and [armada_cruiser](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/docs/orcus_configuration.md#armada_cruiser) configuration sections as they are used for performing the proper logins and cluster creation.

The framework is currently configured to pull the login password from a YAML file, for the use specified in the same section (truncating the email extension from the user name). As such the **leet_path** file should have a <i><b>USERNAME</b>_PASSWORD</i> value in the YAML file to obfuscate the password during testing (see the **_login** function in the [armada test case](https://github.ibm.com/alchemy-containers/advanced-e2e/blob/master/orcus/plugins/armada_test_case.py). Another option is to use Vault for storing the credentials by providing a vault user path and setting the configuration value to **use_vault**.

```bash
# run the deprecated test suite
advanced-e2e$ orcus/main.py --test_cases_path test_cases test_suites/armada_deprecated_test_suite.py

# run the kubernetes versions test suite
advanced-e2e$ orcus/main.py --test_cases_path test_cases test_suites/kube_version_test_suite.py
```


## Further reading

Additional information about the advanced-e2e framework and testing can be found in the [advanced-e2e](https://github.ibm.com/alchemy-containers/advanced-e2e) repository:

- Runbook using [advanced-e2e Jenkins job](https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/runbooks/armada/advanced-e2e-jenkins-testing.html)
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
