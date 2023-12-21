import Vapor

public struct SignInViewContext: Encodable {
   public let csrfToken: String

   init(
      csrfToken: String
   ) {
      self.csrfToken = csrfToken
   }
}

