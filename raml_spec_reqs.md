# Markup Language
- [x] The RAML version MUST be the first line of the RAML document.
- [x] RAML parsers MUST interpret all other YAML-commented lines as comments.
- [x] In RAML, all values MUST be interpreted in a case-sensitive manner.

## Includes
- [x] All RAML parsers MUST support the include tag, which enables including RAML and YAML and regular text files.
- [x] When RAML or YAML files are included, RAML parsers MUST not only read the content, but parse it and add the content to the declaring structure as if the content were declared inline.
- [x] If a relative path is used for the included file, the path is interpreted relative to the location of the original (including) file.
- [ ] If the original file is fetched as an HTTP resource, the included file SHOULD be fetched over HTTP.
- [ ] If the included file has one of the following media types:
    - application/raml+yaml
    - text/yaml
    - text/x-yaml
    - application/yaml
    - application/x-yaml
    RAML parsers MUST parse the content the file as RAML content and append the parsed structures to the RAML document's node.
- [x] If the included file has a .raml or .yml or .yaml extension, RAML parsers MUST parse the content the file as RAML content and append the parsed structures to the RAML document's node.


# Named Parameters

### type
- [x] If type is not specified, it defaults to string.
- [x] Valid types are: string, number, integer, date, boolean, file.

### enum
- [x] Optional.
- [x] Applicable only for parameters of type string.
- [x] MUST be an array.

### pattern
- [x] Optional.
- [x] Applicable only for parameters of type string.
- [x] The pattern attribute is a regular expression.
- [x] Regular expressions MUST follow the regular expression specification from ECMA 262/Perl 5.
- [x] The pattern MAY be enclosed in double quotes for readability and clarity.

### minLength
- [x] Optional.
- [x] Applicable only for parameters of type string.

### maxLength
- [x] Optional.
- [x] Applicable only for parameters of type string.

### minimal
- [x] Optional.
- [x] Applicable only for parameters of type number or integer.

### maximum
- [x] Optional.
- [x] Applicable only for parameters of type number or integer.

### example
- [x] Optional.

### repeat
- [x] Optional.
- [x] The default value is 'false'.

### required
- [x] Optional except as otherwise noted.
- [x] In general, parameters are optional unless the required attribute is included and its value set to 'true'.
- [x] For a URI parameter, the required attribute MAY be omitted, but its default value is 'true'.

### default
- [x] Optional.

## Named Parameters With Multiple Types
- [x] To denote that a named parameter can have multiple types, the value of the named parameter property MAY be an array of mappings, each of which has the attributes described in this document.


## Basic Information
###Root Section
- [x] RAML-documented API definition properties MAY appear in any order.

### API Title
- [x] Required.
- [x] The title property is a short plain text description of the RESTful API.

### API Version
- [x] Optional.

### Base URI and baseUriParameters
- [ ] Optional during development.
- [x] Required after implementation.
- [x] The baseUri property's value MUST conform to the URI specification [RFC2396] or a Level 1 Template URI [RFC6570].
- [ ] If a URI template variable in the base URI is not explicitly described in a baseUriParameters property, and is not specified in a resource-level uriParameters property, it MUST still be treated as a base URI parameter with defaults as specified in the Named Parameters section of this specification. Its type is "string", it is required, and its displayName is its name (i.e. without the surrounding curly brackets [{] and [}]).

### Protocols
- [x] Optional.
- [x] The protocols property MUST be an array of strings, of values "HTTP" and/or "HTTPS".

### Default Media Type
- [x] Optional.
- [x] The media types returned by API responses, and expected from API requests that accept a body, MAY be defaulted by specifying the mediaType property.

### Schemas
- [x] Optional.
- [x] The value of the schemas property is an array of maps; in each map, the keys are the schema name, and the values are schema definitions. 
- [x] The schema definitions MAY be included inline or by using the RAML !include user-defined data type.

