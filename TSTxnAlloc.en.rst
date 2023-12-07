.. Licensed to the Apache Software Foundation (ASF) under one
   or more contributor license agreements.  See the NOTICE file
   distributed with this work for additional information
   regarding copyright ownership.  The ASF licenses this file
   to you under the Apache License, Version 2.0 (the
   "License"); you may not use this file except in compliance
   with the License.  You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing,
   software distributed under the License is distributed on an
   "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
   KIND, either express or implied.  See the License for the
   specific language governing permissions and limitations
   under the License.

.. include:: ../../../common.defs

.. default-domain:: cpp

TSTxnAlloc
**********

Traffic Server Transaction based memory allocation.

Synopsis
========

.. code-block:: cpp

    #include <ts/ts.h>

.. function:: swoc::MemSpan<void> TSTxnAlloc(TSHttpTxn txn, size_t bytes)
.. function:: swoc::MemSpan<void> TSTxnAllocAligned(TSHttpTxn txn, size_t bytes, size_t align)
.. function:: template < typename T > T * TSTxnAllocInstance();
.. function:: template < typename T > swoc::MemSpan<T> TSTxnAllocArray(size_t count);
.. function:: swoc::TextView TSTxnLocalizeString(TSHttpTxn txn, swoc::TextView s)
.. function:: swoc::TextView TSTxnLocalizeCString(TSHttpTxn txn, char const * s)
.. function:: template < typename F > void TSTxnFinalize(TSHttpTxn txn, F && f)

Description
===========

These functions are used to allocate memory that has the same lifetime as a transaction. This has two differences from
normal allocation which are frequently advantageous for plugins.

*  Allocation is much faster than :code:`malloc` or equivalent.
*  The memory is released at the end of the transaction automatically.

The only function in this group that does not allocate is :func:`TSTxnFinalize`. Instead this provides a functor
which is invoked just before the transaction local memory is released.

:func:`TSTxnAlloc` allocates a block of memory of size :arg:`bytes`.

:func:`TSTxnAllocAligned` allocates a block of memory of size :arg:`bytes` that is aligned at a multiple of :arg:`align`,
which must be a power of 2.

:func:`TSTxnAllocInstance` allocates an instance of a type :code:`T` with the required alignment for :arg:`T`,
calls the default constructor for :code:`T`, and the returns the pointer.

:func:`TSTxnAllocArray` allocates a block of memory of size and alignment to hold :arg:`count` instances of :code:`T`. These
are not initialized / constructed.

:func:`TSTxnLocalizeString` copies the string :arg:`s` to transaction local memory and returns a view of the copied string.

:func:`TSTxnLocalizeCString` copies a C string (nul character terminated) :arg:`s` to transaction local memory and returns a view of the copied string.

:func:`TSTxnFinalize` creates a finalizer for the transaction which are described in :ref:`finalizers`.

Notes
=====

In general this memory should avoid referencing memory outside of transaction local memory. Strings are the archetype
as a string is complete in itself and requires no cleanup beyond deallocation. For variable sized structures it is
possible to use :code:`swoc::IntrusiveDList` to create lists which reside entirely in transaction local memory and
therefore require no addtional cleanup.

.. _finalizers::

Finalizers
----------

If cleanup is unavoidable then a :em:`finalizer` can be used. This is a functor that is invoked just before cleaning
up transaction local memory which is intended to perform addtional cleanup. This imposes several restrictions

*  The finalizer itself must not require any cleanup beyond deallocation. One aspect is the functor instance must
   not contain any non-transaction local allocated memory.
*  The finalizer must only do allocation related cleanup. It must not call any TS plugion API calls. The transaction
   object is likely to be in an unusable state when the finalizer is invoked.

For an example finalizer, suppose the allocation is used to hold a :code:`std::vector<size_t>`. Simply releasing the
memory will leak the vector elements, so the vector must be destructed. This can be handled by a finalizer that looks
like

.. code-block:: cpp

   auto * vecp = TSTxnAllocInstance<std::vector<size_t>>(txn);
   TSTxnFinalizer(txn, [=]() -> void { delete vecp; });

The pointer to the allocated vector is captured by the lambda and when the transaction local memory is released the
vector contents are also released. Be very very careful or (better) avoid entirely capture by reference, as the target of the
reference is likely to be long out of scope when the finalizer is invoked.

See also
========

:manpage:`TSAPI(3ts)`
