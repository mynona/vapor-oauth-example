import Vapor
import VaporOAuth
import Fluent

extension OAuthUser: SessionAuthenticatable {
    public var sessionID: String { self.id ?? "" }
}








/*

 // Not working yet -> need to figure out how to do keypaths for an extended model
 
import Vapor
import Fluent
import VaporOAuth

extension OAuthUser: Model, Content {

   public static let schema = "author"

   struct Properties {
      static let username: String = "username"
      static let emailAddress: String = "email_address"
      static let password: String = "password"
   }

   public convenience init() {
      let username = username
      let emailAddress = emailAddress
      let password = password
      self.init(username: username, emailAddress: emailAddress, password: password)
   }

}

// WEB AUTHENTICATION ------------------------------------------

// Save and retrieve user as part of a session
extension OAuthUser: ModelSessionAuthenticatable {}

/*
extension OAuthUser: ModelCredentialsAuthenticatable {

   static let usernameKey = \OAuthUser.$username
   static let passwordHashKey = \OAuthUser.$password

   public func verify(password: String) throws -> Bool {
      try Bcrypt.verify(password, created: self.password)
   }
}
 */

 */

