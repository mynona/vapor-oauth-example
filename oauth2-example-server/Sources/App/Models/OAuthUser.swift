import Vapor
import VaporOAuth

extension OAuthUser: SessionAuthenticatable {

   /// Store UserID (UUID) as sessionID
   public var sessionID: String { self.id ?? "" }

}




