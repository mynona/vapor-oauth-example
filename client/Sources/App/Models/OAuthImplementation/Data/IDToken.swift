import JWTKit

public struct PayloadIDToken: JWTPayload {

   enum CodingKeys: String, CodingKey {
      case sub = "sub"
      case aud = "aud"
      case exp = "exp"
      case nonce = "nonce"
      case authTime = "auth_time" // time when authentication occured
      case iss = "iss"
      case iat = "iat"
      case jti = "jti"
   }

   public var sub: String
   public var aud: [String]
   public var exp: Date
   public var nonce: String?
   public var authTime: Date?
   public var iss: String
   public var iat: Date
   public var jti: String

   init(sub: String,
        aud: [String],
        exp: Date,
        nonce: String?,
        authTime: Date?,
        iss: String,
        iat: Date,
        jti: String
   ) {
      self.sub = sub
      self.aud = aud
      self.exp = exp
      self.nonce = nonce
      self.authTime = authTime
      self.iss = iss
      self.iat = iat
      self.jti = jti
   }

   public func verify(using signer: JWTSigner) throws {
       try exp.verifyNotExpired()
   }

}
