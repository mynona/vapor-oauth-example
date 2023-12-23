import Fluent
import VaporOAuth
import Vapor

final class MyAuthorizationCode: Model, Content {

   static let schema = "authorization_code"

   @ID(key: .id)
   var id: UUID?

   @Field(key: "code_id")
   var code_id: String

   @Field(key: "client_id")
   var client_id: String

   @Field(key: "redirect_uri")
   var redirect_uri: String

   @Field(key: "user_id")
   var user_id: String

   @Field(key: "expiry_date")
   var expiry_date: Date

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

   @OptionalField(key: "code_challenge")
   var code_challenge: String?

   @OptionalField(key: "code_challenge_method")
   var code_challenge_method: String?

   init() {}

   init(id: UUID? = nil,
        code_id: String,
        client_id: String,
        redirect_uri: String,
        user_id: String,
        expiry_date: Date,
        scopes: [String]?,
        code_challenge: String?,
        code_challenge_method: String?
   ) {
      self.id = id
      self.code_id = code_id
      self.client_id = client_id
      self.redirect_uri = redirect_uri
      self.user_id = user_id
      self.expiry_date = expiry_date
      self.scopes = scopes
      self.code_challenge = code_challenge
      self.code_challenge_method = code_challenge_method
   }
}
