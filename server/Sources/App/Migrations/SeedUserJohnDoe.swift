import Fluent
import Vapor

struct SeedUserJohnDoe: AsyncMigration {

   func prepare(on database: Database) async throws {

      let uuid = UUID(uuidString: "5c3afb78-3b44-11ec-8aa0-9c18a4eebeeb")
      let password = try Bcrypt.hash("password")

      let author = UserModel(
         id: uuid,
         username: "john_doe@something.com",
         password: password,
         emailAddress: "john_doe@something.com",
         emailAddressVerified: true,
         givenName: "John",
         familyName: "Doe",
         middleName: "Jasper",
         nickname: "Jonny",
         preferredUsername: "john_doe",
         profile: nil,
         picture: nil,
         website: nil,
         gender: "male",
         birthdate: nil,
         zoneinfo: "AT", // https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
         locale: "en-US",
         phoneNumber: "66477771745",
         phoneNumberVerified: true,
         roles: ["admin","openid","phone","email","profile","custom", "address"],
         newsletter: true,
         blocked: false,
         lastLogin: Date(),
         validatedAt: Date(),
         cookiePreferences: .NOT_SET,
         federated: false,
         oauthProvider: .SELF,
         streetAddress: "Mainstreet 1",
         locality: "Vienna",
         region: "Vienna",
         postalCode: "1010",
         country: "Austria"
      )

      return try await author.save(on: database)
   }

   func revert(on database: Database) async throws {

      try await UserModel
         .query(on: database)
         .filter(\.$username == "john_doe@something.com")
         .delete()
   }

}



