import Vapor
import Fluent

final class Author: Model, Content, Encodable {

   static let schema = "author"

   // Primary key must be named id (Fluent requirement)
   @ID(key: .id) var id: UUID?

   // Attribute(s)
   @Field(key: "first_name") var first_name: String
   @Field(key: "last_name") var last_name: String
   @Field(key: "password") var password: String
   @Field(key: "username") var username: String
   @Enum(key: "scope") var scope: AuthorScope

   init() { }

   init(
      id: UUID? = nil,
      first_name: String,
      last_name: String,
      username: String,
      password: String,
      scope: AuthorScope
   ) {
      // Primary key
      self.id = id
      // Attributes
      self.first_name = first_name
      self.last_name = last_name
      self.username = username
      self.password = password
      self.scope = scope
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


