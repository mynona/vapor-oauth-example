import JWTKit

public struct Payload_RefreshToken: JWTPayload {

   public var id: String?
   public var jti: String
   public var clientID: String
   public var userID: String?
   public var scopes: String?
   public var exp: Date
   public var issuer: String?
   public var issuedAt: Date?

   enum CodingKeys: String, CodingKey {
      case id = "id"
      case jti = "jti" // unique token id
      case clientID = "clientID" // audience
      case userID = "userID" // subject
      case scopes = "_scopes"
      case exp = "exp" // expiration
      case issuer = "iss" // issuer
      case issuedAt = "iat" // issuing date
   }

   init(
      id: String?,
      jti: String,
      clientID: String,
      userID: String? = nil,
      scopes: String? = nil,
      exp: Date,
      issuer: String?,
      issuedAt: Date?
   ) {
      self.id = id
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
