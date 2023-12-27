import Vapor

public protocol IssuedAtClaim: Codable { }

public extension IssuedAtClaim {

   /// When the JWT is created iat will be populated with the current date
   var iat: Date {
         return Date()
   }

}


