import Vapor
import Leaf

extension Controller {

   func home(_ request: Request) async throws -> View {
      return try await request.view.render("index")
   }

}
