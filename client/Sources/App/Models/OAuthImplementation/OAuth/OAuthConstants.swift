import Vapor

struct OAuthConstants {

   static let oAuthProvider = try! getEnvironmentVariable(for: "OAUTH_PROVIDER")
   static let callbackURL = try! getEnvironmentVariable(for: "OAUTH_CALLBACK_URL")
   static let clientURL = try! getEnvironmentVariable(for: "OAUTH_CLIENT_URL")
   static let stateVerifier: String = "\([UInt8].random(count: 32).hex)"
   static let codeVerifier = "\([UInt8].random(count: 32).hex)"
   static let nonce = "\([UInt8].random(count: 32).hex)"
   static let maxAgeAccessToken = Int(try! getEnvironmentVariable(for: "OAUTH_ACCESS_TOKEN_MAX_AGE"))
   static let maxAgeRefreshToken = Int(try! getEnvironmentVariable(for: "OAUTH_REFRESH_TOKEN_MAX_AGE"))
   static let maxAgeIDToken = Int(try! getEnvironmentVariable(for: "OAUTH_ID_TOKEN_MAX_AGE"))
   static let serverSessionCookieName = "oauth-session"
   static let resourceServerUsername = try! getEnvironmentVariable(for: "OAUTH_RESOURCE_SERVER_USERNAME")
   static let resourceServerPassword = try! getEnvironmentVariable(for: "OAUTH_RESOURCE_SERVER_PASSWORD")
   static let clientID = try! getEnvironmentVariable(for: "OAUTH_CLIENT_ID")
   static let clientSecret = try! getEnvironmentVariable(for: "OAUTH_CLIENT_SECRET")
   
   static func getEnvironmentVariable(for environmentVariable: String) throws -> String {

      guard
         let value = Environment.get(environmentVariable)
      else {
         throw Abort(.internalServerError, reason: "Could not load environmental variable for key '\(environmentVariable).")
      }

      return value

   }

}


