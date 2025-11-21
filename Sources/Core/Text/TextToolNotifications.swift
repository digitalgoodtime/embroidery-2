import Foundation

/// Notifications for text tool actions
extension Notification.Name {
    static let addTextToDocument = Notification.Name("addTextToDocument")
    static let selectTextAtPoint = Notification.Name("selectTextAtPoint")
    static let createNewText = Notification.Name("createNewText")
    static let textSelectionChanged = Notification.Name("textSelectionChanged")
}

/// User info keys for text tool notifications
enum TextToolNotificationKey {
    static let textObject = "textObject"
    static let point = "point"
    static let textID = "textID"
}
