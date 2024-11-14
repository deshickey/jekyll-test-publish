---
layout: default
title: Armada Docs Guidance
---
The internal documentation is written in Markdown (using the [Kramdown extended syntax](http://kramdown.gettalong.org/syntax.html)).  It is converted into a static web site using [Jekyll](http://jekyllrb.com).

## Runbook Naming Convention
To improve organization and the ability to search for a runbook based on alerts, the following naming convention is recommended.

**Naming Pattern**

_[runbook service area]-[service name]-[component name]: [alert name]_

**runbook service area** = _[REQUIRED]_ Runbook service name

**service name** = _[REQUIRED]_ A name of the service within the runbook service area

**component name** = _[OPTIONAL]_ A name of a component within the service.

Here are some examples for the first segment without the alert name for the _Containers_ runbook service area.

* _containers-kraken-nova_
* _containers-kraken-rabbit_
* _containers-ccsapi-grupdater_
* _containers-ccsapi-redis_
* _containers-registry_
* _containers-build_
* _containers-volume-quota_

**More examples with alerts ....**

* _containers-kraken-mysql: unexpected number of /usr/sbin/mysqld processes_
* _containers-kraken-nova: [SERVER NAME]/check-nova-services_
* _containers-registry: Registry-Bluemix DOWN: CURL(28):OPERATION_TIMEDOUT_

## Runbook Template

layout: default

description: _[Some useful description]_

service: _[match service name from runbook naming convention]_

title: _[Alert ID] Alert Name_

runbook-name: _[Name for the runbook]_

playbooks: _[array of playbooks for automated recovery]_

failure: _[failure message pattern]_

ownership-details:

escalation: _[escalate policy to use]_

owner-link: _[link to slack channel to use]_

corehours: _[timezone]_

owner-notification: _[True|False]_

team-repo-for-ticket: _[Name of the GHE team repo for opening tickets]_

owner: _[squad name]_

owner-approval: _[True | False]_

link: _[links to additional information]_

type: Troubleshooting

**Purpose**

_Describe the purpose and cause of the alert._

**Technical Details**

_Describe the technical details of how the alert checks for the condition being alerted. Include code snippets, link to alert code, etc._

**User Impact**

_Describe the implications of the problem in terms of impact to users, ongoing risks, and impact to the SLA/SLO/SLI’s. Include the severity and urgency of this problem._

**Instructions to Fix**

_Provide step-by-step instructions for fixing the problem. In priority order:_

1. _How to restore the service to normal operations from an end-user perspective (include code)._
2. _How to do root cause analysis._
3. _How to repair the service to a normal configuration, if needed._

**Notes and Special Considerations**

_Include the contacts for escalation when applicable._

## Add a new runbook

Please follow the instructions in this runbook: https://pages.github.ibm.com/alchemy-conductors/documentation-pages/docs/doc_updates/runbook_updates.html


## Generating the web site locally
The web site can be generated locally, which is useful if you want to make a lot of changes, or want to check rendering of more complicated elements like tables. Clone the projects mentioned below into a workspace on a local server from Project Alchemy in git.

### Build and host the site

~~~
sudo ./host-locally-container
~~~

This runs a docker container that hosts the site on port 4000. It should be accessible from local or remote browsers.

The docker container docker image is loaded from registry `alchemyregistry.hursley.ibm.com`. The jenkins job [alchemy-jekyll-build](https://alchemy-conductors-jenkins.swg-devops.com/view/Conductors/job/Conductors/job/Conductors-Infrastructure/view/documentation-pages/job/alchemy-jekyll-build/) can be used to rebuild if necessary.

`alchemyregistry.hursley.ibm.com` is an insecure Docker registry. If you get an error like:

~~~
docker: Error response from daemon: Get https://alchemyregistry.hursley.ibm.com:5000/v1/_ping: http: server gave HTTP response to HTTPS client.
~~~

you will need to edit or create the Docker `daemon.json` to include `alchemyregistry.hursley.ibm.com:5000` in the `insecure-registries` list.
See [Test an insecure registry](https://docs.docker.com/registry/insecure/) for details.

### Alternatively

If you aren't set up to run containers locally, or you just don't want to, then the following script will host the website at **0.0.0.0:4000** without using a container.

~~~
sudo bash host_locally.sh
~~~

Use `nohup` and `&` if you want it to run in the background. _Note_: This requires ruby >= 2.0.

#### Ubuntu 14.04 caveat

Ubuntu 14.04 supports ruby 1.3.9 and `host_locally.sh` requires ruby >= 2.0. Follow these steps to update ruby to latest stable version.

Install prerequisites:

* sudo apt-get install nodejs

Install ruby from source:

* wget -O ruby-install-0.5.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.5.0.tar.gz
* tar -xzvf ruby-install-0.5.0.tar.gz
* cd ruby-install-0.5.0/
* sudo make install
* sudo ruby-install --system ruby

Update system ruby version:

* wget -O chruby-0.3.9.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz
* tar -xzvf chruby-0.3.9.tar.gz
* cd chruby-0.3.9/
* sudo make install

Install gems required by `host_locally.sh`:

* sudo gem install jekyll
* sudo gem install bundler
* sudo bundler install

### Windows Users Alternative
If you aren't set up to run containers locally, or you just don't want to, then you can run Jekyll directly.  
The tutorial at, [http://jekyll-windows.juthilo.com/](http://jekyll-windows.juthilo.com/), is documented below.  

#### Get Ruby for Windows
Download and Install Ruby: [http://rubyinstaller.org/downloads/](http://rubyinstaller.org/downloads/)  
- Make sure to select the check-box _Add Ruby executables to your PATH_ when installing

#### Install the Ruby DevKit
1. Download the devkit from [http://rubyinstaller.org/downloads/](http://rubyinstaller.org/downloads/).  
	__Note__: It must match the Ruby installation's architecture.  
	I.E. If your Ruby installation is 32-bit, then you must select the 32-bit devkit.
2. Extract the contents to somewhere such as c:\rubyDevKit
3. Open a terminal to that directory and type:  

		ruby dk.rb init
4. Next type:  

		ruby dk.rb install

#### Install Jekyll from gems
Jekyll can now be installed via its gem package:  

		gem install jekyll

#### Serve the Runbook code with Jekyll
1. Navigate to the root directory that you cloned Runbook into and type:  

		jekyll serve
2. You should now be able to visit the Runbook page in your browser at http://127.0.0.1:4000.

#### Serving from your computer to other IBMers
If you are wanting to show your modifications to a colleague, you can host locally at your internal IBM IP.  
Then all you need to do is to send the IBMer to your local version.

1. Find your internal IP address, it should start with a 9.
2. Serve your runbook with the following:

		jekyll serve -H <ip-address>
3. Then point any IBMers to http://\<ip-address\>:4000
