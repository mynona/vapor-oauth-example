import Vapor
import VaporOAuth
import Fluent
import JWTKit

final class MyUserManager: UserManager {

   let app: Application

   init(app: Application) {
      self.app = app
   }

}