### Base URI Parameters
- [x] Optional.
- [x] The baseUriParameters property MUST be a map in which each key MUST be the name of the URI parameter as defined in the baseUri property.
- [x] The uriParameters CANNOT contain a key named version because it is a reserved URI parameter name.

### User Documentation
- [x] Optional.
- [x] Documentation-generators MUST include all the sections in an API definition's documentation property in the documentation output.
- [x] And they MUST preserve the order in which the documentation is declared.
- [x] The documentation property MUST be an array of documents.
- [x] Each document MUST contain title and content attributes, both of which are REQUIRED.
- [x] If the documentation property is specified, it MUST include at least one document.
- [x] Documentation-generators MUST process the content field as if it was defined using Markdown.
- [x] The documentation property MAY be included inline, as described above, or by using the RAML !include user-defined data type to reference external content.

### Resources and Nested Resources
- [x] Resources are identified by their relative URI, which MUST begin with a slash (/).
- [x] A resource defined as a root-level property is called a top-level resource. Its property's key is the resource's URI relative to the baseUri.
- [x] A resource defined as a child property of another resource is called a nested resource, and its property's key is its URI relative to its parent resource's URI.
- [x] Every property whose key begins with a slash (/), and is either at the root of the API definition or is the child property of a resource property, is a resource property.

#### Display Name
- [x] The displayName key is OPTIONAL.
- [x] If the displayName attribute is not defined for a resource, documentation tools SHOULD refer to the resource by its property key (i.e. its relative URI, e.g., "/jobs"), which acts as the resource's name.

#### Description
- [x] Each resource, whether top-level or nested, MAY contain a description property that briefly describes the resource.

#### Template URIs and URI Parameters
- [x] A resource MAY contain a uriParameters property specifying the uriParameters in that resource's relative URI, as described in the Named Parameters section of this specification. 

#### Base URI parameters
- [x] The baseUriParameters property MAY be used to override any or all parameters defined at the root level baseUriParameters property, as well as base URI parameters not specified at the root level.
- [x] In a resource structure of resources and nested resources with their methods, the most specific baseUriParameter fully overrides any baseUriParameter definition made before. In the following example the resource /user/{userId}/image overrides the definition made in /users.
- [x] The special baseUriParameter version is reserved.
- [ ] Processing applications MUST replace occurrences of {version} in any baseUri property values with the value of the root-level version property.
- [x] The {version} parameter, if used in a baseUri, is required.

#### Methods
- [x] A method MUST be one of the HTTP methods defined in the HTTP version 1.1 specification [RFC2616] and its extension, RFC5789 [RFC5789].

##### Description
- [x] Each declared method MAY contain a description attribute that briefly describes what the method does to the resource.
- [x] The value of the description property MAY be formatted using Markdown [MARKDOWN].

##### Headers
- [x] The headers property is a map in which the key is the name of the header, and the value is itself a map specifying the header attributes, according to the Named Parameters section.

###### Example
- [x] Documentation generators MUST include content specified as example information for headers. This information is included in the API definition by using the example property.

##### Protocols
- [ ] A method can override an API's protocols value for that single method by setting a different value for the fields.

##### Query Strings
- [x] The queryParameters property is a map in which the key is the query parameter's name, and the value is itself a map specifying the query parameter's attributes, according to the Named Parameters section.
- [x] Query string queryParameters properties MAY include an example attribute.
- [ ] Documentation generators MUST use example attributes to generate example invocations.

##### Body
- [x] Resources CAN have alternate representations.
- [x] A method's body is defined in the body property as a hashmap.
- [x] The key MUST be a valid media type.

###### Web Forms
- [x] If the API's media type is either application/x-www-form-urlencoded or multipart/form-data, the formParameters property MUST specify the name-value pairs that the API is expecting.
- [x] The formParameters property is a map in which the key is the name of the web form parameter, and the value is itself a map the specifies the web form parameter's attributes, according to the Named Parameters section.

