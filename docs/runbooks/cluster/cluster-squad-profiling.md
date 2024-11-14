---
layout: default
description: Armada cluster - How to profile using pprof
service: armada
runbook-name: "Armada cluster - How to profile using pprof."
link: /cluster/cluster-squad-profiling.html
type: Informational
parent: Armada Cluster
grand_parent: Armada Runbooks
---

Informational
{: .label }

## Overview

This runbook shows how to collect profiling information from an armada-cluster process using the pprof profiler supplied as part of the Go language.

First you will need to carry out some setup on your machine:

* [Required setup](#required-setup)

Then there are two ways you can extract profile information from armada-cluster:

* [By parsing profile data from a file](#parse-profile-data-from-a-file)
* [By attaching to a running process](#attach-to-running-process)

You may also want to collect profiling information on some experimental proof-of-concept code:

* [Enabling profiling in experimental code](#enabling-profiling-in-experimental-code)

Finally there are some useful regular expressions and commands to use within pprof:

* [Regular expression examples](#regular-expression-examples)
* [Useful pprof commands](#useful-pprof-commands)

## Detailed Information

### Required setup

1. You will most likely need to rebuild the armada-cluster executable in your local workspace. The executable built by the standard makefile is for linux. 

   If you are not running linux (e.g. Mac) you will need to rebuild it for your platform using the following command in the root directory of your local armada-cluster repo:

   ~~~~~
   go build
   ~~~~~

2. (Optional) In order to generate some of the graphs output by pprof you will need to install graphviz. 

   You can do this via homebrew as follows:
   ~~~~~
   brew install graphviz
   ~~~~~

### Parse profile data from a file

This process covers the writing of profiling data to file directly by an armada-cluster process. It requires the reading of parameters at process startup to specify the filenames and trigger the profiling. This means it is not suitable for using against an already running process that you wishto profile.

1. Start armada-cluster specifying the files that cpu and memory profile data will be output to:

   ~~~~~
   armada-cluster -cpuprofile=armada-cluster.cpu -memprofile=armada-cluster.mem
   ~~~~~

2. Run the workload you wish to profile through your running armada-cluster instance. The more iterations the better.

3. Stop the armada-cluster instance. You should now have a cpu and memory file in the same directory e.g.

   ~~~~~
   > ll armada-cluster.*
   -rw-r--r--  1 garethb  staff     14856 30 Oct 15:38 armada-cluster.cpu
   -rw-r--r--  1 garethb  staff     14827 30 Oct 15:38 armada-cluster.mem
   ~~~~~

4. Analyze the contents of each file using pprof

   ~~~~~
   go tool pprof armada-cluster.cpu
   ~~~~~

   The data you will analyze in pprof is dependent on which file you specify, cpu or memory.

### Attach to running process

This process covers connecting to a running armada-cluster instance in order to collect profiling data over a period of time.

1. Determine the IP address of the machine/pod the armada-cluster process is running on

2. Determine the port the armada-cluster process is listening on (default 6970)

3. Run pprof to colect profile information from the running service

   ~~~~~
   go tool pprof http://127.0.0.1:6970/debug/pprof/profile?seconds=300
   ~~~~~

   This will collect data for the period defined by the seconds parameter (300s here, 30s by default) and then provide the same CLI for you to enter commmands as the flat file method.

### Enabling profiling in experimental code

This process covers how to enable profiling within a piece of experimental/development code that you wish to profile before including in the product.

1. To enable collection of CPU profiling information to a file passed as a parameter wrap the code to be profiled with the following statements:

   ~~~~~
   cpuprofile := flag.String("cpuprofile", "", "write cpu profile to file")
   flag.Parse()

   if *cpuprofile != "" {
       f, err := os.Create(*cpuprofile)
       if err != nil {
           log.Fatal("Could not create CPU profile: ", err)
       }
       pprof.StartCPUProfile(f)
       log.Println("CPU profiling started")
   }

   <code to be profiled goes here>

   if *cpuprofile != "" {
      pprof.StopCPUProfile()
      log.Println("CPU profiling complete")
   }
   ~~~~~

2. To enable collection of memory dump information to a file passed as a parameter add the following calls after your test code has run:

   ~~~~~
   memprofile := flag.String("memprofile", "", "write memory profile to file")
   flag.Parse()

   <code to be profiled goes here>

   if *memprofile != "" {
      log.Println("MEMORY profiling started")
      f, err := os.Create(*memprofile)
      if err != nil {
          log.Fatal("Could not create MEMORY profile: ", err)
      }
      runtime.GC() // get up-to-date statistics
      if err := pprof.WriteHeapProfile(f); err != nil {
         log.Fatal("Could not write MEMORY profile: ", err)
      }
      f.Close()
      log.Println("MEMORY profiling complete")
   }
   ~~~~~

### Regular expression examples

In order to restrict output pprof accepts regular expressions to define paths that match your required subset. 

* Match a specific method:

  ~~~~~
  github\.ibm\.com\/alchemy-containers\/armada-cluster\/cluster\.performWorkerAction
  ~~~~~

* Match a specific set of sub-directories under a path. This can be useful for filtering out the vendor directory:

  ~~~~~
  github\.ibm\.com\/alchemy-containers\/armada-cluster\/(cluster|iaas).*
  ~~~~~

### Useful pprof commands

* See where time is spent in a method:

  This command will output the source for the method with the lines where large amounts of cpu/memory are used marked inline.

  ~~~~~
  list <method-regexp>
  ~~~~~

  example output:

  ~~~~~
  (pprof) list github\.ibm\.com\/alchemy-containers\/armada-cluster\/cluster\.performWorkerAction
  Total: 3.30s
  ROUTINE ======================== github.ibm.com/alchemy-containers/armada-cluster/cluster.performWorkerAction in /go/src/github.ibm.com/alchemy-containers/armada-cluster/cluster/workers_util.go
         0      140ms (flat, cum)  4.24% of Total
         .          .     75:	// Retrieve interesting pre-action state
         .          .     76:	preCluster := model.Cluster{
         .          .     77:		Datacenter: data.Get(),
         .          .     78:		IsPaid:     data.Get(),
         .          .     79:	}
         .       10ms     80:	if err := task.Store.Get(task.Context, nil, &preCluster); err != nil {
         .          .     81:		logger.Error("Failed to read cluster state", provider.ZapError(err))
         .          .     82:		return
         .          .     83:	}
  ~~~~~

  You can also view this information in a browser using the weblist command:

  ~~~~~
  weblist <method-regexp>
  ~~~~~

* Look at call stacks for a method:

  This command will output the call stacks for methods matching the supplied regex.

  ~~~~~
  peek <method-regexp>
  ~~~~~

  example output:

  ~~~~~
  (pprof) peek github\.ibm\.com\/alchemy-containers\/armada-cluster\/cluster\.performWorkerAction
  Showing nodes accounting for 3.30s, 100% of 3.30s total
  --------------------------------------+-------------
  flat flat% sum% cum cum% calls calls% + context 	 	 
  --------------------------------------+-------------
                           0.14s  100%  | github.ibm.com/alchemy-containers/armada-cluster/cluster.bindRuleEngineManagerRules.func2 /go/src/github.ibm.com/alchemy-containers/armada-cluster/cluster/rules.go
  0    0%    0%  0.14s 4.24%            | github.ibm.com/alchemy-containers/armada-cluster/cluster.performWorkerAction /go/src/github.ibm.com/alchemy-containers/armada-cluster/cluster/workers_util.go
                           0.09s 64.29% | github.ibm.com/alchemy-containers/armada-cluster/cluster.probeWorker /go/src/github.ibm.com/alchemy-containers/armada-cluster/cluster/workers_probe.go
                           0.04s 28.57% | github.ibm.com/alchemy-containers/armada-cluster/vendor/github.ibm.com/alchemy-containers/armada-data/data.(*ruleStore).Set /go/src/github.ibm.com/alchemy-containers/armada-cluster/vendor/github.ibm.com/alchemy-containers/armada-data/data/config.go
                           0.01s  7.14% | github.ibm.com/alchemy-containers/armada-cluster/vendor/github.ibm.com/alchemy-containers/armada-data/data.(*ruleStore).Get /go/src/github.ibm.com/alchemy-containers/armada-cluster/vendor/github.ibm.com/alchemy-containers/armada-data/data/config.go
  ----------------------------------------------------------+-------------
  ~~~~~

## Useful links

* [pprof go doc](https://golang.org/pkg/net/http/pprof/)
* [Profiling Go programs](https://blog.golang.org/profiling-go-programs)
* [Profiling and optimising Go web applications](http://artem.krylysov.com/blog/2017/03/13/profiling-and-optimizing-go-web-applications/)
