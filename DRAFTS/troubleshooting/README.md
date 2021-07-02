## the monitoring/troubleshooting spectrum
### preplanned telemetry vs hands on system 


Before I started working as a software engineer I worked on F-16s. 
Specifically I worked on the F-16 electrical and environmental systems (E&E).

I am going to describe a troubleshooting session I had on the F-16 and in parallel I'll describe 

I used to work for a consultancy (as a software engineer) and I would get dispatched to diagnose and troubleshoot problems with multi-tier architecture systems.

Before I would begin diagnosing problems on a client's software system I would let them know I was going to need access to root (or sudo) access on each of the virtual machines (VM) (yes these were VMs not containers) in the system.
I am pretty sure that if someone within my client's company had asked for root access to each of the VMs she would have been *not* been granted that level of access.

NUMBER 1) diffusion of responsibility: my clients had application support engineers and developers, DBAs, system administrators, and middleware administrators but there was no affordance for single person to trace behavior/misbehavior in the application all the way down to the hardware.

Since my consultancy was getting paid by the hour (not cheap hours either) our clients were motived enough to see that I got the access that I requested.


i think F-16 monitoring should go before troubleshooting...


TODO quick background on ECS.?

### troubleshooting -- preplanned telemetry

When there is a problem with an environmental system on the F-16 the maintenance team goes to the tool crib and checks out an environmental control system (ECS) tester.
It is a big box with a bunch of rubber hoses.
The box has pressure gauges and some electronics for talking to the ECS computer on board the jet.
To use it, you open panels on the side of the jet to expose pressure testing ports on the jet's bleed air ducts.
Then you attach all the hoses; one end to the rest ports and the other end to the big box.
Finally you attach some electrical cables from the big box to the ECS computer on the jet (so the tester can monitor (or alter) the ECS computer's view of the state of the whole ECS).

Then you start the jet, or just the ECS, and troubleshooting, by the book, consists of following a troubleshooting decision tree like this:
```
Is test port #5 between 23 and 29 PSI?
  If below, Is test port #2 between 70 and 90 PSI?
    Then "Replace High Stage Valve"
```


The decision tree does work most of the time.

Let's call the ECS tester with the pressure test ports on the jet a system of "preplanned telemetry."


## troubleshooting -- hands on system

What happens if the preplanned telemetry and the decision tree don't isolate the problem?
That's when you need "hands on system" troubleshooting.

That is, you need to be able to walk right up to the jet (with your knowledge of system operation) and do things like:
- open panels to expose electro-mechanical relays and use a multimeter to test voltage at their inputs
- put your hand on valves to see if you feel them actuate at the appropriate time as the jet engine throttles up and down
- open panels and visually inspect wires, wire connectors, ducts, and flanged duct connectors
- disconnect components in the system to see if system operation is altered in the way you expect
- use electrical wire breakout boxes so you can measure the voltage and current moving through the system at that point


## monitoring -- preplanned telemetry

Ok, now let's look at software...

In my experience, that same continuum (from "preplanned telemetry" to "hands on system") applies to software monitoring and troubleshooting.

You may have heard of some of the "preplanned telemetry" monitoring systems:
- New Relic
- Datadog
- Nagios
- Prometheus

I bet they have labels on the box like "all in one" "everything you need" "one stop shop."

They've got metrics over time and they can show them on a graph (and maybe even add a dashed "red line" to the graph).


Maybe some of you are thinking "wait, monitoring and troubleshooting aren't the same so they require different approaches."
NUMBER 2) In my experience, IT/Infrastructure policies don't differentiate between monitoring and troubleshooting.

You are monitoring when things are basically working as you expect but you are on watch for deviations from normal/optimal.
In the F-16 the pilot has a master caution light which gets latched by dozens of system caution and warning lights.

You transition from monitoring to troubleshooting when you something is not working as you expect.
In the F-16 the pilot doesn't have many troubleshooting tools at her disposal.
The jet's systems mostly have to keep things together until the jet is back on the ground and over to the maintenance team.
Once the jet is on the ground there is a clear transition from monitoring to troubleshooting as the maintenance team takes over.

But in software I rarely see a corresponding transition.
I would expect a tool/technique and access transition to take place but it does not.
In the F-16, the lack of transition would be like watching the maintenance team get in the cockpit, look at the system caution and warning lights, and look at the few dozen mechanical gauges in an attempt to diagnose the problem with the pilot's monitoring tools.
One step further would be the ECS tester...
<!-- But I don't often see a significantly different set of tools and technique --> 

When I was a consultant I would get called in when one of our clients had been in the troubleshooting phase for longer than they cared to be.
And it never failed that they were using mostly monitoring tools/techniques to do their troubleshooting.
It was also the case that most of the time they didn't have someone available with enough knowledge of normal system operation, system configuration, and general [systems programming]() chops.

So my job was to:
1) bring enough knowledge of normal system operation (or learn quickly) 
2) bring awareness of all the ways to configure the system (or learn quickly) a.k.a know which knobs we are able to turn
3) sound the alarm and attempt to persuade people that we need to transition from monitoring tools/techniques and access to troubleshooting tools/techniques and access.
4) apply troubleshooting tools/techniques to operating systems, runtimes (e.g. JVMs), and applications a.k.a be a [systems programmer]().

