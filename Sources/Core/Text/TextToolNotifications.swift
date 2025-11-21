import Foundation

/// Notifications for text tool actions
extension Notification.Name {
    static let addTextToDocument = Notification.Name("addTextToDocument")
}

/// User info keys for text tool notifications
enum TextToolNotificationKey {
    static let textObject = "textObject"
}
