import Vapor
import VaporOAuth
import Fluent
import JWT

final class MyUserManager: UserManager {

   let app: Application

   // ----------------------------------------------------------

   init(app: Application) {
      self.app = app
   }

   func authenticateUser(username: String, password: String) async throws -> String? {

      guard
         let author = try await Author
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

   // ----------------------------------------------------------

   /// Needed to retrieve user for token introspection
   func getUser(userID: String) async throws -> VaporOAuth.OAuthUser? {

      guard
         let uuid = UUID(uuidString: userID)
      else {
         throw(Abort(.badRequest, reason: "userID not valid UUID"))
      }

      guard
         let author = try await Author
            .query(on: app.db)
            .filter(\.$id == uuid)
            .first()
      else {
         return nil
      }

      let user = OAuthUser(
         userID: author.id?.uuidString,
         username: author.username,
         emailAddress: "",
         password: author.password
      )
      return user

   }


}
