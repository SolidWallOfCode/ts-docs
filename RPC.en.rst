.. include:: common.defs

.. highlight:: cpp
.. default-domain:: cpp

.. _rpc:

RPC
*************

Overview
========

To communicate between ``traffic_manager`` and ``traffic_server`` there is an RPC mechanism in
``mgmt/``. This is a simple serialization style RPC which runs over sockets.


Serialization Mechanism
=======================

A RPC message is sent as a ``MgmtMessageHdr`` followed by the serialized data in bytes. 

.. class:: MgmtMarshall

   This is the class used to marshall data objects. It provides functions to marshall and unmarshall data. Each data object is associated with a field. Fields can be:

.. enum:: MGMT_MARSHALL_INT
.. enum:: MGMT_MARSHALL_LONG
.. enum:: MGMT_MARSHALL_STRING
.. enum:: MGMT_MARSHALL_DATA


Marshalling:
++++++++++++

.. function:: ssize_t MgmtMarshall::mgmt_message_marshall(void *buf, size_t remain, const MgmtMarshallType *fields, unsigned count, ...)

   Variable argument wrapper for ``mgmt_message_marshall_v``. Allows for different datatypes to be marshalled together as long as a field is specified for each data object.

.. function:: ssize_t MgmtMarshall::mgmt_message_marshall_v(void *buf, size_t remain, const MgmtMarshallType *fields, unsigned count, va_list ap)

   This function goes through all the data objects and serializes them together into a buffer. Based on the field, the number of bytes is determined and if there is enough space, it is written into the buffer. 

    - MGMT_MARSHALL_INT: 4 bytes.
    - MGMT_MARSHALL_LONG: 8 bytes.
    - MGMT_MARSHALL_STRING: 4 bytes to indicate the string size in bytes, followed by the entire string and NULL terminator. 
    - MGMT_MARSHALL_DATA: 4 bytes to indicate data size in bytes, followed by the entire data object. 

Unmarshalling:
++++++++++++++

.. function:: ssize_t MgmtMarshall::mgmt_message_parse(const void *buf, size_t len, const MgmtMarshallType *fields, unsigned count, ...)

   Variable argument wrapper for ``mgmt_message_parse_v``. 

.. function:: ssize_t MgmtMarshall::mgmt_message_parse_v(const void *buf, size_t len, const MgmtMarshallType *fields, unsigned count, va_list ap)
   
   This function parses all the serialized. Based on the field, the number of bytes to be read is determined and copied into a MgmtMarshallAnyPtr.

    * MGMT_MARSHALL_INT: 4 bytes.
    * MGMT_MARSHALL_LONG: 8 bytes.
    * MGMT_MARSHALL_STRING: Check string is NULL terminated. Read 4 bytes to determine size of string. Copy entire string. 
    * MGMT_MARSHALL_DATA: Read 4 bytes to determine data size in bytes. Copy all bytes of data.  


RPC API for ``traffic_server`` and ``traffic_manager``
======================================================

.. class:: BaseManager 

.. class:: LocalManager : BaseManager

   This class is used by ``traffic_manager`` to communicate with ``traffic_server``

.. function:: void LocalManager::pollMgmtProcessServer()

   This function watches the socket and handles incoming messages from processes. Used in the main event loop of ``traffic_manager``.

.. function:: void LocalManager::sendMgmtMsgToProcesses( ... )

   This function is used by ``traffic_manager`` to process the messages based on msg_id. It then sends the message to ``traffic_server`` over sockets.

.. class:: ProcessManager : BaseManager

   This class is used by ``traffic_server`` to communicate with ``traffic_manager``

.. function:: int ProcessManager::pollLMConnection()

    This function periodically polls the socket to see if there are any messages from the ``LocalManager``. It can accept up to ``MAX_MSGS_IN_A_ROW``, defaulted at 10000. 

.. function:: void ProcessManager::signalManager ( ... )

   This function sends messages to the LocalManager using sockets. Details on how the write is preformed is in the section "Messages over sockets between traffic_manager and traffic_server".

.. rubric:: Notes

1. In the context of the ``ProcessManager``, the ``mgmt_signal_queue`` are signals to be sent from ``traffic_server`` to ``traffic_manager``. The ``mgmt_event_queue`` are events and signals recieved from ``traffic_manager`` to ``traffic_server``. This distinction is important as ``processSignalQueue( ... )`` and ``processEventQueue( ... )`` are preforming different tasks.

#. Both ``pollMgmtProcessServer()`` and ``pollLMConnection()`` actually use ``select()``, not ``poll()`` or ``epoll()``, underneath.


Messages over sockets between ``traffic_manager`` and ``traffic_server``
========================================================================

Read:

1. Read the MgmtMessageHdr:

   a. ``MgmtUtils.cc::mgmt_read_pipe(int fd, char *buf, int bytes_to_read)`` calls,

   #. ``ink_sock.cc::read_socket(int s, char *buffer, int length)`` casts char* buffer to void*, calls, 

   #. ``read(int fd, void *buf, size_t count)`` <- a C system call.

2. Read the content:

   a. data length is given in the header, 

   #. read data_len bytes with the same proceedure as the MgmtMessageHdr.


