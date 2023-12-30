import JWTKit

public struct OAuth_IDTokenPayload: JWTPayload {

   enum CodingKeys: String, CodingKey {
      case subject = "sub"
      case audience = "aud"
      case expiration = "exp"
      case nonce = "nonce"
      case authTime = "auth_time" // time when authentication occured
      case issuer = "iss"
      case issuedAt = "iat"
      case tokenString = "jti"
   }

   public var subject: String
   public var audience: [String]
   public var expiration: Date
   public var nonce: String?
   public var authTime: Date?
   public var issuer: String
   public var issuedAt: Date
   public var tokenString: String

   init(subject: String,
        audience: [String],
        expiration: Date,
        nonce: String?,
        authTime: Date?,
        issuer: String,
        issuedAt: Date,
        tokenString: String
   ) {
      self.subject = subject
      self.audience = audience
      self.expiration = expiration
      self.nonce = nonce
      self.authTime = authTime
      self.issuer = issuer
      self.issuedAt = issuedAt
      self.tokenString = tokenString
   }

   public func verify(using signer: JWTSigner) throws {
       try expiration.verifyNotExpired()
   }

}