I enjoy (1) and (2) and I really enjoy (4).
<!-- (3) is a reason I needed to be paid. -->
Doing (3) isn't fun.
I do (1), (2), and (4) in my spare time sometimes (which is partially why I am good at it).

Why is (3) not fun?
Maybe because I can't bring to bear my full creative/exploratory power to the task. 
To to (3) you have to talk to people, who refer you to other people, who refer you to other people...
Eventually you are talking to a gatekeeper (which can take days to get to this point).
In IT/Infrastructure, gatekeepers mostly keep the gate closed.
  You see why people think gates need to be closed ... Equifax, etc.
  But I suspect that if you look at the sources of breeches it isn't because ...

Those closed gates were set up while thinking about the ideal state.
So you are unable to get elevated access to go up and put your hands on the jet.


In an ideal state you are just monitoring and the gates are closed.
When the gates are closed you have to try to fix an unideal state using monitoring tools.



In order to do "hands on system" troubleshooting on the F-16's E&E systems you do have to have some electro-mechanical knowledge, and understanding of system operation, and, ideally, and engineering spirit.

That engineering spirit allows you to work backwards from a misbehaving pneumatically actuated but electrically controlled value to trace all pneumatic and electrical dependences without the book telling you where to look.

The same applies to software.
The engineering spirit allows you to form temporary hypotheses and follow your hunches without the book telling you what metric and/or graph to look at.

And when I am doing anything with software I don't think about whether I am monitoring or troubleshooting.
So I expect to intermix monitoring flavored tools with troubleshooting flavored tools.
When I need to watch CPU utilization (while focusing on the number of context switches) I might run: 

`vmstat 1 | awk '/^[ ]*[0-9]/ {for (i=1;i<NF;i++){if (i==12) printf("\033[1m%s \033[0m",$i) ; else printf(" %s ",$i)} printf("\n")} !/^[ ]*[0-9]/'`.

TODO get screenie or use bold tags



When I need to watch a network interface (specifically how packet routing policies are affecting traffic) I might run:

`watch -d 'sudo iptables -v -L INPUT | head -1'`

```
Every 2.0s: sudo iptables -v -L INPUT | head -1                                                        parens: Sun Jun 27 11:21:38 2021

Chain INPUT (policy ACCEPT 532K packets, 1620M bytes)
```


When I need to see which configuration file is being read by a process I might watch the OS [system calls]() for that process like:

`sudo strace -f -p 17489`

```
...
[pid 18222] openat(AT_FDCWD, "/usr/lib/locale/locale-archive", O_RDONLY|O_CLOEXEC) = 3
[pid 18222] fstat(3, {st_mode=S_IFREG|0644, st_size=5698896, ...}) = 0
[pid 18222] mmap(NULL, 5698896, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7f60f9615000
...
```


I have *never* come across a deployed monitoring service that let's me see that kind of granular "hands on system" derived information.
Also I don't often come across engineers that know how to inspect the whole software stack with tools and techniques like that.
The clue that unravels the whole mystery isn't always one a "preplanned telemetry" system will reveal.


Some gatekeepers in IT/Infrastructure do appreciate the difference between monitoring and troubleshooting.
Some that do appreciate the difference just find it too inconvenient to accommodate "hands on system" troubleshooting so they punt -- hoping that life will find a way with the "preplanned telemetry".


And life does _eventually_ find a way.
Maybe an expensive contractor like me gets hired to request elevated access and diagnoses the problem.
Maybe the engineers do some off-the-record [shell forwarding](https://stuffjasondoes.com/2018/07/18/bind-shells-and-reverse-shells-with-netcat/) so they can run the commands they need to run to diagnose the problem.
Maybe the engineers spend an exorbitant amount of time replicating the problem in an environment where they do have elevated access to run the [commands they need to run](TODO footnote).
Maybe the application owners just get IT to throw more hardware at the problem and it helps a little.
I've seen and/or done all of these several times each.

But most often I think something like this happens:
The application owners struggle to diagnose problems for months or years.
They (and their engineers) find some workarounds that help like sleeping for 20 minutes between batch jobs or writing an additional service to find and kill inexplicably stale jobs.
Even with the workarounds the disappointment remains.
The commercial application doesn't feel as slick as the vendor advertised or the internally developed application doesn't deliver what it promised.
The commercial application vendor says the new version will address the problems.
The team doing the internally developed application says a refactor/rewrite or a responsibility smaller in scope will address or remove the problems.
Or maybe they both point at another system within the enterprise that needs to pick up the slack or prevent the slack.
Eventually a boy dinosaur appears amidst the girl dinosaurs and later you are with a different company.


foot note: I talk about "running commands they (engineers) need to run" but it isn't always clear what handful of commands you need to run.
If it was I would just tell IT/Infrastructure to run these commands and send me the results.
Instead, it takes some time (sometimes days) with the system -- checking file contents, tuning thread counts, watching some super granular metric, etc.



http://www.brendangregg.com/Perf/linux_observability_tools.png
