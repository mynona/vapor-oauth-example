import Vapor
import VaporOAuth

extension OAuthUser: SessionAuthenticatable {
   
   public var sessionID: String { self.id ?? "" }
   
}
