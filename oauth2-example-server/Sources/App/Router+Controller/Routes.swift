import Vapor
import VaporOAuth

func Routes(_ app: Application) throws {

   let passwordProtected = app.grouped(Author.credentialsAuthenticator())
   passwordProtected.post("oauth", "login", use: Controller().signin)

}
