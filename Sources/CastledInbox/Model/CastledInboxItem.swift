//
//  CastledInboxitem.swift
//  CastledInboxPOC
//
//  Created by antony on 28/08/2023.
//
@_spi(CastledInternal) import Castled
import Foundation
import UIKit

@objc public class CastledInboxItem: NSObject, Codable {
    public var actionButtons: [[String: Any]]
    public var addedDate: Date
    public var aspectRatio: CGFloat
    public var body: String
    public var bodyTextColor: UIColor
    public var containerBGColor: UIColor
    public var dateTextColor: UIColor
    public var imageUrl: String
    public var inboxType: CastledInboxType
    public var isRead: Bool
    public var isPinned: Bool
    public var message: [String: Any]
    public var messageId: Int64
    public var startTs: Int64
    public var sourceContext: String
    public var tag: String
    public var teamID: Int
    public var title: String
    public var titleTextColor: UIColor
    public var updatedTime: Int64

    enum CodingKeys: String, CodingKey {
        case teamID = "teamId"
        case messageId
        case isRead = "read"
        case updatedTime = "updatedTs"
        case isPinned = "pinningEnabled"
        case message
        case sourceContext, startTs, aspectRatio, tag // Use messageData to decode the message
    }

    public func encode(to encoder: Encoder) throws {
        var _ = encoder.container(keyedBy: CodingKeys.self)

        // Encode other fields if needed
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.teamID = (try? container.decodeIfPresent(Int.self, forKey: .teamID)) ?? 0
        self.messageId = try container.decode(Int64.self, forKey: .messageId)
        self.sourceContext = try container.decode(String.self, forKey: .sourceContext)
        self.startTs = try container.decodeIfPresent(Int64.self, forKey: .startTs) ?? 0
        self.updatedTime = try container.decodeIfPresent(Int64.self, forKey: .updatedTime) ?? 0
        self.isRead = try container.decodeIfPresent(Bool.self, forKey: .isRead) ?? true
        self.isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
        self.tag = try container.decodeIfPresent(String.self, forKey: .tag) ?? ""
        self.message = try container.decode([String: Any].self, forKey: .message)
        self.addedDate = Date.from(epochTimestamp: TimeInterval(self.startTs / 1000))
        self.actionButtons = (self.message["actionButtons"] as? [[String: Any]] ?? [])
        self.aspectRatio = CGFloat((self.message["aspectRatio"] as? Double) ?? Double((self.message["aspectRatio"] as? Int) ?? Int(0.0)))
        self.imageUrl = (self.message["thumbnailUrl"] as? String) ??
            (self.message["contents"] as? [[String: Any]] ?? []).first?["thumbnailUrl"] as? String ??
            (self.message["contents"] as? [[String: Any]] ?? []).first?["url"] as? String ?? ""
        self.title = (self.message["title"] as? String) ?? ""
        self.body = (self.message["body"] as? String) ?? ""
        self.inboxType = CastledInboxType(rawValue: (self.message["type"] as? String) ?? "OTHER") ?? .other
        self.titleTextColor = CastledCommonClass.hexStringToUIColor(hex: (self.message["titleFontColor"] as? String) ?? "") ?? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.bodyTextColor = CastledCommonClass.hexStringToUIColor(hex: (self.message["bodyFontColor"] as? String) ?? "") ?? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.dateTextColor = self.bodyTextColor
        self.containerBGColor = CastledCommonClass.hexStringToUIColor(hex: (self.message["bgColor"] as? String) ?? "") ?? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }

    static func == (lhs: CastledInboxItem, rhs: CastledInboxItem) -> Bool {
        return lhs.sourceContext == rhs.sourceContext
    }

    // Initialize your properties here
    override init() {
        self.actionButtons = []
        self.addedDate = Date()
        self.aspectRatio = 0.0
        self.bodyTextColor = .black
        self.containerBGColor = .white
        self.dateTextColor = .black
        self.inboxType = .other
        self.isRead = false
        self.message = [:]
        self.sourceContext = ""
        self.imageUrl = ""
        self.title = ""
        self.body = ""
        self.startTs = 0
        self.teamID = 0
        self.messageId = 0
        self.titleTextColor = .black
        self.isPinned = false
        self.tag = ""
        self.updatedTime = 0
        super.init()
    }
}
