import Vapor
import VaporOAuth


/// OpenID Connect Discovery Document
///
/// Specification: https://openid.net/specs/openid-connect-discovery-1_0.html
struct MyDiscoveryDocument: DiscoveryDocument {

   /// URL using the https scheme with no query or fragment components that the OP asserts as its Issuer Identifier. If Issuer discovery is supported (see Section 2), this value MUST be identical to the issuer value returned by WebFinger. This also MUST be identical to the iss Claim value in ID Tokens issued from this Issuer.
   var issuer: String {
      return "OpenID Provider"
   }

   /// URL of the OP's OAuth 2.0 Authorization Endpoint [OpenID.Core]. This URL MUST use the https scheme and MAY contain port, path, and query parameter components.
   var authorizationEndpoint: String {
      return "http://localhost:8090/oauth/authorize"
   }

   /// URL of the OP's OAuth 2.0 Token Endpoint [OpenID.Core]. This is REQUIRED unless only the Implicit Flow is used. This URL MUST use the https scheme and MAY contain port, path, and query parameter components.
   var tokenEndpoint: String {
      return "http://localhost:8090/oauth//token"
   }

   /// URL of the OP's UserInfo Endpoint [OpenID.Core]. This URL MUST use the https scheme and MAY contain port, path, and query parameter components.
   var userInfoEndpoint: String {
      return ""
   }

   var revocationEndpoint: String {
      return ""
   }

   var introspectionEndpoint: String {
      return "http://localhost:8090/oauth/token_info"
   }

   /// URL of the OP's JWK Set [JWK] document, which MUST use the https scheme. This contains the signing key(s) the RP uses to validate signatures from the OP. The JWK Set MAY also contain the Server's encryption key(s), which are used by RPs to encrypt requests to the Server. When both signing and encryption keys are made available, a use (public key use) parameter value is REQUIRED for all keys in the referenced JWK Set to indicate each key's intended usage. Although some algorithms allow the same key to be used for both signatures and encryption, doing so is NOT RECOMMENDED, as it is less secure. The JWK x5c parameter MAY be used to provide X.509 representations of keys provided. When used, the bare key values MUST still be present and MUST match those in the certificate. The JWK Set MUST NOT contain private or symmetric key values.
   var jwksURI: String {
      return "http://localhost:8090/oauth/.well-known/jwks.json"
   }

   /// URL of the OP's Dynamic Client Registration Endpoint [OpenID.Registration], which MUST use the https scheme.
   var registrationEndpoint: String {
      return ""
   }

   /// JSON array containing a list of the OAuth 2.0 [RFC6749] scope values that this server supports. The server MUST support the openid scope value. Servers MAY choose not to advertise some supported scope values even when this parameter is used, although those defined in [OpenID.Core] SHOULD be listed, if supported.
   var scopesSupported: [String] {
      return ["code"]
   }

   /// JSON array containing a list of the OAuth 2.0 response_type values that this OP supports. Dynamic OpenID Providers MUST support the code, id_token, and the id_token token Response Type values.
   var responseTypesSupported: [String] {
      return ["query"]
   }

   /// JSON array containing a list of the OAuth 2.0 Grant Type values that this OP supports. Dynamic OpenID Providers MUST support the authorization_code and implicit Grant Type values and MAY support other Grant Types. If omitted, the default value is ["authorization_code", "implicit"].
   var grantTypesSupported: [String] {
      return ["authorization_code"]
   }

   /// JSON array containing a list of Client Authentication methods supported by this Token Endpoint. The options are client_secret_post, client_secret_basic, client_secret_jwt, and private_key_jwt, as described in Section 9 of OpenID Connect Core 1.0 [OpenID.Core]. Other authentication methods MAY be defined by extensions. If omitted, the default is client_secret_basic -- the HTTP Basic Authentication Scheme specified in Section 2.3.1 of OAuth 2.0 [RFC6749].
   var tokenEndpointAuthMethodsSupported: [String] {
      return ["client_secret_basic"]
   }

   /// JSON array containing a list of the JWS signing algorithms (alg values) supported by the Token Endpoint for the signature on the JWT [JWT] used to authenticate the Client at the Token Endpoint for the private_key_jwt and client_secret_jwt authentication methods. Servers SHOULD support RS256. The value none MUST NOT be used.
   var tokenEndpointAuthSigningAlgValuesSupported: [String] {
      return ["RS256"]
   }

   /// URL of a page containing human-readable information that developers might want or need to know when using the OpenID Provider. In particular, if the OpenID Provider does not support Dynamic Client Registration, then information on how to register Clients needs to be provided in this documentation.
   var serviceDocumentation: String {
      return ""
   }

   /// Languages and scripts supported for the user interface, represented as a JSON array of BCP47 [RFC5646] language tag values.
   var uiLocalesSupported: [String] {
      return ["en-US"]
   }

   /// URL that the OpenID Provider provides to the person registering the Client to read about the OP's requirements on how the Relying Party can use the data provided by the OP. The registration process SHOULD display this URL to the person registering the Client if it is given.
   var opPolicyURI: String {
      return ""
   }

   /// URL that the OpenID Provider provides to the person registering the Client to read about the OpenID Provider's terms of service. The registration process SHOULD display this URL to the person registering the Client if it is given.
   var opTosURI: String {
      return ""
   }

   var resourceServerRetriever: VaporOAuth.ResourceServerRetriever? {
      return nil
   }

   /// JSON array containing a list of the Subject Identifier types that this OP supports. Valid types include pairwise and public.
   var subjectTypesSupported: [String] {
      return [""]
   }

   /// JSON array containing a list of the Claim Names of the Claims that the OpenID Provider MAY be able to supply values for. Note that for privacy or other reasons, this might not be an exhaustive list.
   var claimsSupported: [String] {
      return ["openid"]
   }

   // Dummy code as this is not used in the example
   var extend: [String : Any] {
      get { 
         return ["":""]
      }
      set {

      }
   }




}