###### Schema
- [x] The structure of a request or response body MAY be further specified by the schema property under the appropriate media type.
- [x] The schema key CANNOT be specified if a body's media type is application/x-www-form-urlencoded or multipart/form-data.
- [x] All parsers of RAML MUST be able to interpret JSON Schema [JSON_SCHEMA]
- [ ] All parsers of RAML MUST be able to interpret XML Schema [XML_SCHEMA].
- [x] Schema MAY be declared inline or in an external file.
- [x] Alternatively, the value of the schema field MAY be the name of a schema specified in the root-level schemas property.

###### Example
- [x] Documentation generators MUST use body properties' example attributes to generate example invocations.

##### Responses
- [x] Resource methods MAY have one or more responses.
- [x] Responses MAY be described using the description property.
- [x] And MAY include example attributes or schema properties
- [x] Responses MUST be a map of one or more HTTP status codes, where each status code itself is a map that describes that status code.
- [x] Each response MAY contain a body property, which conforms to the same structure as request body properties (see Body).
- [x] Responses that can return more than one response code MAY therefore have multiple bodies defined.
- [x] Responses MAY contain a description property that further clarifies why the response was emitted.

###### Headers
- [x] The headers property is a map in which the key is the name of the header, and the value is itself a map specifying the header attributes, according to the Named Parameters section.
- [x] Documentation generators MUST include content specified as example information for headers. 

### Resource Types and Traits
- [x] Resources may specify the resource type from which they inherit using the type property.
- [x] The resource type may be defined inline as the value of the type property (directly or via an !include).
- [x] Or the value of the type property may be the name of a resource type defined within the root-level resourceTypes property.
- [x] Methods may specify one or more traits from which they inherit using the is property.
- [x] A resource may also use the is property to apply the list of traits to all its methods.
- [x] The value of the is property is an array of traits.
- [x] Each trait element in that array may be defined inline (directly or via an !include).
- [x] Or it may be the name of a trait defined within the root-level traits property.
- [x] Resource type definitions MUST NOT incorporate nested resources.

#### Declaration
- [x] The resourceTypes and traits properties are declared at the API definition's root level with the resourceTypes and traits property keys, respectively.
- [x] The value of each of these properties is an array of maps; in each map, the keys are resourceType or trait names, and the values are resourceType or trait definitions, respectively.

##### Usage
- [x] The usage property of a resource type or trait is used to describe how the resource type or trait should be used. 
- [ ] Documentation generators MUST convey this property as characteristics of the resource and method, respectively.
- [x] However, the resources and methods MUST NOT inherit the usage property: neither resources nor methods allow a property named usage.

##### Parameters
- [x] In resource type definitions, there are two reserved parameter names: resourcePath and resourcePathName. The processing application MUST set the values of these reserved parameters to the inheriting resource's path (for example, "/users") and the part of the path following the rightmost "/" (for example, "users"), respectively.
- [ ] Processing applications MUST also omit the value of any mediaTypeExtension found in the resource's URI when setting resourcePath and resourcePathName.
- [x] In trait definitions, there is one reserved parameter name, methodName, in addition to the resourcePath and resourcePathName. The processing application MUST set the value of the methodName parameter to the inheriting method's name. The processing application MUST set the values of the resourcePath and resourcePathName parameters the same as in resource type definitions.
- [x] The !singularize function MUST act on the value of the parameter by a locale-specific singularization of its original value. The only locale supported by this version of RAML is United States English.
- [x] The !pluralize function MUST act on the value of the parameter by a locale-specific pluralization of its original value. The only locale supported by this version of RAML is United States English.
- [x] Parameters may not be used within !include tags, that is, within the location of the file to be included. This will be reconsidered for future versions of RAML

##### Optional Properties
- [x] A resource type or trait definition MAY append a question mark ("?") suffix to the name of any non-scalar property that should not be applied if it doesn't already exist in the resource or method at the corresponding level. 
- [x] Using the optional marker ("?") in a scalar property such as usage or displayName MUST be rejected from RAML parsers.

