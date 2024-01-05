import Vapor
import VaporOAuth
import Fluent

public struct OAuthUserSessionAuthenticator: AsyncSessionAuthenticator {
    public typealias User = OAuthUser

    public func authenticate(sessionID: String, for request: Vapor.Request) async throws {

#if DEBUG
      print("\n-----------------------------")
      print("OAuthUserSessionAuthenticator() \(#function)")
      print("-----------------------------")
      print("User UUID is stored as sessionID")
      print("sessionID: \(sessionID)")
      print("-----------------------------")
#endif

       guard
         let uuid = UUID(uuidString: sessionID)
       else {

#if DEBUG
      print("\n-----------------------------")
      print("OAuthUserSessionAuthenticator() \(#function)")
      print("-----------------------------")
      print("sessionID could not be converted to UUID")
      print("-----------------------------")
#endif

          return
       }

       // Query database for user
       let myuser = try await MyUser
          .query(on: request.db)
          .filter(\.$id == uuid)
          .first()

#if DEBUG
      print("\n-----------------------------")
      print("OAuthUserSessionAuthenticator() \(#function)")
      print("-----------------------------")
      print("User: \(myuser)")
      print("-----------------------------")
#endif

       if let myuser {

          let user = OAuthUser(
            userID: myuser.id?.uuidString,
            username: myuser.username,
            emailAddress: myuser.emailAddress,
            password: myuser.password,
            name: myuser.name,
            givenName: myuser.givenName,
            familyName: myuser.familyName,
            middleName: myuser.middleName,
            nickname: myuser.nickname,
            profile: myuser.profile,
            picture: myuser.picture,
            website: myuser.website,
            gender: myuser.gender,
            birthdate: myuser.birthdate,
            zoneinfo: myuser.zoneinfo,
            locale: myuser.locale,
            phoneNumber: myuser.phoneNumber,
            updatedAt: myuser.updatedAt
          )
          request.auth.login(user)
          request.session.authenticate(user)
       }

    }
}
