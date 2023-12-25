import Vapor
import VaporOAuth
import Fluent

extension OAuthUser: SessionAuthenticatable {
    public var sessionID: String { self.id ?? "" }

}


/*
extension OAuthUser: Model {

   public static let schema = "user"

   struct Mapper {

      @ID(key: .id)
      static var id: UUID?

      @Field(key: "password")
      static var password: String

      @Field(key: "username")
      static var username: String

      @OptionalField(key: "email_address")
      static var emailAddress: String?

   }

   public var id: String? {
      get {
         return Mapper.id?.uuidString
      }
      set(newValue) {
         if let newValue {
            Mapper.id = UUID(uuidString: newValue)
         }
      }
   }

   var password: String {
      get {
         return Mapper.password
      }
      set(newValue) {
         Mapper.password = newValue
      }
   }

   var username: String {
      get {
         return Mapper.username
      }
      set(newValue) {
         Mapper.username = newValue

      }
   }

   public var emailAddress: String? {
      get {
         return Mapper.emailAddress
      }
      set(newValue) {
         if let newValue {
            Mapper.emailAddress = newValue
         }

      }
   }

   public convenience init() {
      self.init(
         username: Mapper.username,
         emailAddress: Mapper.emailAddress,
         password: Mapper.password
      )

   }

 }

extension OAuthUser: ModelSessionAuthenticatable {}

extension OAuthUser: ModelCredentialsAuthenticatable {}

extension OAuthUser: ModelAuthenticatable {

   public static var usernameKey = \OAuthUser.Mapper.$username
   public static var passwordHashKey = \OAuthUser.Mapper.$password

   public func verify(password: String) throws -> Bool {
      try Bcrypt.verify(password, created: self.password)
   }
}


*/
