import JWTKit

public struct PayloadAccessToken: JWTPayload {

   enum CodingKeys: String, CodingKey {
      case jti = "jti" // unique token id
      case aud = "aud" // audience
      case sub = "sub" // subject
      case scopes = "scopes"
      case exp = "exp" // expiration
      case iss = "iss" // issuer
      case iat = "iat" // issuing date
   }

   public var jti: String
   public var aud: String
   public var sub: String?
   public var scopes: String?
   public var exp: Date
   public var iss: String
   public var iat: Date

   init(jti: String,
        aud: String,
        sub: String? = nil,
        scopes: String? = nil,
        exp: Date,
        iss: String,
        iat: Date
   ) {
      self.jti = jti
      self.aud = aud
      self.sub = sub
      self.scopes = scopes
      self.exp = exp
      self.iss = iss
      self.iat = iat
   }

   public func verify(using signer: JWTSigner) throws {
       try exp.verifyNotExpired()
   }

}
