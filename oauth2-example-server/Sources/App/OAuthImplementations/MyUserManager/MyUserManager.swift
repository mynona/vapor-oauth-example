import Vapor
import VaporOAuth
import Fluent
import JWT

final class MyUserManager: UserManager {

   let app: Application

   init(app: Application) {
      self.app = app
   }

}
