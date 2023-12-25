import Vapor
import Fluent

final class Author: Model, Content, Encodable {

   static let schema = "author"

   // Primary key must be named id (Fluent requirement)
   @ID(key: .id) var id: UUID?

   // Attribute(s)
   @Field(key: "first_name") 
   var first_name: String

   @Field(key: "last_name") 
   var last_name: String

   @Field(key: "password") 
   var password: String

   @Field(key: "username") 
   var username: String

   var scopes: [String] {
      get {
         let scopesArray = _scopes.split(separator: ",")
         return scopesArray.map(String.init)
      }
      set {
         _scopes = newValue.joined(separator: ",")
      }
   }

   @Field(key: "scopes")
   var _scopes: String

   @Timestamp(key: "created_at", on: .create, format: .default) 
   var created_at: Date?

   @Timestamp(key: "updated_at", on: .update, format: .default)
   var updated_at: Date?

   init() { }

   init(
      id: UUID? = nil,
      first_name: String,
      last_name: String,
      username: String,
      password: String,
      scopes: [String]
   ) {
      // Primary key
      self.id = id
      // Attributes
      self.first_name = first_name
      self.last_name = last_name
      self.username = username
      self.password = password
      self.scopes = scopes
   }

}

// WEB AUTHENTICATION ------------------------------------------

// Save and retrieve user as part of a session
extension Author: ModelSessionAuthenticatable {}

// Authenticate users with username and password when they log in
extension Author: ModelCredentialsAuthenticatable {}

extension Author: ModelAuthenticatable {

   static let usernameKey = \Author.$username
   static let passwordHashKey = \Author.$password

   func verify(password: String) throws -> Bool {
      try Bcrypt.verify(password, created: self.password)
   }
}


