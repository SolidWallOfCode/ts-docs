.. |SM| replace:: :code:`HttpSM`

Layer 7 Working Group
*********************

The Layer 7 Routing Working Group is a community effort to improve the ability of Traffic Server to
do routing based on layer 7 (HTTP) data. This is intended to subsume the various routing such as
parent selection and plugins like CARP in to a single mechanism.

Terminology
===========

This work is based on splitting functionality out of the current HTTP state machine in to other
objects. The major ones are

Router
   Select the upstream destination for the request. This is a singleton.

Strategy
   A particular way of selecting an upstream destination. There can be multiple strategies, each
   identified by a name.

Connector
   Management of outbound connections. This handles both pooling of outbound connections and
   connecting to upstreams.

Interaction
===========

To proxy a request the |SM| needs a stream to an appropriate upstream. Currently this
is done via direct connection handling, but this should be changed to be stream / transaction based
as was done for the inbound requests. The |SM| should become isolated from the details of connection
handling. In this design, a new component, the Connector, will be created to handle obtaining transactions from upstreams, subsuming the functionality of the session pool and outbound connection handling.

* The |SM| first selects a strategy.
* The |SM| asks the Router for a transaction based on that strategy and the request.
* The Router selects a specific upstream.
* The Router asks the Connector for a transaction to the upstream.
* The Connector returns either a transaction or an error upon connection failure.
* The Router returns the transaction to the |SM|.
* The |SM| uses the transaction and reports the result back to the Router.

.. figure:: /pix/l7-basic-activity.svg

The Router (and thence the strategy) is responsible for any connection retries. The Connector makes
only one attempt to create a new network connection. If there is an error it gives up and reports
the error to the Router. The |SM| makes only one request to the Router, and gets a valid transaction
or not, and in the latter case reports an error to the user agent. The Router, using the active
strategy, must decide whether to retry and what upstream to use. There is no requirement that a
retry use the same upstream as the previous connection attempt, it is entirely up the Router.

Router, Strategies, Plugins
---------------------------

Ultimately a strategy is a particular way to select an upstream. A strategy is implemented by a
strategy plugin which reads a configuration file. This pairing creates a strategy. The same plugin
can be used with other configuration files to create other strategies. The Router is a singleton and
is the engine that drives the strategy. As a strategy is implmented by a plugin performs actions
during callbacks, it is the Router that invokes the callbacks. The Router is responsible for loading
the strategy plugins and tracking the mapping between strategy names and instances. The |SM|
specifies a strategy by name to the Router, which "activates" that strategy to select upstreams.

Tracking transactions
---------------------

It is important to the Router to know the result of a transaction in order to track the state of the
upstreams. Rather than complex criteria the rule is the |SM| always reports the result to the Router. If the active strategy doesn't care the report can be ignored.

Open Issues
===========

The Connector must provide some level of detail on any connection failure. This would include, but not be limited to

*  Connection timeout.
*  Unreachable destination.
*  Unresolvable destination.

Outbound session hooks will be necessary. This is a first pass at those hooks.

.. figure:: /pix/outbound-ssn-hooks.svg
   :align: center

Appendix
========

