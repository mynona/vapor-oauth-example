import Vapor
import Foundation
import Crypto

extension Controller {

   /// Starts Authentication Grant Flow
   ///
   func clientLogin(_ request: Request) async throws -> Response {

      return try await OAuthHelper.requestAuthorizationCode(request)

   }

}
