.. default-domain:: c

=======================
TSHttpOutboundTargetSet
=======================

Set the outbound connection target.

Synopsis
========

.. code-block:: c

    #include <ts/ts.h>

.. function:: TSReturnCode TSHttpOutboundTargetSet(TSHttpTxn txnp, char const * name, int len)

Description
===========

Set the target for for the transaction :arg:`txnp`. This is initially set from the request but can
be explicitly overridden using this function. If the name can be parsed as an IP address then that
address is used and no other resolution is done.

Return values
=============

:data:`TS_SUCCESS` on success, or :data:`TS_ERROR` on failure.

See also
========

:ref:`TSHttpOutboundTargetGet`
