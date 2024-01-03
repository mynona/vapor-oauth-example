import Fluent
import Vapor
import VaporOAuth

/// Refresh Token
///
/// - Parameters:
///   - id: unique identifier in the database
///   - token_string: token itself
///   - client_id: client for whom the token was created
///   - user_id: user for whom the token was created
///   - scopes: scopes that can be granted with this refresh token
///   - expiry_time: time when the token expires
///
final class MyRefreshToken: Model, VaporOAuth.RefreshToken, Content {

   static let schema = "refresh_token"

   @ID(key: .id)
   var id: UUID?
   
   @Field(key: "jti")
   var jti: String

   @Field(key: "client_id")
   var clientID: String
   
   @Field(key: "user_id")
   var userID: String?

   var scopes: [String]? {
      get {
         guard let scopes = _scopes else { return nil }
         let scopesArray = scopes.split(separator: ",")
         return scopesArray.map(String.init)
      }
      set {
         guard let newValue = newValue else {
            _scopes = nil
            return
         }
         _scopes = newValue.joined(separator: ",")
      }
   }
   
   @Field(key: "scopes")
   var _scopes: String?

   @Field(key: "exp")
   var exp: Date

   init() {}
   
   init(
      id: UUID? = nil,
      jti: String,
      clientID: String,
      userID: String? = nil,
      scopes: [String]? = nil,
      exp: Date
   ) {
      self.id = id
      self.jti = jti
      self.clientID = clientID
      self.userID = userID
      self.scopes = scopes
      self.exp = exp
   }
}
