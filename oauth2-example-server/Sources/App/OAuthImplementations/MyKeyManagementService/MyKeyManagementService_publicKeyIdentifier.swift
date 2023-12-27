import Vapor
import VaporOAuth
import Fluent
import JWTKit

extension MyKeyManagementService {

   /// (Key ID) Parameter for JWT JOSE Header
   ///
   /// The "kid" (key ID) parameter is used to match a specific key. This is used, for instance, to choose among a set of keys within a JWK Set during key rollover.  The structure of the "kid" value is unspecified.  When "kid" values are used within a JWK Set, different keys within the JWK Set SHOULD use distinct "kid" values.  (One example in which different keys might use the same "kid" value is if they have different "kty" (key type) values but are considered to be equivalent alternatives by the application using them.)  The "kid" value is a case-sensitive string.  Use of this member is OPTIONAL. When used with JWS or JWE, the "kid" value is used to match a JWS or JWE "kid" Header Parameter value.
   ///
   /// https://datatracker.ietf.org/doc/html/rfc7517#autoid-56
   ///
   /// - Returns: kid
   ///
   func publicKeyIdentifier() throws -> String {

      return "public-key"

   }

}
