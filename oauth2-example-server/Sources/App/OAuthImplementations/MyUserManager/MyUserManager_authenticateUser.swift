import Vapor
import VaporOAuth
import Fluent
import JWTKit


extension MyUserManager {

   /// User login
   func authenticateUser(username: String, password: String) async throws -> String? {

      guard
         let author = try await MyUser
            .query(on: app.db)
            .filter(\.$username == username)
            .first(),
         let uuidString = author.id?.uuidString
      else {
         return nil
      }

      guard
         try author.verify(password: password)
      else {
         return nil
      }

      return uuidString

   }



}
