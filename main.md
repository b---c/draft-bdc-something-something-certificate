%%%
title = "Client-Cert HTTP Header: Conveying Client Certificate Information from TLS Terminating Reverse Proxies to Origin Server Applications"
abbrev = "Client-Cert Header"
ipr = "trust200902"
area = "Security"
workgroup = "Aspirational"

[seriesInfo]
name = "Internet-Draft"
value = "draft-bdc-something-something-certificate-00"
stream = "IETF"
status = "standard"

[[author]]
initials="B."
surname="Campbell"
fullname="Brian Campbell"
organization="Ping Identity"
    [author.address]
    email = "bcampbell@pingidentity.com"
%%%

.# Abstract

This document defines the HTTP header field `Client-Cert` that allows a TLS terminating reverse proxy to convey information about the client certificate of a mutually-authenticated TLS connection to an origin server in a standardized manner. 
        
{mainmatter}

# Introduction {#Introduction}

A fairly common deployment pattern for HTTPS applications is to have the origin HTTP application servers sit behind a reverse proxy that terminates TLS connections from clients. The proxy is accessible to the internet and dispatches client requests to the appropriate origin server within a private or protected network. The origin servers are not directly accessible by clients and are only reachable through the reverse proxy. The details of this type of deployment are typically opaque to clients who make requests to the proxy server and see responses as though they originated from the proxy server itself. Although HTTPS is also usually employed between the proxy and the origin server, the TLS connection that the client establishes for HTTPS is only between itself and the reverse proxy server. 

The deployment pattern is found in a number of varieties such as n-tier architectures, content del  ivery networks, application load balancing services, and ingress controllers.

Although not exceedingly prevalent, TLS client certificate authentication is sometimes employed and in such cases the origin server often requires information about the client certificate for its application logic. Such logic might include access control decisions, audit logging, and binding issued tokens or cookies to a certificate, and the respective validation of such bindings. The specific details of the certificate needed also vary with the application requirements. In order for these types of application deployments to work in practice, the reverse proxy needs to convey information about the client certificate to the origin application server. A common way this information is conveyed in practice today is by using the non-standard header(s) to carry the certificate (in some encoding) or individual parts thereof in the HTTP request that is dispatched to the origin server. This solution works to some extend but interoperability between independently developed components can be cumbersome or even impossible depending on the implementation choices respectively made (like what headers names are used or are configurable, which parts of the certificate are exposed, or how the certificate is encoded). A standardized approach to this commonly functionality could improve and simplify interoperability between implementations.

This document aspires to standardize an HTTP header field called `Client-Cert` that a TLS terminating reverse proxy adds to requests that it sends to the origin servers. The header value contains the client certificate from the mutually-authenticated TLS connection between the client and reverse proxy, which enables the origin server to utilize the certificate in its application logic. The usage of the headers, both the reverse proxy adding the header and the origin server relying on the header for application logic, are to be configuration options of the respective systems as they will not always be applicable. 


## Requirements Notation and Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in BCP 14 [@!RFC2119] [@!RFC8174] when, and only when, they appear in all capitals, as shown here.

## Terminology
Phrases like TLS client certificate authentication or mutually-authenticated TLS are used throughout this document refer to the process whereby, in addition to the normal TLS server authentication with a certificate, a client presents its X.509 certificate [@!RFC5280] and proves possession of the corresponding private key to a server when negotiating a TLS session.  In contemporary versions of TLS [@RFC8446] [@RFC5246] this requires that the client send the Certificate and CertificateVerify messages during the handshake and for the server to verify the CertificateVerify and Finished messages.

# HTTP Header Field and Processing Rules

## Encoding 
The field-values of the HTTP header defined herein utilize the following encoded form. 

A certificate is represented in text as an `EncodedCertificate`, which is the base64-encoded (Section 4 of [@!RFC4648]) DER [@!ITU.X690] PKIX certificate. The encoded value MUST NOT include any line breaks, whitespace, or other additional characters. ABNF [@RFC5234] syntax for `EncodedCertificate` is shown in the figure below. 

```
 EncodedCertificate = 1*( DIGIT / ALPHA / "+" / "/" ) 0*2"=" 

 DIGIT = <Defined in Section B.1 of [RFC5234]>  ; A-Z / a-z
 ALPHA = <Defined in Section B.1 of [RFC5234]>  ; 0-9  
```

## Client-Cert HTTP Header Field {#header}
 In the context of a TLS terminating reverse proxy (TTRP) deployment, the TTRP makes the TLS client certificate available to the backend application with the following header field.
 
