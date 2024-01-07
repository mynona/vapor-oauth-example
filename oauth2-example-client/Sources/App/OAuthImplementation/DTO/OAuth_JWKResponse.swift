import Vapor
import JWT


public struct RSAKey: Content {

   public let kid: String?
   public let kty: String?
   public let e: String?
   public let n: String?
   public let alg: String?

   public init(
      kid: String?,
      kty: String?,
      e: String?,
      n: String?,
      alg: String?
   ) {
      self.kid = kid
      self.kty = kty
      self.e = e
      self.n = n
      self.alg = alg
   }
}



/// Response /.well-known/jwks.json
///
public struct OAuth_JWKResponse: Content {

   // Access token
   public let keys: [RSAKey]

   public init(
      keys: [RSAKey]
   ) {
      self.keys = keys
   }
}
