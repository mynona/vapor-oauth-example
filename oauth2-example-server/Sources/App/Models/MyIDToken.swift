import Fluent
import Vapor
import VaporOAuth

/// IDToken
/// - Parameters:
///   - authTime: (auth_time) time at which the user was authenticated, specified as the number of seconds sinceJanuary 1, 1970, 00:00:00 UtC to the time of authentication.
///   - issuer: (iss) Issuer of the ID Token, identified in URL format. The issuer is typically the OpenID Provider. The “iss” claim should not include URL query or fragment components.
///   - subject: (sub) Unique (within the OpenID Provider), case-sensitive string identifier for the authenticated user or subject entity, no more than 255 ASCII characters long. The identifier in the subclaim should never be reassigned to a new user or entity.
///   - audience: (aud) Client ID of the relying party (application) for which the ID Token is intended. May be a single, case-sensitive string or an array of the same if there are multiple audiences.
///   - expiration: (exp) Expiration time for the ID Token, specified as the number of seconds since January 1, 1970, 00:00:00 UTC to the time of token expiration. Applications must consider an ID Token invalid after this time, with a few minutes of tolerance allowed for clock skew.
///   - issuedAt: (iat) Time at which the ID Token was issued, specified as the number of seconds since January 1, 1970, 00:00:00 UTC to the time of ID Token issuance.
///
final class MyIDToken: Model, VaporOAuth.IDToken {

   static let schema = "id_token"

   @ID(key: .id)
   var id: UUID?

   @Field(key: "token_string")
   var tokenString: String

   @Field(key: "issuer")
   var issuer: String

   @Field(key: "subject")
   var subject: String

   var audience: [String] {
      get {
         let audience = _audience
         let audienceArray = audience.split(separator: ",")
         return audienceArray.map(String.init)
      }
      set {
         let newValue = newValue
         _audience = newValue.joined(separator: ",")
      }
   }

   @Field(key: "audience")
   var _audience: String

   @Field(key: "expiration")
   var expiration: Date

   @Field(key: "issued_at")
   var issuedAt: Date

   @OptionalField(key: "nonce")
   var nonce: String?

   @Field(key: "auth_time")
   var authTime: Date?

   init() {}

   init(
      id: UUID? = nil,
      tokenString: String,
      issuer: String,
      subject: String,
      audience: [String],
      expiration: Date,
      issuedAt: Date,
      nonce: String?,
      authTime: Date?
   ) {
      self.id = id
      self.tokenString = tokenString
      self.issuer = issuer
      self.subject = subject
      self.audience = audience
      self.expiration = expiration
      self.issuedAt = issuedAt
      self.nonce = nonce
      self.authTime = authTime
   }

}
