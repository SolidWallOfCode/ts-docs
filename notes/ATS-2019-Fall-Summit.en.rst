ATS Summit Fall 2019
********************

The summit was held in Building B at Yahoo! on 8 Oct to 10 Oct 2019.

These notes are my personal views of the summit, things I found of interest that were not obvious
in the slides. I have tried to not duplicate too much slide information.

New Committers
==============
Aaron Canary, Peter Chou.

Introduction
============

*  Need more cross company PR reviews. This will require other companies to spend time on this,
   the current cabal can't make this happen.

*  Switched over to Slack. Anyone in the channel can invite others, just need to find anyone
   already there.

*  Decisions from last summit

   *  Move to YAML for configurations.

   *  Remove LuaJIT from the core.

*  ATS 9

   *  HTTP/3 QUIC - alpha. Based on draft-20.

   *  Minimum OpenSSL is now 1.0.2.

   *  Tentatively drop support for Solaris - no support, no way to even build it.

   *  Blockers for ATS 9 release should be added to issue 5932.

Long discussion about live testing and configuration validation on production systems. Apple uses an
internal tool called "CDN Checker" to do this. This is embedded tightly with Voluspa and wouldn't be
easily separated. There were requests for more common tools to do this kind of thing. I think this
is a perfect application for Http Replay, but despite all the talks about it at summits no one else
seems to be aware of it. I've also presented on using AuTest for live testing, but that was
apparently forgotten.

For ATS 10 and onwards, we want to move to having the release notes in the documentation. PRs that
make non-compatible changes should also contain updates to the release notes.

Some discussion about Layer 7 Routing and A/B testing. Sudheer mentioned wanting to do ramping load
balancing where load is gradually shifted between sets of upstreams.

Outbound Refactoring
====================

Work is on feature branch "h1-outbound". Discussion about how much of the renaming should be on
master and ATS 9.

Kit asked about better manipulation of HTTP/2 with regard to gRPC proxying and handling trailing
headers.

Sudheer mentioned there is a need to be able to do session level property setting for outbound
sessions, which currently is done in a poor way by using transaction based hooks. A cleaner way is
needed for this. It seems this can mostly be done if there are outbound session hooks.

HTTP/3 QUIC
===========

QUIC is a generic transport layer, and HTTP/3 is really HTTP over QUIC.

Experimental support is available in ATS 9. This requires a special version of OpenSSL. There is
still a feature branch, `quic-latest`. This is intended to be merged to master after every
successful InterOp.

*  QUIC : draft-20
*  HTTP/3 : draft-20
*  QUACK : draft-03

There are a number of missing features and not suitable for production use. It is a a good base for
people interested in working on HTTP/3. InterOP tests are done using an internal client
`traffic_quic` which is based on the ATS QUIC libraries.

Should also take care to not break BoringSLL support when working on OpenSSL code.

Unified Routing
===============

Current routing is basically "remap.config" and a few plugins such as "regex_remap". Mostly host or
path based. Want "ramping" or "A/B testing" to have partial routing between distinct groups of
upstreams.

Very similar to TxnBox - have a set of routing criteria ("features") and then apply actions
("directives") based on the criteria.

Key ordering is predetermined by the code. Longest / most specific rules are matched first.

Rules can be conditional based on internal tracking of upstream results. Rules can be linked to
"cascade" selection.

Can be configured via an external API. Rules can be created and listed. Rules have an index and a
hash key which is computed from properties of the key.

Serving Wikipedia with ATS
==========================

Spent 12 months work on using ATS for Wikipedia. Was served by Varnish, now a mix of ATS and
Varnish. This means all of the Wikipedia foundation (more than just Wikipedia).

Run their own CDN for general autonomy. All of the software and tools are open source and available
on github.

Old split was two proxy instances, one ram only and the other disk only. Replacing the disk only
proxies with ATS. Will be continuing with conversions of other proxies to ATS. Looks like the
Varnish killer was the lack of TLS support.

Found several issues: #4466, #4635, #5179, #5787.

Using ATS 8.0.5.

Using Lua plugin

*  path normalization, RFC 3986

*  Tweak headers for MediaWiki processing.

*  Cache control.

Quite a bit of work on determining the logic for whether a response is cached, using system tap
to track the decisions. Having problems with dealing with requests that are non cacheable based
on server response, and not determinable at request time. Varnish can make a note of the
non-cacheablility. I think this is distinct from negative caching.

