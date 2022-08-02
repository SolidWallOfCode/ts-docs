.. default-domain:: c

=======================
TSHttpSsnRetryActionSet
=======================

Set the outbound connection retry action.

Synopsis
========

.. code-block:: c

    #include <ts/ts.h>

.. function:: TSReturnCode TSHttpSsnRetryActionSet(TSHttpTxn txnp, TSHttpOutboundRetryAction action)

Description
===========

Set the retry action for transaction :arg:`txnp`.

Return values
=============

:data:`TS_SUCCESS` on success, or :data:`TS_ERROR` on failure.

See also
========

:ref:`TSHttpSsnRetryActionGet`
