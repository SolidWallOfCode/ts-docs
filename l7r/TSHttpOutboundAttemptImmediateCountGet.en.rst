.. default-domain:: c

======================================
TSHttpOutboundAttemptImmediateCountGet
======================================

Get the number of attempts to connect outbound for the current target.

Synopsis
========

.. code-block:: c

    #include <ts/ts.h>

.. function:: int TSHttpSsnRetryActionSet(TSHttpTxn txnp)

Description
===========

Retrieve the number of times an outbound connection attempt was made for this transaction for the current target.


Return values
=============

The number of outbound connection attempts for the current target.

See also
========

:ref:`TSHttpOutboundAttemptCountGet`
