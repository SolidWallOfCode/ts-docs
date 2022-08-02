.. default-domain:: c

=============================
TSHttpOutboundAttemptCountGet
=============================

Get the number of attempts to connect outbound.

Synopsis
========

.. code-block:: c

    #include <ts/ts.h>

.. function:: int TSHttpOutboundAttemptCountGet(TSHttpTxn txnp)

Description
===========

Retrieve the number of times an outbound connection attempt was made for this transaction.


Return values
=============

The number of outbound connection attempts.

See also
========

:ref:`TSHttpOutboundAttemptImmediateCountGet`
