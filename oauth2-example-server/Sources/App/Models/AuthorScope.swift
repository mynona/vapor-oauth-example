import Vapor

public enum AuthorScope: String, Content {
   case ADMIN = "admin"
   case EDITOR = "editor"
   case VIEWER = "viewer"
}
