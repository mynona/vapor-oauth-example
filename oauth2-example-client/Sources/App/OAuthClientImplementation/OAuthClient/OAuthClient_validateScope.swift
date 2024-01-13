extension OAuthClient {

   /// Validate Scopes
   ///
   /// Retrieved scopes can be returned in any order. Additionally, it can not be guaranteed that scopes are separated by spaces or commas. Therefore, this validation uses the data type Set to compare scopes.
   ///
   static func validateScope(
      requiredScopes: String,
      retrievedScopes: String
   ) -> Bool {


      func stringToArray(_ scopes: String) -> [String] {
         let scopesArray: [String]
         if scopes.contains(",") {
            scopesArray = scopes.components(separatedBy: ",")
         } else {
            scopesArray = scopes.components(separatedBy: " ")
         }

         return scopesArray
      }

      let retrievedScopesSet = Set(stringToArray(retrievedScopes))
      let requiredScopesSet = Set(stringToArray(requiredScopes))

      guard
         requiredScopesSet.isSubset(of: retrievedScopesSet)
      else {

#if DEBUG
         print("\n-----------------------------")
         print("Controller() \(#function)")
         print("-----------------------------")
         print("allowedScopes: \(requiredScopesSet)")
         print("returnedScopes: \(retrievedScopesSet)")
         print("Scope check failed.")
         print("-----------------------------")
#endif

         return false
      }

#if DEBUG
      print("\n-----------------------------")
      print("Controller() \(#function)")
      print("-----------------------------")
      print("allowedScopes: \(requiredScopesSet)")
      print("returnedScopes: \(retrievedScopesSet)")
      print("Scope check passed.")
      print("-----------------------------")
#endif

      return true

   }

}
