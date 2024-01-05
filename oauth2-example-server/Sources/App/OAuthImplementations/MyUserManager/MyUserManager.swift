import Vapor
import VaporOAuth
import Fluent
import JWT

/// Retrieve username in Token introspection
final class MyUserManager: UserManager {

   let app: Application

   // ----------------------------------------------------------

   init(app: Application) {
      self.app = app
   }

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

   // ----------------------------------------------------------

   /// Retrieve username in Introspection
   func getUser(userID: String) async throws -> VaporOAuth.OAuthUser? {

      guard
         let uuid = UUID(uuidString: userID)
      else {
         throw(Abort(.badRequest, reason: "userID not valid UUID"))
      }

      guard
         let myUser = try await MyUser
            .query(on: app.db)
            .filter(\.$id == uuid)
            .first()
      else {
         return nil
      }

      let user = OAuthUser(
         userID: myUser.id?.uuidString,
         username: myUser.username,
         emailAddress: myUser.emailAddress,
         password: "",
         name: myUser.name,
         givenName: myUser.givenName,
         familyName: myUser.familyName,
         middleName: myUser.middleName,
         nickname: myUser.nickname,
         profile: myUser.profile,
         picture: myUser.picture,
         website: myUser.website,
         gender: myUser.gender,
         birthdate: myUser.birthdate,
         zoneinfo: myUser.zoneinfo,
         locale: myUser.locale,
         phoneNumber: myUser.phoneNumber,
         updatedAt: myUser.updatedAt
      )

      // Be aware:
      // Extended properties are not exported
      user.createdAt = myUser.createdAt
      print(user.createdAt)

      return user

   }


}
