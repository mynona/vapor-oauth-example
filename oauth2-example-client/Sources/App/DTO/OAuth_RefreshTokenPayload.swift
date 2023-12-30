import JWTKit

public struct OAuth_RefreshTokenPayload: JWTPayload {

   public var tokenString: String
   public var clientID: String
   public var userID: String?
   public var scopes: [String]?
   public var expiration: Date
   public var issuer: String
   public var issuedAt: Date

   enum CodingKeys: String, CodingKey {
      case tokenString = "jti" // unique token id
      case clientID = "aud" // audience
      case userID = "sub" // subject
      case scopes = "scopes"
      case expiration = "exp" // expiration
      case issuer = "iss" // issuer
      case issuedAt = "iat" // issuing date
   }

   init(
      tokenString: String,
      clientID: String,
      userID: String? = nil,
      scopes: [String]? = nil,
      expiration: Date,
      issuer: String,
      issuedAt: Date
   ) {
      self.tokenString = tokenString
      self.clientID = clientID
      self.userID = userID
      self.scopes = scopes
      self.expiration = expiration
      self.issuer = issuer
      self.issuedAt = issuedAt
   }

   public func verify(using signer: JWTSigner) throws {
       try expiration.verifyNotExpired()
   }

}
