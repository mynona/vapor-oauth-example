import Vapor
import Leaf

extension Controller {

   func unauthorized(_ request: Request) async throws -> Response {

      let view = try await request.view.render(
         "unauthorized"
      )

      return try await view.encodeResponse(for: request)

   }

}
