import Fluent
import VaporOAuth
import Vapor

extension OAuthFlowType: Content {}

/// Clients
///
/// - Parameters:
///   - id: unique identifier (uuid) in the database
///   - client_id: unique identifier of the client. separate from the id as the requirement for the client_id is to be as string value
///   - redirect_uri: allowed redirect uris for this client
///   - client_secret: client secret
///   - scopes: allowed scopes for this client
///   - confidential_client: An application that can securely store confidential secrets with which to authenticate itself to an authorization server or use another secure authentication mechanism for that purpose. Confidential clients typically execute primarily on a protected server.
///   - first_party: First-party applications are those controlled by the same organization or person who owns this authorization provider.
///   - grant_type: authorization_code
///
final class MyClient: Model, Content {

   static let schema = "client"

   @ID(key: .id)
   var id: UUID?

   // Username must be unique
   @Field(key: "client_id")
   var client_id: String

   var redirect_uris: [String]? {
      get {
         guard let redirect_uris = _redirect_uris else { return nil }
         let redirect_uris_Array = redirect_uris.split(separator: ",")
         return redirect_uris_Array.map(String.init)
      }
      set {
         guard let newValue = newValue else {
            _redirect_uris = nil
            return
         }
         _redirect_uris = newValue.joined(separator: ",")
      }
   }

   @OptionalField(key: "redirect_uris")
   var _redirect_uris: String?

   @OptionalField(key: "client_secret")
   var client_secret: String?

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

   @OptionalField(key: "scopes")
   var _scopes: String?

   // Confidential clients are applications that are able to securely authenticate with the authorization server, for example being able to keep their registered client secret safe.
   // Public clients are unable to use registered client secrets, such as applications running in a browser or on a mobile device.
   @OptionalField(key: "confidential_client")
   var confidential_client: Bool?

   // First-party applications are applications that the user recognizes as belonging to the same brand as the authorization server. For example, a bank publishing their own mobile application.
   @OptionalField(key: "first_party")
   var first_party: Bool?

   @Enum(key: "grant_type")
   var grant_type: OAuthFlowType

   init() {}

   init(
      id: UUID? = nil,
      client_id: String,
      redirect_uris: [String]?,
      client_secret: String?,
      scopes: [String]?,
      confidential_client: Bool?,
      first_party: Bool?,
      grant_type: OAuthFlowType
   ) {
      self.id = id
      self.client_id = client_id
      self.redirect_uris = redirect_uris
      self.client_secret = client_secret
      self.scopes = scopes
      self.confidential_client = confidential_client
      self.first_party = first_party
      self.grant_type = grant_type
   }

   // Note for real implementation:
   //
   // vapor/oauth: client_secret must be provided in plain text
   // therefore Bcrypt doesn't work as it is a one-way-hash
   // As we should never store plain text passwords in a database
   // this model needs to be extended with a cypher

}
