import Fluent
import VaporOAuth
import Vapor

final class MyResourceServer: Model, Content {

   static let schema = "resource_servers"

   @ID(key: .id)
   var id: UUID?

   // Username must be unique
   @Field(key: "username")
   var username: String

   @Field(key: "password")
   var password: String

   init() {}

   init(
      id: UUID? = nil,
      username: String,
      password: String
   ) {
      self.id = id
      self.username = username
      self.password = password
   }

   func verify(password: String) throws -> Bool {
      try Bcrypt.verify(password, created: self.password)
   }
   
}
