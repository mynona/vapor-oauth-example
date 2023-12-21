import Vapor
import VaporOAuth
import Leaf

struct LiveResourceServerRetriever: ResourceServerRetriever {

   func getServer(_ username: String) -> VaporOAuth.OAuthResourceServer? {

      return OAuthResourceServer(username: "test", password: "test")
   }

}

