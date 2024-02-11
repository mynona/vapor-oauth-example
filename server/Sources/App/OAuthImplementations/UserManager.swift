import Vapor
import VaporOAuth
import Fluent
import JWTKit

final class UserManager: VaporOAuth.UserManager {

   let app: Application
   
   init(app: Application) {
      self.app = app
   }
   
   /// User login
   func authenticateUser(username: String, password: String) async throws -> String? {

#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("Called with parameters:")
      print("username: \(username)")
      print("password: \(password)")
      print("-----------------------------")
#endif

      // Check if the username is valid
      guard !username.isEmpty else {
         // Optionally log this as a warning or throw an exception
         throw Abort(.badRequest, reason: "Username is empty")
      }
      
      // Check if the password is valid
      guard !password.isEmpty else {
         // Optionally log this as a warning or throw an exception
         throw Abort(.badRequest, reason: "Password is empty")
      }
      
      // Fetch the user from the database
      guard let user = try await UserModel
         .query(on: app.db(.main))
         .filter(\.$username == username)
         .first() else {
         // Log the event of not finding the user or handle accordingly
         return nil
      }
      
      // Verify the password
      guard try user.verify(password: password) else {
         // Log the failed login attempt or handle accordingly
         return nil
      }
      
      // Return the user's UUID string
      return user.id?.uuidString
   }
   
   /// Retrieve username in Introspection
   func getUser(userID: String) async throws -> VaporOAuth.OAuthUser? {

#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("Called with parameters:")
      print("userID: \(userID)")
      print("-----------------------------")
#endif

      guard let uuid = UUID(uuidString: userID) else {
         throw Abort(.badRequest, reason: "userID not valid UUID")
      }
      
      guard let myUser = try await UserModel
         .query(on: app.db(.main))
         .filter(\.$id == uuid)
         .first() else {
         // Optionally, log the event of not finding the user
         // Use a proper logging mechanism here
         return nil
      }
      
      // Construct OAuthUser without exposing sensitive data like password
      return OAuthUser(
         userID: myUser.id?.uuidString,
         username: myUser.username,
         emailAddress: myUser.emailAddress,
         password: "", // Exclude the password
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
         extend: ["cookiePreferences": myUser.cookiePreferences?.rawValue ?? ""],
         updatedAt: myUser.updatedAt
      )
   }

   /// Return only the scopes that are valid for this client
   ///
   func getUserClient(userID: String, clientID: String) async throws -> VaporOAuth.OAuthUser? {

#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("Called with parameters:")
      print("userID: \(userID)")
      print("clientID: \(clientID)")
      print("-----------------------------")
#endif

      guard let uuid = UUID(uuidString: userID) else {
         throw Abort(.badRequest, reason: "userID not valid UUID")
      }

      guard
         let user = try await UserModel
            .query(on: app.db(.main))
            .filter(\.$id == uuid)
            .first()
      else {
         // Optionally, log the event of not finding the user
         // Use a proper logging mechanism here
         return nil
      }

      guard
         let client = try await Client
            .query(on: app.db(.main))
            .filter(\.$clientId == clientID)
            .first(),
         let scopes = client.scopes
      else {
         // Optionally, log the event of not finding the client
         // Use a proper logging mechanism here
         return nil
      }

      var oAuthUser: OAuthUser?
      if scopes.contains("email") {
         oAuthUser = OAuthUser(
            userID: user.id?.uuidString,
            username: user.username,
            emailAddress: user.emailAddress,
            password: "",
            emailVerified: user.emailAddressVerified
            )
      }
      else {
         oAuthUser = OAuthUser(
            userID: user.id?.uuidString,
            username: user.username,
            emailAddress: "",
            password: "")
      }

      if scopes.contains("phone") {
         oAuthUser?.phoneNumber = user.phoneNumber
         oAuthUser?.phoneNumberVerified = user.phoneNumberVerified
      }

      if scopes.contains("profile") {
         oAuthUser?.name = user.name 
         oAuthUser?.familyName = user.familyName
         oAuthUser?.givenName = user.givenName
         oAuthUser?.middleName = user.middleName
         oAuthUser?.nickname = user.nickname
         oAuthUser?.preferredUserName = user.preferredUsername
         oAuthUser?.profile = user.profile
         oAuthUser?.picture = user.picture
         oAuthUser?.website = user.website
         oAuthUser?.gender = user.gender
         oAuthUser?.birthdate = user.birthdate
         oAuthUser?.zoneinfo = user.zoneinfo
         oAuthUser?.locale = user.locale
         oAuthUser?.updatedAt = user.updatedAt
      }

      if scopes.contains("address") {
         let address = Address(
            formatted: user.formatted,
            streetAddress: user.streetAddress,
            locality: user.locality,
            region: user.region,
            postalCode: user.postalCode,
            country: user.country
         )
         oAuthUser?.address = address
      }

      // Customized claims
      if scopes.contains("custom") {

         var cookiePreferences = ""
         if let temp = user.cookiePreferences?.rawValue.uppercased() {
            cookiePreferences = temp
         }

         var lastLogin = ""
         if let temp = user.lastLogin {
            //lastLogin = formatter.string(from: temp)
            lastLogin = String(temp.timeIntervalSince1970)
         }

         var validatedAt = ""
         if let temp = user.validatedAt {
            validatedAt = String(temp.timeIntervalSince1970)
         }

         var oAuthProvider = ""
         if let temp = user.oauthProvider?.rawValue.uppercased() {
            oAuthProvider = temp
         }

         var federated = "false"
         if let temp = user.federated {
            federated = String(temp)
         }

         let roles = user.roles.joined(separator: " ")

         oAuthUser?.extend = [
            "cookiePreferences": cookiePreferences,
            "newsletter": "\(user.newsletter)",
            "blocked": "\(user.blocked)",
            "lastLogin": lastLogin,
            "validatedAt": validatedAt,
            "federated": federated,
            "oAuthProvider": oAuthProvider,
            "roles": roles,
            "numberOfLogins": "\(user.numberOfLogins)"
         ]
      }

      return oAuthUser

   }

}
