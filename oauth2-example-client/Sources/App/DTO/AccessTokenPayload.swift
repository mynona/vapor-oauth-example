import JWTKit

public struct JWT_AccessTokenPayload: JWTPayload {

   enum CodingKeys: String, CodingKey {
      case tokenString = "jti" // unique token id
      case clientID = "aud" // audience
      case userID = "sub" // subject
      case scopes = "scopes"
      case expiryTime = "exp" // expiration
      case issuer = "iss" // issuer
      case issuedAt = "iat" // issuing date
   }

   public var tokenString: String
   public var clientID: String
   public var userID: String?
   public var scopes: [String]?
   public var expiryTime: Date
   public var issuer: String
   public var issuedAt: Date

   init(tokenString: String, 
        clientID: String,
        userID: String? = nil,
        scopes: [String]? = nil,
        expiryTime: Date,
        issuer: String,
        issuedAt: Date
   ) {
      self.tokenString = tokenString
      self.clientID = clientID
      self.userID = userID
      self.scopes = scopes
      self.expiryTime = expiryTime
      self.issuer = issuer
      self.issuedAt = issuedAt
   }

   public func verify(using signer: JWTSigner) throws {
       try expiryTime.verifyNotExpired()
   }

}
