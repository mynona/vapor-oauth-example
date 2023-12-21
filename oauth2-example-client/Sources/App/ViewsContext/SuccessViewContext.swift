import Foundation

struct SuccessViewContext: Encodable {
    let expiryInMinutes: Int
    let accessToken: String
    let refreshToken: String
    let scope: String
}