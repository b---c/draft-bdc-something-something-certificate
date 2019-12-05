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

This document defines the HTTP header field `Client-Cert` that allows a TLS terminating reverse proxy to convey information about the client certificate of a mutually authenticated TLS connection to an origin server in a standardized manner. 
        
{mainmatter}

# Introduction {#Introduction}

A fairly common deployment pattern for HTTPS applications is to have the origin HTTP application servers sit behind a reverse proxy that terminates TLS connections from clients. The proxy is accessible to the internet and dispatches client requests to the appropriate origin server within a private or protected network. The origin servers are not directly accessible by clients and are only reachable through the reverse proxy. The details of this type of deployment are typically opaque to clients who make requests to the proxy server and see responses as though they originated from the proxy server itself. Although HTTPS is also usually employed between the proxy and the origin server, the TLS connection that the client establishes for HTTPS is only between itself and the reverse proxy server. 

The deployment pattern is found in a number of varieties such as n-tier architectures, content delivery networks, application load balancing services, and microservice sidecar proxies. 

Although not exceedingly prevalent, TLS client certificate authentication is sometimes employed and in such cases the origin server often requires information about the client certificate for its application logic. Such logic might include access control decisions, audit logging, and binding issued tokens or cookies to a certificate, and the respective validation of such bindings. The specific details of the certificate needed also vary with the application requirements. In order for these types of application deployments to work in practice, the reverse proxy needs to convey information about the client certificate to the origin application server. A common way this information is conveyed in practice today is by using the non-standard header(s) to carry the certificate (in some encoding) or individual parts thereof in the HTTP request that is dispatched to the origin server. This solution works to some extend but interoperability between independently developed components can be cumbersome or even impossible depending on the implementation choices respectively made (like what headers names are used or are configurable, which parts of the certificate are exposed, or how the certificate is encoded). A standardized approach to this commonly functionality could improve and simplify interoperability between implementations.

This document standardizes the HTTP header field called `Client-Cert` that a TLS terminating reverse proxy adds to requests that it sends to the origin servers. The header value contains the client certificate from the mutually authenticated TLS connection between the client and reverse proxy, which enables the origin server to utilize the certificate in its application logic. The usage of the headers, both the reverse proxy adding the header and the origin server relying on the header for application logic, are to be configuration options of the respective systems as they will not always be applicable. 


## Requirements Notation and Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in BCP 14 [@!RFC2119] [@!RFC8174] when, and only when, they appear in all capitals, as shown here.

## Terminology
Phrases like TLS client certificate authentication or mutually authenticated TLS used throughout this document refer to the process whereby, in addition to the normal TLS server authentication with a certificate, a client presents its X.509 certificate and proves possession of the corresponding private key to a server when negotiating a TLS session.  In contemporary versions of TLS [@RFC8446] [@RFC5246] this requires that the client send the Certificate and CertificateVerify messages during the handshake and for the server to verify the CertificateVerify and Finished messages.

# HTTP Header Field and Processing Rules

## Client-Cert HTTP Header Field

The `Client-Cert` HTTP header field is an OPTIONAL header field that, when used, contains one or more X.509 public key certificates 


Client-Cert
:   The `Client-Cert` HTTP header field is an OPTIONAL header field that, when used, contains one or more X.509 public key certificates 


# Security Considerations

# Acknowledgements

# IANA Considerations

[[ TODO the `Client-Cert` HTTP header field ]]


{backmatter}

# Document History

   [[ To be removed by the RFC Editor before publication as an RFC (should that come to pass) ]]

   -00 

   * Initial draft after time constrained and rushed [secdispatch presentation](https://datatracker.ietf.org/meeting/106/materials/slides-106-secdispatch-securing-protocols-between-proxies-and-backend-http-servers-00) at IETF 106 in Singapore with the recommendation to write up a draft (at the end of the [minutes](https://datatracker.ietf.org/meeting/106/materials/minutes-106-secdispatch)) and some folks expressing interest 
   