Using named pipe for logging. Pondered writing to Kafka, not done yet.

Note all of the code and even performance graphs are publically available. Lots of interesting
Puppet scripts.

Nexthop selection strategies
============================

This is primarily a reworking of parent selection. Checks for remap, and if not remapped uses
parent selection.

Single config file that contains multiple strategies. Updated "remap.config" parsing to enable a
"strategy" option that specifies which strategy from the configuration should be used.
Synchronization between the two files is done by always reloading the strategy config file when the
"remap.config" is reloaded. Configuration files are linked via a special `#include` mechanism.

Planning on having plugins at some point.

AMC Tech Corner
===============

Still hard push for not supporting old and new configuration instances.

Cache config YAML accepted, no real objects.

For down server handling, in the "service not available" case make sure cache "serve while stale"
works.

No comments on working on Cache Tool outside of ATS repo.

For disabling ram cache - per volume is OK. JvD wants to look at remap level of preventing specific
objects from being promoted to ram cache.

Reloadable Remap Plugins
========================

Currently on master. This works for remap plugins. May be extended to L7R plugins.

Mostly a demo, showing how remap plugins get notified. The big change is that the dynamic libraries
get unloaded and reloaded. Continuations created by the remap plugins is tracked and the library
kept loaded until all the Continuations are destroyed.

Http Replay
===========

Using for performance and testing.

WebAssembly
===========

Use for TS plugins.

Reloading - can reload libraries, but that's not the core problem, which is dangling Continuations.

Trying to make an ABI that makes it possible to use the same plugins on different proxies.

Multiple plugins done by linking them into a single VM. A framework does the function call routing.

VMs have API to get functions (calls to VM from proxy) and callback registration (calls from VM to
proxy), plus memory copy (in and out).

Not clear on the state model. There are context objects, perhaps those are the equivalent of Lua
states or "light weight threads" sort of thing. That is, "context switching" for different
transactions is done by selecting a corresopnding context object. (Appears to be correct). The
internal context has both state data and the methods / functions available in the context. The
functions are represented as methods on an object and extracted during compilation.

In essence, to get other language support, we would need a "WASM API" kind of like the C++ API
which wraps the C plugin API. This API is a concrete implementation of an abstract "proxy VM"
defined by WASM. Once this works, then WASM takes care of interfacing from other languages to
the concrete proxy VM.

Analytics with ATS Logs
=======================

Primary goal was to figure out how well the CDN was serving. Wanted to distinguish between regions
and / or networks to be able to track down issues. Ended up using ATS logs along with other logs
and beacon measurements.

Generates reports via Hadoop cluster, then uses Druid / Pivot to view the reports and graphs. Doing
this with the network team enables tracking down real network problems. Has resulted in many
actual fixes for problems.

Want to do real time streaming in the future.

ATS Ingress Controller
======================

(Originally listed as "ATS and Kubernetes")

Uses "Ingress Controller" process in a pod to control ATS, which in turns proxies access to the
services in other pods. Seems like another good place for a better RPC for updating configuration
and retrieving status information.

Ingress Controller dynamically adjusts the proxy state to handle changes in the service mesh. New
instances, new services, services or instances removed, etc.

Need to implement more control of routing.

Network and HTTP/2 Performance Issues
=====================================

Initially some throttling problems, have fixes for this in HostDB and accept logic.

An issue is transaction processing happens on the `ET_NET` threads and if HTTP/2 processing is
expensive, this can cause cross talk latency.

In general, a number of minor issues that add up. For instance, inefficient memory handling in
HPACK using :code:`HdrHeap`.

Discussion of issue with accepting connections, dedicated threads vs. `ET_NET` acceptance. Lots
of discussion, probably need to do something in this area.

There is other work going with regard to HTTP/2, mostly by Susan and Masaori.

TLS 1.3 0-RTT
=============

Combine initial client data with handshake. This requires quite a lot of changes in ATS.

Biggest problem was figuring out what the OpenSSL options for early data are and how they work.

Early data is put in to a specific sidecar buffer.

Need some specific replay protections as the built in ones don't work in our use case.

Part of the replay protection is limiting early requests to specific methods. Request for being able
to restrict methods on a per domain basis, or look at being able to do this in "remap.config".

Low Latency HLS
===============

Changes to the basic HLS spec to enable much lower latency for live video. Goal is to compete in
latency with standard satellite broadcasts. The biggest problems seemed to me to be the 6 second
chunk, which implies a minimum 6 second delay. The official list is

