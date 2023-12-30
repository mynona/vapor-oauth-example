import Vapor
import JWT

struct Controller: Encodable {

   enum TokenType {
      case AccessToken
      case RefreshToken
      case IdToken
   }

   // ----------------------------------------------------------

   /// Create cookie to store token value
   ///
   func createCookie(value: String, for tokenType: TokenType) -> HTTPCookies.Value {

      let maxAge: Int
      let path: String?

      switch tokenType {

      case .AccessToken:
         maxAge = 60 * 2 // 2 minutes
         path = nil

      case .RefreshToken:
         maxAge = 60 * 60 * 24 * 30 // 30 days
         path = nil // "/refresh" in real world situation

      case .IdToken:
         maxAge = 60 * 10 // 10 minutes
         path = nil

      }

      return HTTPCookies.Value(
         string: value,
         expires: Date(timeIntervalSinceNow: TimeInterval(maxAge)),
         maxAge: maxAge,
         domain: nil,
         path: path,
         isSecure: false, // in real world case: true
         isHTTPOnly: true,
         sameSite: .lax
      )

   }

   // ----------------------------------------------------------

   /// Request new accessToken with refreshToken
   ///
   /// - Returns: access_token
   ///
   func requestNewAccessToken(forRefreshToken refreshToken: String, _ request: Request) async throws -> OAuth_RefreshTokenResponse? {

      // Add basic authentication credentials to the request header
      let resourceServerUsername = "resource-1"
      let resourceServerPassword = "resource-1-password"
      let credentials = "\(resourceServerUsername):\(resourceServerPassword)".base64String()

      let headers = HTTPHeaders(dictionaryLiteral:
                                 ("Authorization", "Basic \(credentials)")
      )

      let tokenEndpoint = URI(string: "http://localhost:8090/oauth/token")

      let content = OAuth_RefreshTokenRequest(
         grant_type: "refresh_token",
         client_id: "1",
         client_secret: "password123",
         refresh_token: refreshToken
      )

      let response = try await request.client.post(tokenEndpoint, headers: headers, content: content)

#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("Refresh token endpoint: \(tokenEndpoint)")
      print("Refresh token request header: \(headers)")
      print("-----------------------------")
      print("Refresh token response: \(response)")
      print("-----------------------------")
#endif

      guard
         response.status == .ok
      else {
         return nil
      }

      // Unwrap response
      let token: OAuth_RefreshTokenResponse = try response.content.decode(OAuth_RefreshTokenResponse.self)

#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("-----------------------------")
      print("Unwrapped: \(token)")
      print("-----------------------------")
#endif

      return token

   }

   // ----------------------------------------------------------

   /// Call introspection endpoint
   ///
   func token_info(accessToken: String, _ request: Request) async throws -> OAuth_TokenIntrospectionResponse? {

      // -------------------------------------------------------
      // Token introspection to check if a valid token has been
      // provided

      let content = OAuth_TokenIntrospectionRequest(
         token: accessToken
      )

      // Add basic authentication credentials to the request header
      let resourceServerUsername = "resource-1"
      let resourceServerPassword = "resource-1-password"
      let credentials = "\(resourceServerUsername):\(resourceServerPassword)".base64String()

      let headers = HTTPHeaders(dictionaryLiteral:
                                 ("Authorization", "Basic \(credentials)")
      )

#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("Token introspection request")
      print("Headers: \(headers)")
      print("Content: \(content)")
      print("-----------------------------")
#endif

      let tokenEndpoint = URI(string: "http://localhost:8090/oauth/token_info")
      let response = try await request.client.post(tokenEndpoint, headers: headers, content: content)

#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("Token introspection response:")
      print("Response: \(response)")
      print("-----------------------------")
#endif

      guard
         response.status == .ok
      else {
         return nil
      }

      // Unwrap response
      let introspection: OAuth_TokenIntrospectionResponse = try response.content.decode(OAuth_TokenIntrospectionResponse.self)

#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("Unwrapped response::")
      print("Introspection: \(introspection)")
      print("-----------------------------")
#endif

      return introspection
   }

   // ----------------------------------------------------------

   /// Validate Signature and payload of JWT
   ///
   func validateJWT(forToken token: String, tokenType: TokenType,  _ request: Request) async throws -> Bool {

#if DEBUG
      print("\n-----------------------------")
      print("validateJWT() \(#function)")
      print("-----------------------------")
      print("Called for \(tokenType)")
      print("-----------------------------")
#endif

      let response = try await request.client.get("http://localhost:8090/.well-known/jwks.json")

      guard
         response.status == .ok
      else {
         throw Abort(.badRequest, reason: "JWKS could not be retrieved from OpenID Provider.")
      }

      let jwkSet = try response.content.decode(JWKS.self)

      guard
         let jwks = jwkSet.find(identifier: JWKIdentifier(string: "public-key"))?.first,
         let modulus = jwks.modulus,
         let exponent = jwks.exponent,
         let publicKey = JWTKit.RSAKey(modulus: modulus, exponent: exponent)
      else {
         throw Abort(.badRequest, reason: "JWK key could not be unpacked")
      }

      let signers = JWTKit.JWTSigners()
      signers.use(.rs256(key: publicKey))


      // Validate JWT payload and correct signature
      var payload: JWTPayload? = nil

      do {
         switch tokenType {
         case .AccessToken:
            payload = try signers.verify(token, as: OAuth_AccessTokenPayload.self)
         case .RefreshToken:
            payload = try signers.verify(token, as: EmptyPayload.self)
         case .IdToken:
            payload = try signers.verify(token, as: OAuth_IDTokenPayload.self)
         }
      } catch {
         // Signature or payload issue
         return false
      }

#if DEBUG
      print("\n-----------------------------")
      print("validateJWT() \(#function)")
      print("-----------------------------")
      print("Public Key: \(publicKey)")
      print("Payload: \(payload)")
      print("Signature and payload validation of \(tokenType) was successful.")
      print("-----------------------------")
#endif

      return true

   }

}
