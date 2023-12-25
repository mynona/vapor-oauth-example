import Vapor
import Fluent

final class Author: Model, Content, Encodable {

   static let schema = "author"

   // Primary key must be named id (Fluent requirement)
   @ID(key: .id) var id: UUID?

   @Field(key: "username")
   var username: String

   @Field(key: "password")
   var password: String

   @OptionalField(key: "given_name") // first name
   var givenName: String?

   @OptionalField(key: "family_name") // last name
   var familyName: String?

   @OptionalField(key: "middle_name")
   var middleName: String?

   @OptionalField(key: "nickname")
   var nickname: String?

   @OptionalField(key: "profile")
   var profile: String?

   @OptionalField(key: "picture")
   var picture: String?

   @OptionalField(key: "website")
   var website: String?

   @OptionalField(key: "gender")
   var gender: String?

   @OptionalField(key: "birthdate")
   var birthdate: String?

   @OptionalField(key: "zoneinfo")
   var zoneinfo: String?

   @OptionalField(key: "locale")
   var locale: String?

   @OptionalField(key: "phone_number")
   var phoneNumber: String?

   @Timestamp(key: "created_at", on: .create, format: .default)
   var created_at: Date?

   @Timestamp(key: "updated_at", on: .update, format: .default)
   var updated_at: Date?

   var scopes: [String] {
      get {
         let scopesArray = _scopes.split(separator: ",")
         return scopesArray.map(String.init)
      }
      set {
         _scopes = newValue.joined(separator: ",")
      }
   }

   @Field(key: "scopes")
   var _scopes: String

   init() { }

   init(
      id: UUID? = nil,
      username: String,
      password: String,
      givenName: String?,
      familyName: String?,
      middleName: String?,
      nickname: String?,
      profile: String?,
      picture: String?,
      website: String?,
      gender: String?,
      birthdate: String?,
      zoneinfo: String?,
      locale: String?,
      phoneNumber: String?,
      scopes: [String]
   ) {
      self.id = id
      self.username = username
      self.password = password
      self.givenName = givenName
      self.familyName = familyName
      self.middleName = middleName
      self.nickname = nickname
      self.profile = profile
      self.picture = picture
      self.website = website
      self.gender = gender
      self.birthdate = birthdate
      self.zoneinfo = zoneinfo
      self.locale = locale
      self.phoneNumber = phoneNumber
      self.scopes = scopes
   }

}

// WEB AUTHENTICATION ------------------------------------------

// Save and retrieve user as part of a session
extension Author: ModelSessionAuthenticatable {}

// Authenticate users with username and password when they log in
extension Author: ModelCredentialsAuthenticatable {}

extension Author: ModelAuthenticatable {

   static let usernameKey = \Author.$username
   static let passwordHashKey = \Author.$password

   func verify(password: String) throws -> Bool {
      try Bcrypt.verify(password, created: self.password)
   }
}


