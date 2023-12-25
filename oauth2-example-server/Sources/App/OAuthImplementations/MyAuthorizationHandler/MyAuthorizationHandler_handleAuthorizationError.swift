import Vapor
import VaporOAuth
import Leaf

extension MyAuthorizationHandler {

   /// - Throws: invalidClientID
   /// - Throws: confidentialClientTokenGrant
   /// - Throws: invalidRedirectURI
   /// - Throws: httpRedirectURI
   func handleAuthorizationError(_ errorType: AuthorizationError) async throws -> Response {

#if DEBUG
      print("\n-----------------------------")
      print("MyAuthorizeHandler() \(#function)")
      print("-----------------------------")
      print("Authorization error")
      print("\(errorType)")
      print("-----------------------------")
#endif

      return Response(status: .unauthorized, body: .init(string: errorType.localizedDescription))
   }


}
