import Fluent
import Vapor
import VaporOAuth

final class LiveRefreshToken: Model, RefreshToken {
    static let schema = "refresh_tokens"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "token_string")
    var tokenString: String

    @Field(key: "client_id")
    var clientID: String

    @Field(key: "user_id")
    var userID: String?

    var scopes: [String]? {
        get {
            guard let scopes = _scopes else { return nil }
            let scopesArray = scopes.split(separator: ",")
            return scopesArray.map(String.init)
        }
        set {
            guard let newValue = newValue else {
                _scopes = nil
                return
            }
            _scopes = newValue.joined(separator: ",")
        }
    }

    @Field(key: "scopes")
    var _scopes: String?

    init() {}

    init(id: UUID? = nil, tokenString: String, clientID: String, userID: String? = nil, scopes: [String]? = nil) {
        self.id = id
        self.tokenString = tokenString
        self.clientID = clientID
        self.userID = userID
        self.scopes = scopes
    }
}
