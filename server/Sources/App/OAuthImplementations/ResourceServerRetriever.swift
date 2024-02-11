import Vapor
import VaporOAuth
import Fluent

final class ResourceServerRetriever: VaporOAuth.ResourceServerRetriever {
    let app: Application
    
    init(app: Application) {
        self.app = app
    }
    
    func getServer(_ username: String) async throws -> VaporOAuth.OAuthResourceServer? {

#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("Called with parameters:")
      print("username: \(username)")
      print("-----------------------------")
#endif

        // Validate the input
        guard !username.isEmpty else {
            // Optionally log this as a warning or throw an exception
            throw Abort(.badRequest, reason: "Username is empty")
        }
        
        // Fetch the server from the database
        guard let server = try await ResourceServer
            .query(on: app.db)
            .filter(\.$username == username)
            .first() else {
                // Log the event of not finding the server or handle accordingly
                return nil
        }

       let encryptionKey = "i+/61SLnMj2A25nB6sVJnLtHkJQQNMDubwoCbx83bsk="
       let password = try server.getPassword(decryptionKey: encryptionKey)

        // Create and return the OAuthResourceServer object
        return OAuthResourceServer(username: server.username, password: password)
    }
}
