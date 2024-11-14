---
playbooks: [<NoPlayBooksSpecified>]
layout: default
description: Overview on the firewall, its maintenance, and current configuration.
service: Firewall
title: Firewall configuration
runbook-name: "Firewall Configuration"
link: /firewall_configuration.html
type: Operations
parent: Armada Runbooks

---

Ops
{: .label .label-green}

Rev 150925

### Requesting a Firewall Change

All requests for firewall rule changes should be raised via the [*#netint*](https://ibm-cloudplatform.slack.com/messages/netint/)
channel in slack. Our helpful assistant,  *@netmax*, can provide you with the firewall template by typing:

    @netmax template

This will raise a GHE ticket which can be tracked using the [*zenhub plugin*](https://zenhub.innovate.ibm.com/setup/download)
You will also be notified of changes to your ticket via messages in the *#netint* channel.

#### Opening container ports for customers

These requests should include the following information.

  1. Customer name.
  2. Protocol: TCP, UDP or both. Most requests will likely be TCP.
  3. Port number list:
      - Use commas to separate a list of multiple ports, e.g. ```1000, 2000``` means ports 1000
        and 2000 only.
      - For a range of consecutive port numbers, use hypens e.g. ```1000-2000``` means all ports
        between 1000 and 2000 inclusive (1000, 1001, 1002, ... 1999, 2000). Note that this is
        only an example: we would not usually open such a big port range without a very good
        justification.

#### Any other firewall change

For the template to work, please ensure that you include a value for every field in the template. If you are unsure please put a comment in to explain this and we will contact you to help determine the correct value.

_PLEASE NOTE:_

  - Please request firewall changes as early as possible during development. This is because 
    the Network Intelligence squad receives many firewall requests and there is a typical lead
    time of 2 days (often longer) to deploy new rules. Changes affecting public internet access,
    cross-VLAN connections, customer containers or customer VMs are likely to take longer
    because extra security considerations apply to these higher risk areas.

  - Do not wait until immediately before your deadline to request a firewall change because it
    could delay your project. Please consider security design early: in particular, the following
    will require extra attention and may take longer:
        - anything that needs public access to/from the internet
        - anything near customer containers and VMs (e.g. at or near the Kraken machines)
        - anything that allows connectivity across VLANs

  - Due to an anomaly in the current devtest environment, some machines in devtest are in the
    wrong VLANs, e.g. some of the management group (CSMG) machines are incorrectly in the
    API (CSAP) VLANs. This means that more firewall rules may be required in staging than in
    devtest, so promotion to staging may take longer due to the extra work. We hope to make
    the devtest and staging structures consistent in future to avoid this issue.

  - We do not normally deploy new rules immediately into production environments because they
    must be deployed in devtest and staging first so that the changes can be tested. Please allow
    time for testing in devtest and staging before you proceed to production. Due to the time
    taken to move through the pipeline, some squads prefer to raise separate IDS tasks for each
    environment so that they can track progress of smaller items.

  - Please ask in the Slack #netint channel if you need help.

## Router Configuration Overview, Including Filtering and NAT

All routing (a) between subnets within an environment and (b) between
the inside and the outside of an environment is handled by a Fortigate
or a Brocade Vyatta 3600 router.  These routers can do filtering
(i.e., firewall) and NAT.

The design intent is for the Vyattas to be deployed and operated in HA
pairs, but that is not fully worked out yet.

The configuration of the Vyattas is managed through Git/Gerrit/IDS, by
the Network Intelligence squad (Slack #netint).  This configuration involves most
aspects of an environment's networking, including: what subnets are
defined and on what VLANs, the various IPSEC tunnels, the NAT between
intermediate and public IP addressse of containers and the NAT to cope
with the DNS hacks in CF's YS1, as well as the firewall behavior.

The network configuration of an environment named FOO is defined in a
model, which is a Python program named `print_FOO.py` in the
`cfgprogs` directory of the `container-service-config` project.  When
the model is run it produces some derived files used in configuring
and running the system, some of which are inputs to the Vyatta
configuration assembler.  The models are managed primarily through
[Gerrit](https://gerrit.swg-devops.com/#/admin/projects/alchemy/container-service-config);
on a good day, they are mirrored quickly to
[git](https://github.rtp.raleigh.ibm.com/project-alchemy/container-service-config).
For example, the latest model for the prod-dal09 environment can
usually be found at
https://github.rtp.raleigh.ibm.com/project-alchemy/container-service-config/blob/master/cfgprogs/print_prod-dal09.py

The firewalls are stateful, so for TCP connections and UDP or ICMP
sessions we only need to define rules that allow the connection to be
initiated.

## Firewall Maintenance

This section is intended for reference within the Network Intelligence team.

The source for the Vyatta configuration rules is stored in the container-service-config git project, 
which is maintained via its [gerrit repository](https://gerrit.swg-devops.com/#/admin/projects/alchemy/container-service-config) 
in order to enforce code reviews. Always clone from the gerrit repository because a direct push to git 
is not allowed. Ralph Bateman, Michael Spreitzer and members of the NetInt Reviewers group have the
authority to +2 approve the reviews.

Familiarity with
[the Vyatta product](http://www.brocade.com/content/brocade/en/products-services/software-networking/network-functions-virtualization/5600-vrouter.html)
is required: the Firewall and NAT sections are most useful.
Some online documentation can be found [here](http://www.brocade.com/content/html/en/administration-guide/vyatta_5400_manual/wwhelp/wwhimpl/js/html/wwhelp.htm).

Most firewall rules involve defining address-group and port-group
objects with lists of IP addresses and port numbers. In many cases the
relevant groups will already exist, so you can add extra addresses to
the existing groups.

Once these groups exist, you can add rules to the ruleset for a particular VLAN or interface 
which reference the groups for the source or destination address. Remember to compile the firewall 
rules locally after making your changes to check for inconsistencies. 

Use the container-service-config bin/query.py script to query groups, for example:
  ```bin/query.py -g groupname --rules```

Refer to the project [readme](https://github.rtp.raleigh.ibm.com/project-alchemy/container-service-config/blob/master/README.md)
for full details of how to update the firewall rules. 

## GIT hints

Remember to `git checkout master` and `git pull` as often as possible.

Keep your bags packed.

Follow normal commit message conventions.  First line is a short
summary, second line is blank.  The short summary should start with
the IDS item number and, if relevant, the name(s) of the environments
affected.

Our Git/Gerrit integration does not automatically contribute comments
to IDS/RTC, so please do that manually.  Add a comment every time you
submit a change for review.  It would also be polite to add a comment
when the change is merged, and when it is applied to the running
system.  In the latter case you might want to document the full list
of deltas you applied (e.g., by exhibiting the output of the Vyatta's
`compare` command).

### How to recover from clashing merges

One simple solution to a merge conflict is to manually rebase.  In
`http://docs.openstack.org/infra/manual/developers.html` you will find
a description that includes some OpenStack specifics but also has some
pretty generic sections.

In many cases your real source change is small, so you can simply put
a copy somewhere out of the way and start over from the current
master, referring to your original edition of your change as you
create the new edition.

The following may also be of some interest.

Scenario: You've made a number of firewall changes, run the compile-firewall.py script performed ```git add``` and then committed your changes. You try to push but discover there are changes that need to be pulled. This will enevitably end up with a horrible merge / git confict on the firewall-definition and other files

Solution:

* ```git log``` - find the commit SHA just before your commit
* ```git reset <SHA>``` - this will result in your commit being removed but all file changes kept
* ```git checkout <firewall compile output files>``` - this will revert the automated changes that usually clash
* ```git stash``` - will save your changed files and make your working copy look "clean"
* ```git pull``` - to get the latest changes
* ```git stash pop``` - to replay your changes over the top of the pop'd files
* ```bin/make-all.sh``` - to re-build the firewall definition files


## Current Firewall Configuration

The current Vyatta configuration can be seen on the [firewall environment configuration](./firewall_environments.html)
page. It is automatically updated by the firewall-build-diagrams Jenkins job.