Write:

1. create a MgmtMessageHdr and populate it with the message information (msg id, raw data, raw data length) then, 

#. append the MgmtMessageHdr with the raw data via memcpy. When it is to be written, 

#. ``MgmtUtils.cc::mgmt_write_pipe(int fd, char *buf, int bytes_to_write)`` calls,

#. ``ink_sock.cc::write_socket(int s, const char *buffer, int length)`` casts buffer to const void* and calls,

#. ``write(int fildes, const void *buf, size_t nbytes)`` <- a C system call.


Runtime Structure ``traffic_ctl`` to ``traffic_server``
=======================================================

Address spaces:

    *traffic_ctl*
    
    *traffic_manager*

    *traffic_server*

traffic_manager opens a socket to recieve commands from traffic_ctl. traffic_manager has a socket connection to traffic_server to relay RPC commands.


Sequence Diagram from ``traffic_ctl`` to ``traffic_server``
===========================================================

For example (command line): "traffic_ctl plugin msg TAG hello" 

1. traffic_ctl via ``TSControlMain.cc::TSLifeCycleMessage ( ... )``

#. traffic_manager recieves this message over handle_lifecycle_message.

Request flow:

    a. ``LocalManager::signalEvent(MGMT_EVENT_LIFECYCLE_MESSAGE ... )``

    #. event enqueued in local linked-list event queue

    #. dequeued via ``LocalManager::processEventSignal()`` and sent using ``LocalManager::sendMgmtMsgToProcesses( ... )``

    #. ``ProcessManager::pollLMConnection()`` periodically polls the socket to see if there is any message from LocalManager

    #. ``ProcessManager::handleMgmtMsgFromLM( ... )`` calls ``BaseManager::signalMgmtEntity`` which enqueues the message recieved 

    #. Events periodically processed in the ``processManagerThread`` using ``processEventQueue( ... )``

    #. ``BaseManager::executeMgmtCallback( ... )`` does a lookup for the callback function ``Main.cc::mgmt_lifecycle_msg_callback( ... )`` corresponding to the msg_id

    #. the ``TS_EVENT_LIFECYCLE_MSG`` hook is invoked within the callback handler 

    #. plugins registered to the event hook will recieve the data sent from ``traffic_ctl`` as a ``TSPluginMsg`` 

Response flow:

    a. ``NetworkMessage::send_mgmt_response( ... )``

    #. marshall respones as data object. 

    #. send serialized data over socket. 
    
.. note::

    Currently a fire and forget model. traffic_manager sends out an asynchoronous signal without any acknowledgement. It then proceeds to send a response itself. 



Management Signals
==================
------------------

.. c:macro:: MGMT_SIGNAL_PID 

.. c:macro:: MGMT_SIGNAL_MACHINE_UP 

.. c:macro:: MGMT_SIGNAL_MACHINE_DOWN 

.. c:macro:: MGMT_SIGNAL_CONFIG_ERROR 

.. c:macro:: MGMT_SIGNAL_SYSTEM_ERROR
 
.. c:macro:: MGMT_SIGNAL_LOG_SPACE_CRISIS

.. c:macro:: MGMT_SIGNAL_CONFIG_FILE_READ 

.. c:macro:: MGMT_SIGNAL_CACHE_ERROR 

.. c:macro:: MGMT_SIGNAL_CACHE_WARNING 

.. c:macro:: MGMT_SIGNAL_LOGGING_ERROR 

.. c:macro:: MGMT_SIGNAL_LOGGING_WARNING

.. c:macro:: MGMT_SIGNAL_PLUGIN_SET_CONFIG 

.. c:macro:: MGMT_SIGNAL_LOG_FILES_ROLLED 

.. c:macro:: MGMT_SIGNAL_LIBRECORDS 

.. c:macro:: MGMT_SIGNAL_HTTP_CONGESTED_SERVER 

.. c:macro:: MGMT_SIGNAL_HTTP_ALLEVIATED_SERVER 

.. c:macro:: MGMT_SIGNAL_CONFIG_FILE_CHILD 

.. c:macro:: MGMT_SIGNAL_SAC_SERVER_DOWN 


Management Events
==================
------------------

.. c:macro:: MGMT_EVENT_SYNC_KEY

.. c:macro:: MGMT_EVENT_SHUTDOWN 

.. c:macro:: MGMT_EVENT_RESTART 

.. c:macro:: MGMT_EVENT_BOUNCE 

.. c:macro:: MGMT_EVENT_CLEAR_STATS 

.. c:macro:: MGMT_EVENT_CONFIG_FILE_UPDATE

.. c:macro:: MGMT_EVENT_PLUGIN_CONFIG_UPDATE

.. c:macro:: MGMT_EVENT_ROLL_LOG_FILES

.. c:macro:: MGMT_EVENT_LIBRECORDS 

.. c:macro:: MGMT_EVENT_CONFIG_FILE_UPDATE_NO_INC_VERSION

.. c:macro:: MGMT_EVENT_STORAGE_DEVICE_CMD_OFFLINE

.. c:macro:: MGMT_EVENT_LIFECYCLE_MESSAGE