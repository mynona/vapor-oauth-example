import JWTKit

public struct PayloadRefreshToken: JWTPayload {

   public var jti: String
   public var clientID: String
   public var userID: String?
   public var scopes: String?
   public var exp: Date
   public var issuer: String?
   public var issuedAt: Date?

   enum CodingKeys: String, CodingKey {
      case jti = "jti" // unique token id
      case clientID = "aud" // audience
      case userID = "sub" // subject
      case scopes = "scopes"
      case exp = "exp" // expiration
      case issuer = "iss" // issuer
      case issuedAt = "iat" // issuing date
   }

   init(
      jti: String,
      clientID: String,
      userID: String? = nil,
      scopes: String? = nil,
      exp: Date,
      issuer: String?,
      issuedAt: Date?
   ) {
      self.jti = jti
      self.clientID = clientID
      self.userID = userID
      self.scopes = scopes
      self.exp = exp
      self.issuer = issuer
      self.issuedAt = issuedAt
   }

   public func verify(using signer: JWTSigner) throws {
       try exp.verifyNotExpired()
   }

}
