import Foundation

/// Notifications for text tool actions
extension Notification.Name {
    static let showTextInputDialog = Notification.Name("showTextInputDialog")
}

/// User info keys for text tool notifications
enum TextToolNotificationKey {
    static let position = "position"
}
