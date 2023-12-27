import Fluent
import VaporOAuth
import Vapor
import JWT

/// JWT
///
/// - sub (subject): Subject of the JWT (the user)
/// - exp (expiration time): Time after which the JWT expires
/// - jti (JWT ID): Unique identifier; can be used to prevent the JWT from being replayed (allows a token to be used only once
/// - iss (issuer): Issuer of the JWT
/// - aud (audience): Client for which the JWT is intended
/// - iat (issued at time): Time at which the JWT was issued; can be used to determine age of the JWT
///
///  Note: As we use property wrappers we must use customized encoders and decoders. The values will be decoded to _client_id instead of client_id. As we only need to decode the jti (tokenString) for further usage, a correct mapping back to 'jti' is done only for this value.
///   https://www.hackingwithswift.com/books/ios-swiftui/adding-codable-conformance-for-published-properties
///
final class MyAccessToken: Model, VaporOAuth.AccessToken, Content, Codable, IssuedAtClaim {

   static let schema = "access_token"

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

   @Field(key: "expiry_time")
   var expiryTime: Date


   // Additional properties for the token generation
   var issuer: String  = "OAuth Provider"

   enum CodingKeys: CodingKey {
      case sub
      case exp
      case jti
      case iss
      case aud
      case iat
   }


   // Decoded tokenString to jti
   var jti = String()

   // Encode and decode to the correct claims

   required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      userID = try container.decode(String.self, forKey: .sub)
      expiryTime = try container.decode(Date.self, forKey: .exp)
      if let tokenString = try container.decodeIfPresent(String.self, forKey: .jti) {
         self.jti = tokenString
      }
      issuer = try container.decode(String.self, forKey: .iss)
      clientID = try container.decode(String.self, forKey: .aud)
   }

   func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(userID, forKey: .sub)
      try container.encode(expiryTime, forKey: .exp)
      try container.encode(tokenString, forKey: .jti)
      try container.encode(issuer, forKey: .iss)
      try container.encode(clientID, forKey: .aud)
      try container.encode(iat, forKey: .iat)
   }

   init() {}

   init(id: UUID? = nil,
        tokenString: String,
        clientID: String,
        userID: String? = nil,
        scopes: [String]? = nil,
        expiryTime: Date
   ) {
      self.id = id
      self.tokenString = tokenString
      self.clientID = clientID
      self.userID = userID
      self.scopes = scopes
      self.expiryTime = expiryTime
   }
}


