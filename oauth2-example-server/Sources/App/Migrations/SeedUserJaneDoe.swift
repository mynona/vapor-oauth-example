import Fluent
import Vapor

struct SeedUserJaneDoe: AsyncMigration {
   
   func prepare(on database: Database) async throws {
      
      let uuid = UUID(uuidString: "8c3afb78-3b44-11ec-8aa0-9c18a4eebeeb")
      let password = try Bcrypt.hash("password")

      let author = MyUser(
         id: uuid,
         username: "jane_doe@something.com",
         password: password,
         emailAddress: nil,
         emailAddressVerified: nil,
         givenName: "Jane",
         familyName: "Doe",
         middleName: nil,
         nickname: nil,
         profile: nil,
         picture: nil,
         website: nil,
         gender: nil,
         birthdate: nil,
         zoneinfo: nil,
         locale: nil,
         phoneNumber: nil,
         phoneNumberVerified: nil,
         roles: ["viewer","lalala","something","something"],
         newsletter: false,
         blocked: false,
         lastLogin: nil,
         validatedAt: nil,
         cookiePreferences: .NOT_SET,
         federated: false,
         oauthProvider: .SELF
      )

      return try await author.save(on: database)
   }
   
   func revert(on database: Database) async throws {
      
      try await MyUser
         .query(on: database)
         .filter(\.$username == "jane_doe@something.com")
         .delete()
   }
   
}



