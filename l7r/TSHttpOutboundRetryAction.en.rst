.. include:: /common.defs

.. default-domain:: c

TSHttpHookID
************

Synopsis
========

.. code-block:: c

    #include <ts/apidefs.h>

.. c:type:: TSHttpOutboundRetryAction

Action failure to connect outbound.


Enumeration Members
===================

.. c:macro:: TSHttpOutboundRetryAction TS_HTTP_OUTBOUND_RETRY_IMMEDIATE

   Retry the same target.

.. c:macro:: TSHttpOutboundRetryAction TS_HTTP_OUTBOUND_RETRY_POOL

   Select an outbound connection from the outbound connection pool.

.. c:macro:: TSHttpOutboundRetryAction TS_HTTP_OUTBOUND_RETRY_OTHER

   Select the outound target again - return the target resolution state.

.. c:macro:: TSHttpOutboundRetryAction TS_HTTP_OUTBOUND_RETRY_FAIL

   Fail the transaction due to outbound connection failure.


Description
===========

This describes what action to take if an outbound connection for an HTTP transaction fails.
