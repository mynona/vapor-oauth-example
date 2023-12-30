import Vapor
import JWT

/// Used for testing purposes only
public struct EmptyPayload: JWTPayload {
   public func verify(using signer: JWTKit.JWTSigner) throws {

   }



}