Client-Cert
:      The certificate or certificate chain as a comma-separated list of `EncodedCertificate` values with the end-entity certificate first followed by any intermediate certificates. 
                                                                                                
The `Client-Cert` header field defined herein is only for use in HTTP requests and MUST NOT be used in HTTP responses. 

## Processing Rules

This section defines the applicable processing rules for a TLS terminating reverse proxy (TTRP) that has negotiated a mutually-authenticated TLS connection to convey the client certificate and any intermediaries from that connection to the backend origin servers. Use of the technique is to be a configuration or deployment option and the processing rules described herein are for servers operating with that option enabled. 

A TTRP negotiates the use of a mutually-authenticated TLS connection with the client, such as is described in [@RFC8446] or [@RFC5246], and validates the client certificate per its policy and trusted certificate authorities.  Each HTTP request on the underlying TLS connection are dispatched to the origin server with the following modifications:

1. The client certificate and any intermediate certificates are be placed in the `Client-Cert` header field of the dispatched request as defined in (#header).
1. Any occurrence of the `Client-Cert` header in the original incoming request MUST be removed or overwritten before forwarding the request.

Requests made over a TLS connection where the use of client certificate authentication was not negotiated MUST be sanitized by removing any and all occurrences `Client-Cert` header field prior to dispatching the request to the backend server.

Forward proxies and other intermediaries MUST NOT add the `Client-Cert` header to requests. 

Backend origin servers may then use the `Client-Cert` header of the request to determine if the connection from the client to the TTRP was mutually-authenticated and, if so, the certificate thereby presented by the client. 


# Security Considerations

The header described herein enable a reverse proxy and backend or origin server to function together as though, from the client's perspective, they are a single logical server side deployment of HTTPS over a mutually-authenticated TLS connection. Use of the headers outside that intended use case, however, may undermine the protections afforded by TLS client certificate authentication. Therefore steps MUST be taken to prevent unintended use, both in sending the headers and in relying on their value.

Producing and consuming the headers SHOULD be a configurable option, respectively, in a reverse proxy and backend server (or individual application in that server). The default configuration for both should be to not use the headers thus requiring an "opt-in" to the functionality.

Backend servers MUST only accept the headers from trusted reverse proxies. And reverse proxies MUST sanitize the incoming request before forwarding it on by removing or overwriting any existing instances of the headers. Otherwise arbitrary clients can control the header values as seen and used by the backend server.

The communication between a reverse proxy and backend server needs to be secured against eavesdropping and modification by unintended parties.

The configuration options and request sanitization are necessarily functionally of the respective servers. The other requirements can be met in a number of ways, which will vary based on specific deployments. The communication between a reverse proxy and backend or origin server, for example, might be authenticated in some way with the insertion and consumption headers occurring only on that connection. Alternatively the network topology might dictate a private network such that the backend application is only able to accept requests from the reverse proxy and the proxy can only make requests to that server. Other deployments that meet the requirements set forth herein are also possible.
 

# Acknowledgements
[[TBD]]

# IANA Considerations

   [[ TBD if this draft progresses, register the `Client-Cert` HTTP header field in the "Permanent Message Header Field Names" registry defined in [@RFC3864] ]]

{backmatter}

# Example 
[[TBD]]

# Considerations Considered
[[TBD: RFC7239, maybe something about the TTRP-to-origin connection and sanitation, maybe something about the whole cert vs. parts]]

# Document History

   [[ To be removed by the RFC Editor before publication as an RFC (should that come to pass) ]]

   draft-bdc-something-something-certificate-00 

   * Initial draft after a time constrained and rushed [secdispatch presentation](https://datatracker.ietf.org/meeting/106/materials/slides-106-secdispatch-securing-protocols-between-proxies-and-backend-http-servers-00) at IETF 106 in Singapore with the recommendation to write up a draft (at the end of the [minutes](https://datatracker.ietf.org/meeting/106/materials/minutes-106-secdispatch)) and some folks expressing interest despite the rather poor presentation 

   
<reference anchor="ITU.X690">
<front>
<title>
Information Technology - ASN.1 encoding rules: Specification of Basic Encoding Rules (BER), Canonical Encoding Rules (CER) and Distinguished Encoding Rules (DER)
</title>
<author>
<organization>International Telecommunications Union</organization>
</author>
<date month="August" year="2015"/>
</front>
<seriesInfo name="ITU-T" value="Recommendation X.690"/>
</reference>
