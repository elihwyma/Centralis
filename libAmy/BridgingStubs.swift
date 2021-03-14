//
//  BridgingStubs.swift
//  NitrolessiOS
//
//  Created by A W on 11/02/2021.
//

import UIKit

class AmyCell: UITableViewCell {}

enum AmyCellType {
    case Button
    case Switch
    case Social
    case AppIcon
    case Notification
}

protocol CellData {}

struct AmyCellData {
    var identifier: AmyCellType!
    var data: CellData?
}

struct SettingsSwitchData: CellData {
    var defaultName: String!
    var title: String!
    var defaultState: Bool!
}

struct NotificationSwitchData: CellData {
    var defaultName: String!
    var title: String!
    var defaultState: Bool!
    var vc: UIViewController!
}
/*
struct SocialCellData: CellData {
    var imageName: String!
    var title: String!
    var link: URL!
}
*/
struct ButtonCellData: CellData {
    var title: String!
    var notificationName: String!
}

/*
struct AppIconCellData: CellData {
    var title: String!
    var isDefault: Bool!
    var image: String!
}
*/