*  Shrink the segment size from 6 seconds to much smaller.
*  Do long polling from user agent to upstream to get the next update of the index file.
*  User agent can ask for a push of the next segment when fetching the index file.
*  Delta for index files.
*  Index files can specify the alternate rate files to make adaptive switching faster.

`Official Talk <https://developer.apple.com/videos/play/wwdc2019/502/>`__.

Delain Concert
==============

AWESOME!

Lightning Talks
===============

Netlify
-------

Provides hosting services to developers. Host over 174K distinct domains. L7 routing is done by
mapping everything to service on a localhost address / port.

Demonstrated how basically a random user can create a github repository which can then be linked and
distributed by Netlify.

Can set up alternate sites based on pull requuests to the main website branch.

Supports redirects (really remap) rules to map paths to other paths. Can have generic redirects that
allow arbitrary URLS to map to a fixed page, but files are exempted therefore the remapping must
be able to detect files. This is done during deployment of the website.

Original remapping service was written in Go, and so not really suitable for a plugin. Working on
converting to plugin.

SystemTap in ATS
----------------

Used system tap to tap into :code:`state_cache_open_read` to detect how many cache write lock
retries have done in order to tune that parameters.

Problem is the taps require intimate knowledge of ATS internals and even specific line numbers. It
is possible to define tap points in the code. These can have arguments as well, which provide data
to the tapper. Man page claims this is assembled to a :code:`NOP` and only data about how to find
the arguments is stored in a side file.

This is similar to `gdb` macros.

Might be reasonable to tweak the :code:`DEBUG` macro to provide tap points. If it's interesting for
debugging by logs, it should be interesting for tapping. Would need to have another argument
for the tap point name. Each tap point is distinguished by a `provider/name` pair which must
be globally unique.

`Example Files <https://github.com/wikimedia/puppet/tree/production/modules/trafficserver/files>`__.

Bryan Call then spoke `gdb` macros for examing data in cores and live in production instances of
`traffic_server`. Supports conditional break and resume. To avoid problems with dropped connections
causing problems you need ::

   handle SIGPIPE nostop
   handle SIGPIPE noprint

Session Logging
---------------

In most cases, there is a lot of transaction logging data that is idnetical across all transactions
for a given sessions. It would be handy if there was as session log and have a key per entry
which can be logged with a transaction.

One issue would be the ability to have IDs that distinguish inbound vs. outbound sessions. This
doesn't seem a large hurdle. All the data needed is already there.

Some of the motivations are

*  Potentially save a lot of log space by not duplicating session level data.

*  Session logs are useful on their own - much network analysis is session based.

*  Overall, we're moving into a state where sessions are becoming more central, particularly
   with regard to hooks and overridable configurations. This is just part of the same issue.

With regard to outbound vs. inbound sessions, there are some synchronization issues with when
data is accessed for transaction level logging.

We should move session based data that needs log caching (e.g. outbound IP addresses) to a separate
structure that's session based.

Leif wanted to have four possible logs

*  Inbound transactions
*  Outbound transactions
*  Inbound sessions
*  Outbound sessions

I'm not convinced of the utility of splitting the transaction logs. Need to talk to our "data
scientists" about it.

Debugging
---------

Leif, Bryan, Emmanuelle, I (and maybe some others) talked about system tap probe points and ATS
debugging. Leif wanted to re-organize the debug namespace. The general consensus was

#  Do a test where all the current calls to :code:`DEBUG` also create a probe point. The name
   can be the file and line number to guarantee uniqueness. Then test this in production to see
   what the performance impact is. If it's undetectable, then we don't have to worry about it.

#  Look at Walt's proposal for improving :code:`DEBUG` tag checking performance. This means
   using :code:`DEBUG` to create local static objects that are globally registered. When the
   debug tag string is updated, update flags in these objects to indicate whether it's active.
   Then the lookup cost is once per setting of the configuration variable, not for every time
   the tag is hit.

#  While working on the previous, come up with a better name space organization for debug tags.
   In particular, we need more "long" names so that debugging can be more focused. For instance
   the "http" tags should be more varied to be more selective about what's logged.

#  In the end, the :code:`DEBUG` should be able to take an optional tag that indicates it should
   also be a probe point.

Although it seems reasonable at the start to make all :code:`DEBUG` calls in to probe points, this
is problematic because it makes so many probe points as to render them unusable. Instead we'll
have to be a bit more selective.

