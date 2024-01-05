import Vapor
import VaporOAuth

extension OAuthUser: SessionAuthenticatable {

   /// Store UserID (UUID) as sessionID
   public var sessionID: String { self.id ?? "" }

}

extension OAuthUser {
   
   var createdAt: Date? {
      get { return extend.get(\OAuthUser.createdAt, default: nil) }
      set { extend.set(\OAuthUser.createdAt, to: newValue) }
   }

}


