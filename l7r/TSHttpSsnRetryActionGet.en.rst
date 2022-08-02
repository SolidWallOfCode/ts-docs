.. default-domain:: c

=======================
TSHttpSsnRetryActionGet
=======================

Get the outbound connection retry action.

Synopsis
========

.. code-block:: c

    #include <ts/ts.h>

.. function:: TSHttpOutboundRetryAction TSHttpSsnRetryActionGet(TSHttpTxn txnp)

Description
===========


Return values
=============

The current action for failed outbound connections for the transaction :arg:`txnp`.

See also
========

:ref:`TSHttpSsnRetryActionSet`
