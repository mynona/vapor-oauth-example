import Vapor
import VaporOAuth
import Fluent

extension OAuthUser: SessionAuthenticatable {
    public var sessionID: String { self.id ?? "" }
}



/*
extension OAuthUser: Model {

   

 public static let schema = "user"

   struct Properties {
           static let username = "username"
           static let emailAddress = "email_address"
           static let password = "password"
       }



 public convenience init(
   let username = try
   username: String,
   password: String
 )


 }
*/

