import Fluent
import Vapor
import VaporOAuth

final class MyIDToken: Model, IDToken {

   static let schema = "id_token"

   @ID(key: .id)
   var id: UUID?

   @Field(key: "token_string")
   var tokenString: String

   @Field(key: "issuer")
   var issuer: String

   @Field(key: "subject")
   var subject: String

   @Field(key: "audience")
   var audience: [String]

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
