import Vapor
import VaporOAuth

func routes(_ app: Application) throws {

   let passwordProtected = app.grouped(UserModel.credentialsAuthenticator())
   passwordProtected.post("oauth", "login", use: Controller().login)
   passwordProtected.get("oauth", "login-forward", use: Controller().loginForward)
   passwordProtected.get("oauth", "logout", use: Controller().logout)

}
