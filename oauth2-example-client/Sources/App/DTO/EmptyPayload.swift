import Vapor
import JWT

/// JWT Payload
/// - Parameters:
///   - subject: The "sub" (subject) claim identifies the principal that is the subject of the JWT.
///   - expiration: The "exp" (expiration time) claim identifies the expiration time
///   - issuer: An identifier for that system which created the JWT.
///   - audience: An identifier for the intended audience
///   - jti: Unique identifier; can be used to prevent the JWT from being replayed (allows a token to be used only once)
///   - issuedAtTime: issuing DateTime
public struct EmptyPayload: JWTPayload {
   public func verify(using signer: JWTKit.JWTSigner) throws {

   }



}
