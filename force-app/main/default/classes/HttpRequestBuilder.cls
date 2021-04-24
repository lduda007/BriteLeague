global class HttpRequestBuilder {

	private static final String METHOD_GET = 'GET';
	private static final String METHOD_POST = 'POST';
	private static final String METHOD_PUT = 'PUT';
	private static final String METHOD_DELETE = 'DELETE';

	private String endpoint;
	private String body;
	private Map<String, String> headers;
	private Map<String, String> rawBody;
	private Map<String, String> params;

	public HttpRequestBuilder(String endpoint) {
		this.endpoint = endpoint;
		this.headers = new Map<String, String>();
		this.rawBody = new Map<String, String>();
		this.params = new Map<String, String>();
	}

	public HttpRequestBuilder body(String body) {
		this.body = body;

		return this;
	}

	public HttpRequestBuilder body(String name, String value) {
		this.rawBody.put(name, value);

		return this;
	}

	public HttpRequestBuilder header(String name, String value) {
		this.headers.put(name, value);

		return this;
	}

	public HttpRequestBuilder param(String name, String value) {
		this.params.put(name, value);

		return this;
	}

	public String get() {
		return sendRequest(METHOD_GET);
	}

	public String post() {
		return sendRequest(METHOD_POST);
	}

	public String put() {
		return sendRequest(METHOD_PUT);
	}

	public String del() {
		return sendRequest(METHOD_DELETE);
	}

	private String sendRequest(String method) {
		Http http = new Http();

		if (params.isEmpty() == false) {
			String parameters = '?';
			for (String key : params.keySet()) {
				parameters += key + '=' + EncodingUtil.urlEncode(params.get(key), 'UTF-8') + '&';
			}
			parameters = parameters.substring(0, parameters.length() - 1);

			endpoint += parameters;
		}

		HttpRequest req = new HttpRequest();
		req.setEndpoint(endpoint);
		req.setMethod(method);

		if (String.isNotBlank(body)) {
			req.setBody(body);
		}

		if (rawBody.isEmpty() == false) {
			String body = '';
			for (String key : rawBody.keySet()) {
				body += key + '=' + EncodingUtil.urlEncode(rawBody.get(key), 'UTF-8') + '&';
			}
			body = body.substring(0, body.length() - 1);
			req.setBody(body);
		}

		if (headers.isEmpty() == false) {
			for (String key : headers.keySet()) {
				req.setHeader(key, headers.get(key));
			}
		}

		HttpResponse res = http.send(req);

		return res.getBody();
	}

}