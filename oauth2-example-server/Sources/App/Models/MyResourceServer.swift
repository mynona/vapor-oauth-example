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

   // Note for real implementation:
   //
   // vapor/oauth: password must be provided in plain text
   // therefore Bcrypt doesn't work as it is a one-way-hash
   // As we should never store plain text passwords in a database
   // this model needs to be extended with a cypher

   /*
    func verify(password: String) throws -> Bool {
    try Bcrypt.verify(password, created: self.password)
    }
    */

}
