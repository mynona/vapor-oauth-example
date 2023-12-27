import Vapor
import VaporOAuth
import Fluent
import JWTKit


/// Key Management Service
///
/// Generate private key:
/// *  openssl genpkey -algorithm RSA -out private_key.pem
/// 
/// Display private key; if passphrase defined you will be prompted
/// * openssl rsa -check -in private_key.pem
///
/// Generate public key out of the private key
/// * openssl rsa -pubout -in private_key.pem -out public_key.pem
///
/// Get the modulus of the key
/// * openssl rsa -pubout -in private_key.pem -noout -modulus
/// * openssl rsa -in private_key.pem -noout -text
///
/// Ansi parse
/// * openssl asn1parse -in public_key.pem -i -dump
///
final class MyKeyManagementService: VaporOAuth.KeyManagementService {

   private let app: Application

   init(app: Application) {
      self.app = app
   }

   public var privateKey: RSAKey? {

      let pem =
"""
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC2eyLG1Z2aa2Gt
F6iB7DuqYDsq2W9pkZiHeWrkZ2lxwq0+IIAGai4Y5UbW2iWKva2hesWRlzEpNbZA
sG0JgmHec0ddWpjjFnmbHnsgkTrY4wE6X8wzpCy25SsuZm3WAyWlZaGX7XEI6aqh
/GTFsfRzGOuT/6c5+6ycCS/gyZ2DLDuDWGVhEKp3FXCjspNjnRrISszViD1IoH+J
kajo5NFMfYpfeuZE/oBQ2ZHpjToq0y//IsJ6ypHz1MEkKq48/PF18DYSjPadHiUu
t7MzAq59t5TJ5lAFYBkZUeF+q8DvaX2HFc6rbCwh2E2qJUFBtw96Qg20D2zLjI4X
DC/+qYlPAgMBAAECggEABJ+7fTJYhgXb5G5JtNEZn0hE94xUSGaKE5S+DVTu1RUh
HVvmzULPhuNNwjqmN40gOIv13v89HargwrmLFHHwrO8Fi0C1Hbv/ZNuG3zJkPVld
5JlyK999ypH6tXhJpuH5iDwPtjEsFhUQX9PCHJ2qcL2G6qnQa6W29VU+Q1dDMy8B
ZaPObEM+DmANLMQPZCrkmi/wiJHgqZTeGN03bNk2sMjoq2r/H2VmCHK6BvDdohXr
nOvyrBg9cDJETk/uYVJojGux+Dxvx3nFaFuuWfuhJ4J5N9yX7rUPoMv1oYRcYCBw
oWd7QSdNNhXPlQEvq6q72GoFglgdF/oSoPcthqTRUQKBgQDxfPm9ML0xH0wKeoW2
LCaiJCwdyp2j1q7W1FibBHs8a/g1Av3GkXctWjxgdKLaRsrpPm4pzXwVsECrkECg
2FE5KAN/kHJKj1szpdYR5UtHxqHG2qqNmLNMff9VL3wt/nL+VrOMMVcUR4sR0zfe
MEkRdyXHPIS6QaPdDX4UeLeL0wKBgQDBcmap0ox2UZqa9h0duJnO53QTyA10ORT1
amjMNlMLEA/zk5/7dzmdfsUY8ihBoerT7oF6w6wuTA0R5D5sKNcBjemsI5iQHSS/
Qp/Zxq36A7THt3VXpsrb8P5QRQNL9G8ig7aIQzhjyqA4bNpfi4+SB4zR+OJyZXOL
DtOBFmMLFQKBgQCURHVZcYlXla2saVmbZjQ6LRdhGzv6kh87C5lzZCb+DBSTB8kk
l7+ietrDJhmvBvQijRA6Xk2nS1YJgEIN/4KvIyAyvE9P9AC9Dz8GMdAsu4ose6ln
0q+TcXDJrqQB4U5dVoJauxiJ/Psn8JVGuELElHD/iOq9KPwhBt24V/3pvQKBgEMc
PSGNOc2SYeCAoXk+IZ32Df8O2BwJ8Ytybwjpj8W2vNHz1PyYUBSjdh1BZVXfpmf/
xkugtosZNy+Nz1oWkQCpCvf9IWBdu/HeWzZiBtlFj+H5c2wFITtMT+3pA0vGcQe4
SgrbxyRXl1375YZgFF7E38W4Ylbtezgy3I1cBuBBAoGBAMOa0ChC7VHV5WyB88cd
ZeNNfZz+ugg2FvyEOjy0fs5L4FEjdJvnXJfRqCbLjBEpPsrTydGIWfm4H5YjGyx2
EKBwiCB+VTRjQ8SqJ2PUsmVIBhAPKahAZQkhbMQAyMZwGaKva9FCvVtng6nMSixZ
vZVdVCpopLzPjH7MWw5x1vB1
-----END PRIVATE KEY-----
"""
      // Inititalize an RSA key with private pem
      do {
         let privateKey = try RSAKey.private(pem: pem)
         return privateKey
      } catch {
         return nil
      }
   }

   public var publicKey: RSAKey? {

      let pem =
"""
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtnsixtWdmmthrReogew7
qmA7KtlvaZGYh3lq5GdpccKtPiCABmouGOVG1tolir2toXrFkZcxKTW2QLBtCYJh
3nNHXVqY4xZ5mx57IJE62OMBOl/MM6QstuUrLmZt1gMlpWWhl+1xCOmqofxkxbH0
cxjrk/+nOfusnAkv4Mmdgyw7g1hlYRCqdxVwo7KTY50ayErM1Yg9SKB/iZGo6OTR
TH2KX3rmRP6AUNmR6Y06KtMv/yLCesqR89TBJCquPPzxdfA2Eoz2nR4lLrezMwKu
fbeUyeZQBWAZGVHhfqvA72l9hxXOq2wsIdhNqiVBQbcPekINtA9sy4yOFwwv/qmJ
TwIDAQAB
-----END PUBLIC KEY-----
"""
      // Initialize an RSA key with public pem
      do {
         let publicKey = try RSAKey.public(pem: pem)
         return publicKey
      } catch {
         return nil
      }
   }

   /// Extract modulus from Key:
   ///
   /// PEM to JWK converter: Enter the public key and try the endpoint /.well-known/jwks.json to create the PEM for validation
   ///
   /// * https://8gwifi.org/jwkconvertfunctions.jsp
   ///
   public let modulus: String = "tnsixtWdmmthrReogew7qmA7KtlvaZGYh3lq5GdpccKtPiCABmouGOVG1tolir2toXrFkZcxKTW2QLBtCYJh3nNHXVqY4xZ5mx57IJE62OMBOl_MM6QstuUrLmZt1gMlpWWhl-1xCOmqofxkxbH0cxjrk_-nOfusnAkv4Mmdgyw7g1hlYRCqdxVwo7KTY50ayErM1Yg9SKB_iZGo6OTRTH2KX3rmRP6AUNmR6Y06KtMv_yLCesqR89TBJCquPPzxdfA2Eoz2nR4lLrezMwKufbeUyeZQBWAZGVHhfqvA72l9hxXOq2wsIdhNqiVBQbcPekINtA9sy4yOFwwv_qmJTw"


   /// Extract modulus from Key:
   ///
   /// * openssl rsa -pubin -in public_key.pem -text -noout
   ///
   public let exponent: String = "AQAB" // representation of 65537

}
