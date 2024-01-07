import Foundation
import JWTKit

public extension Date {
    func verifyNotExpired() throws {
        if self < Date() {
            throw JWTError.claimVerificationFailure(name: "exp", reason: "Token has expired")
        }
    }
}
