import VaporOAuth
import Vapor
import Fluent

final class MyCodeManger: CodeManager {

   public let app: Application

   init(app: Application) {
      self.app = app
   }

   // Device Code flow not part of this example:

   func generateDeviceCode(userID: String, clientID: String, scopes: [String]?) async throws -> String { return "" }

   func getDeviceCode(_ deviceCode: String) async throws -> VaporOAuth.OAuthDeviceCode? { return nil }

   func deviceCodeUsed(_ deviceCode: VaporOAuth.OAuthDeviceCode) async throws { }


}
