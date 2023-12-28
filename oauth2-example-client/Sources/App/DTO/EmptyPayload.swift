import Vapor
import JWT

public struct EmptyPayload: JWTPayload {
   public func verify(using signer: JWTKit.JWTSigner) throws {

   }



}
