.. default-domain:: c

=======================
TSHttpOutboundTargetGet
=======================

Set the outbound connection retry action.

Synopsis
========

.. code-block:: c

    #include <ts/ts.h>

.. function:: char const * TSHttpOutboundTargetGet(TSHttpTxn txnp, int * len)

Description
===========

Get a view of the outbound target name.

Return values
=============

A pointer to the target name, or :code:`nullptr` if there is no target or an error occurred.
If :arg:`len` is not :code:`nullptr` then it is updated with the length of the target name.
The name is may not be null terminated, it is not a C string.

See also
========

