import Vapor
import JWT

public struct Payload: JWTPayload {
   // Maps the longer Swift property names to the
   // shortened keys used in the JWT payload.
   public enum CodingKeys: String, CodingKey {
      case subject = "sub"
      case expiration = "exp"
      case issuer = "iss"
      case audience = "aud"
      case jti = "jti"
      case issuedAtTime = "iat"
   }

   // The "sub" (subject) claim identifies the principal that is the
   // subject of the JWT.
   public var subject: SubjectClaim

   // The "exp" (expiration time) claim identifies the expiration time on
   // or after which the JWT MUST NOT be accepted for processing.
   public var expiration: ExpirationClaim

   // Custom data

   // An identifier for that system which created the JWT.
   public var issuer: String

   // An identifier for the intended audience
   public var audience: String

   // Unique identifier; can be used to prevent the JWT from being replayed
   // (allows a token to be used only once)
   public var jti: String

   public var issuedAtTime: Date

   // Run any additional verification logic beyond
   // signature verification here.
   // Since we have an ExpirationClaim, we will
   // call its verify method.
   public func verify(using signer: JWTSigner) throws {
      try self.expiration.verifyNotExpired()
   }
}
