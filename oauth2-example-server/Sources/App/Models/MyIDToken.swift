import Fluent
import Vapor
import VaporOAuth
import JWTKit

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


   func verify(using signer: JWTKit.JWTSigner) throws {
      //return try app.jwt.signers.sign(payload)

#if DEBUG
      print("\n-----------------------------")
      print("MyIDToken() \(#function)")
      print("-----------------------------")
      print("signer: \(signer)")
      print("-----------------------------")
#endif

   }

   static let schema = "id_token"

   @ID(key: .id)
   var id: UUID?

   @Field(key: "jti")
   var jti: String

   @Field(key: "iss")
   var iss: String

   @Field(key: "sub")
   var sub: String

   var aud: [String] {
      get {
         let aud = _aud
         let audArray = aud.split(separator: ",")
         return audArray.map(String.init)
      }
      set {
         let newValue = newValue
         _aud = newValue.joined(separator: ",")
      }
   }

   @Field(key: "aud")
   var _aud: String

   @Field(key: "exp")
   var exp: Date

   @Field(key: "iat")
   var iat: Date

   @OptionalField(key: "nonce")
   var nonce: String?

   @Field(key: "auth_time")
   var authTime: Date?

   init() {}

   init(
      id: UUID? = nil,
      jti: String,
      iss: String,
      sub: String,
      aud: [String],
      exp: Date,
      iat: Date,
      nonce: String?,
      authTime: Date?
   ) {
      self.id = id
      self.jti = jti
      self.iss = iss
      self.sub = sub
      self.aud = aud
      self.exp = exp
      self.iat = iat
      self.nonce = nonce
      self.authTime = authTime
   }

}
