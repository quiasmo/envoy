.. _config_http_conn_man_access_log:

Access logging
==============

Configuration
-------------------------

Access logs are configured as part of the :ref:`HTTP connection manager config
<config_http_conn_man>`.

.. code-block:: json

  {
    "access_log": [
      {
        "path": "...",
        "format": "...",
        "filter": "{...}",
      },
    ]
  }

.. _config_http_conn_man_access_log_path_param:

path
  *(required, string)* Path the access log is written to.

.. _config_http_conn_man_access_log_format_param:

format
  *(optional, string)* Access log format. Envoy supports :ref:`custom access log formats
  <config_http_con_manager_access_log_format>` as well as a :ref:`default format
  <config_http_con_manager_access_log_default_format>`.

.. _config_http_conn_man_access_log_filter_param:

filter
  *(optional, string)* :ref:`Filter <config_http_con_manager_access_log_filters>` which is used to
  determine if the access log needs to be written.

.. _config_http_con_manager_access_log_format:

Format rules
------------

The access log format string contains either command operators or other characters interpreted as a
plain string. Note, if one of the parameters are not available '-' will be present in the log
entry. The following command operators are supported:

%START_TIME%
  Request start time including milliseconds.

%BYTES_RECEIVED%
  Body bytes received.

%PROTOCOL%
  Protocol. Currently either *HTTP/1.1* or *HTTP/2*.

%RESPONSE_CODE%
  HTTP response code. Note that a response code of '0' means that the server never sent the
  beginning of a response. This generally means that the (downstream) client disconnected.

%BYTES_SENT%
  Body bytes sent.

%DURATION%
  Total duration in milliseconds of the request from the start time to the last byte out.

%FAILURE_REASON%
  Additional failure reason if any in addition to response code. Possible values are:

  * **LH**: Local health check failed.
  * **UH**: No healthy upstream.
  * **UT**: Upstream request timeout.
  * **LR**: Connection local reset.
  * **UR**: Upstream remote reset.
  * **UF**: Upstream connection failure.
  * **UC**: Upstream connection termination.
  * **UO**: Upstream overflow (circuit breaking).
  * **NR**: No route configured for a given request.

%UPSTREAM_HOST%
  Upstream host URL (e.g., tcp://ip:port for TCP connections).

%REQ(X?Y):Z%
  An HTTP request header where X is the main HTTP header, Y is the alternative one, and Z is an
  optional parameter denoting string truncation up to Z characters long. The value is taken from the
  HTTP request header named X first and if it's not set, then request header Y is used. If none of
  the headers are present '-' symbol will be in the log.

%RESP(X?Y):Z%
  Same as **%REQ(X?Y):Z%** but taken from HTTP response headers.

.. _config_http_con_manager_access_log_default_format:

Default format
--------------

If custom format is not specified, Envoy uses the following default format::

  [%START_TIME%] "%REQ(:METHOD)% %REQ(X-ENVOY-ORIGINAL-PATH?:PATH)% %PROTOCOL%"
  %RESPONSE_CODE% %FAILURE_REASON% %BYTES_RECEIVED% %BYTES_SENT% %DURATION%
  %RESP(X-ENVOY-UPSTREAM-SERVICE-TIME)% "%REQ(X-FORWARDED-FOR)%" "%REQ(USER-AGENT)%"
  "%REQ(X-REQUEST-ID)%" "%REQ(:AUTHORITY)%" "%UPSTREAM_HOST%"

Example of the default Envoy access log format::

  [2016-04-15T20:17:00.310Z] "POST /api/v1/locations HTTP/2" 204 - 154 0 226 100 "10.0.35.28"
  "nsq2http" "cc21d9b0-cf5c-432b-8c7e-98aeb7988cd2" "locations" "tcp://10.0.2.1:80"

.. _config_http_con_manager_access_log_filters:

Filters
-------

Envoy supports the following access log filters:

.. contents::
  :local:

Status code
^^^^^^^^^^^

.. code-block:: json

  {
    "filter": {
      "type": "status_code",
      "op": "...",
      "value": "..."
    }
  }

Filters on HTTP response/status code.

op
  *(required, string)* Comparison operator. Currently *>=* is the only supported operator.

value
  *(required, integer)* The value to compare against.

Duration
^^^^^^^^

.. code-block:: json

  {
    "filter": {
      "type": "duration",
      "op": "..",
      "value": "..."
    }
  }

Filters on total request duration in milliseconds.

op
  *(required, string)* Comparison operator. Currently *>=* is the only supported operator.

value
  *(required, integer)* The value to compare against.

Not health check
^^^^^^^^^^^^^^^^

.. code-block:: json

  {
    "filter": {
      "type": "not_healthcheck"
    }
  }

Filters for requests that are not health check requests. A health check request is marked by
the :ref:`health check filter <config_http_filters_health_check>`.

Traceable
^^^^^^^^^

.. code-block:: json

  {
    "filter": {
      "type": "traceable_request"
    }
  }

Filters for requests that are traceable. See the :ref:`tracing overview <arch_overview_tracing>` for
more information on how a request becomes traceable.

And
^^^

.. code-block:: json

  {
    "filter": {
      "type": "logical_and",
      "filters": []
    }
  }

Performs a logical "and" operation on the result of each filter in *filters*. Filters are evaluated
sequentially and if one of them returns false, the filter returns false immediately.

Or
^^

.. code-block:: json

  {
    "filter": {
      "type": "logical_or",
      "filters": []
    }
  }

Performs a logical "or" operation on the result of each individual filter. Filters are evaluated
sequentially and if one of them returns true, the filter returns true immediately.