#### Applying Resource Types and Traits
- [x] To apply a resource type definition to a resource, so that the resource inherits the resource type's characteristics, the resource MUST be defined using the type attribute
- [x] The value of the type attribute MUST be either a) one and only one of the resource type keys (names) included in the resourceTypes declaration, or b) one and only one resource type definition map.
- [x] To apply a trait definition to a method, so that the method inherits the trait's characteristics, the method MUST be defined by using the is attribute. 
- [x] The value of the is attribute MUST be an array of any number of elements, each of which MUST be a) one or more trait keys (names) included in the traits declaration, or b) one or more trait definition maps.
- [x] A trait may also be applied to a resource by using the is key, which is equivalent to applying the trait to all methods for that resource, whether declared explicitly in the resource definition or inherited from a resource type.

## Security

### Declaration
- [ ] The securitySchemes property is declared at the API's root level.

##### Description
- [ ] The description attribute MAY be used to describe a securitySchemes property.

##### Type
- [ ] The type attribute MAY be used to convey information about authentication flows and mechanisms to processing applications such as Documentation Generators and Client generators.
- [ ] Processing applications SHOULD provide handling for the following schemes:
    - [ ] OAuth 1.0 The API's authentication requires using OAuth 1.0 as described in RFC5849 [RFC5849]
    - [ ] OAuth 2.0 The API's authentication requires using OAuth 2.0 as described in RFC6749 [RFC6749]
    - [ ] Basic Authentication  The API's authentication relies on using Basic Access Authentication as described in RFC2617 [RFC2617]
    - [ ] Digest Authentication The API's authentication relies on using Digest Access Authentication as described in RFC2617 [RFC2617]
    - [ ] x-{other} The API's authentication relies in another authentication method.

##### describedBy
- [ ] The describedBy attribute MAY be used to apply a trait-like structure to a security scheme mechanism so as to extend the mechanism, such as specifying response codes, HTTP headers or custom documentation.

##### Settings
- [ ] The settings attribute MAY be used to provide security schema-specific information. 
- [ ] The following lists describe the minimum set of properties which any processing application MUST provide and validate if it chooses to implement the Security Scheme type.
    - [ ] OAuth 1.0
        - [ ] requestTokenUri   The URI of the Temporary Credential Request endpoint as defined in RFC5849 Section 2.1
        - [ ] authorizationUri  The URI of the Resource Owner Authorization endpoint as defined in RFC5849 Section 2.2
        - [ ] tokenCredentialsUri   The URI of the Token Request endpoint as defined in RFC5849 Section 2.3
    - [ ] OAuth 2.0
        - [ ] authorizationUri  The URI of the Authorization Endpoint as defined in RFC6749 [RFC6748] Section 3.1
        - [ ] accessTokenUri    The URI of the Token Endpoint as defined in RFC6749 [RFC6748] Section 3.2
        - [ ] authorizationGrants   A list of the Authorization grants supported by the API As defined in RFC6749 [RFC6749] Sections 4.1, 4.2, 4.3 and 4.4, can be any of: code, token, owner or credentials.
        - [ ] scopes    A list of scopes supported by the API as defined in RFC6749 [RFC6749] Section 3.3

### Usage: Applying a Security Scheme to an API
- [ ] To apply a securityScheme definition to every method in an API, the API MAY be defined using the securedBy attribute. This specifies that all methods in the API are protected using that security scheme.
- [ ] Applying a securityScheme definition to a method overrides whichever securityScheme has been defined at the root level.
- [ ] To indicate that the method is protected using a specific security scheme, the method MUST be defined by using the securedBy attribute.
- [ ] The value of the securedBy attribute MUST be a list of any of the security schemas defined in the securitySchema declaration.
- [ ] A securityScheme may also be applied to a resource by using the securedBy key, which is equivalent to applying the securityScheme to all methods that may be declared, explicitly or implicitly, by defining the resourceTypes or traits property for that resource.
- [ ] To indicate that the method may be called without applying any securityScheme, the method may be annotated with the null securityScheme.
- [ ] If the processing application supports custom properties, custom parameters can be provided to the security scheme at the moment of inclusion in a method.

