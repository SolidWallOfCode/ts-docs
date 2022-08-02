.. include:: /common.defs

.. default-domain:: c

==========================
TSHttpOutboundAttempResult
==========================

Synopsis
========

.. code-block:: c

    #include <ts/apidefs.h>

.. c:type:: TSHttpOutboundAttempResult

Action failure to connect outbound.


Enumeration Members
===================

.. c:macro:: TSHttpOutboundAttempResult TS_HTTP_OUTBOUND_CONNECT_FAIL

   Generic failure, no more specific information.

.. c:macro:: TSHttpOutboundAttempResult TS_HTTP_OUTBOUND_CONNECT_TIMEOUT

   There was a timeout while connecting.

.. c:macro:: TSHttpOutboundAttempResult TS_HTTP_OUTBOUND_CONNECT_NO_PATH

   Immediate rejection by target or unable to resolve the target.

.. c:macro:: TSHttpOutboundAttempResult TS_HTTP_OUTBOUND_CONNECT_BAD_PROTO

   Higher level protocol error. Generally a TLS related error.

.. c:macro:: TSHttpOutboundAttempResult TS_HTTP_OUTBOUND_CONNECT_POOL_FAIL

   The outbound connection was taken from the outbound connection pool but failed.


Description
===========

This describes the result of an attempt to connect outbound.
