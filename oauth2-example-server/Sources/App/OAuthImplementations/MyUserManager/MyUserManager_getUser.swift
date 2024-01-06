import Vapor
import VaporOAuth
import Fluent
import JWTKit

extension MyUserManager {

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
         // You can add your own customized properties as dictionary:
         extend: ["cookiePreferences":myUser.cookiePreferences?.rawValue ?? ""],
         updatedAt: myUser.updatedAt
      )

      return user

   }


}
