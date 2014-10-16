# encoding: UTF-8
require_relative 'spec_helper'

describe Raml::Documentation do
  let(:root_data) { {'title' => 'x', 'baseUri' => 'http://foo.com'} }
  let(:root) { Raml::Root.new root_data }

  let(:title) { 'Request Formats' }
  let(:content) { <<-EOS
Credentials
-----------

All requests to Twilio's REST API require you to authenticate using [HTTP basic auth](http://en.wikipedia.org/wiki/Basic_access_authentication) to convey your identity. The username is your AccountSid (a 34 character string, starting with the letters AC). The password is your AuthToken. Your AccountSid and AuthToken are on the [Account Dashboard](http://www.twilio.com/user/account/) page.

Most HTTP clients (including web-browsers) present a dialog or prompt for you to provide a username and password for HTTP basic auth. Most clients will also allow you to provide credentials in the URL itself. For example:

```
https://{AccountSid}:{AuthToken}@api.twilio.com/2010-04-01/Accounts
```

Retrieving Resources with the HTTP GET Method
---------------------------------------------

You can retrieve a representation of a resource by GETting its url. The easiest way to do this is to copy and paste a URL into your web browser's address bar.

### Possible GET Response Status Codes

* 200 OK: The request was successful and the response body contains the representation requested.
* 302 FOUND: A common redirect response; you can GET the representation at the URI in the Location response header.
* 304 NOT MODIFIED: Your client's cached version of the representation is still up to date.
* 401 UNAUTHORIZED: The supplied credentials, if any, are not sufficient to access the resource.
* 404 NOT FOUND: You know this one.
* 429 TOO MANY REQUESTS: Your application is sending too many simultaneous requests.
* 500 SERVER ERROR: We couldn't return the representation due to an internal server error.
* 503 SERVICE UNAVAILABLE: We are temporarily unable to return the representation. Please wait for a bit and try again.
EOS
	}
  subject { Raml::Documentation.new(title, {'content' => content }, root) }
 end