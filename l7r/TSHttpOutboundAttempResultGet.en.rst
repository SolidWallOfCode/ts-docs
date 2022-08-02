.. default-domain:: c

=============================
TSHttpOutboundAttempResultGet
=============================

Result of an outbound connection attempt.

Synopsis
========

.. code-block:: c

    #include <ts/ts.h>

.. function:: TSHttpOutboundAttemptResult TSHttpOutboundAttempResultGet(TSHttpTxn txnp, TSHttpOutboundRetryAction action)

Description
===========

Set the retry action for transaction :arg:`txnp`.

Return values
=============

:data:`TS_SUCCESS` on success, or :data:`TS_ERROR` on failure.

See also
========

:ref:`TSHttpSsnRetryActionGet`
