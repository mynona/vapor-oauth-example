import Vapor
import VaporOAuth
import Fluent

extension OAuthUser: SessionAuthenticatable {
    public var sessionID: String { self.id ?? "" }
}

