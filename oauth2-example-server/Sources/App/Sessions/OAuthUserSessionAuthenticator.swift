import Vapor
import VaporOAuth
import Fluent

public struct OAuthUserSessionAuthenticator: AsyncSessionAuthenticator {
    public typealias User = OAuthUser

    public func authenticate(sessionID: String, for request: Vapor.Request) async throws {

#if DEBUG
      print("\n-----------------------------")
      print("OAuthUserSessionAuthenticator().authenticate()")
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
      print("OAuthUserSessionAuthenticator().authenticate()")
      print("-----------------------------")
      print("sessionID could not be converted to UUID")
      print("-----------------------------")
#endif

          return
       }

       // Query database for user

       let author = try await Author
          .query(on: request.db)
          .filter(\.$id == uuid)
          .first()

#if DEBUG
      print("\n-----------------------------")
      print("OAuthUserSessionAuthenticator().authenticate()")
      print("-----------------------------")
      print("User: \(author)")
      print("-----------------------------")
#endif

       if let author {

          let user = OAuthUser(
            userID: author.id?.uuidString,
            username: author.username,
            emailAddress: "",
            password: author.password
          )
          request.auth.login(user)

       }

    }
}
