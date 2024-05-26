//
//  Configs.swift
//  PanelDashBoard
//
//  Created by Nasir Bin Tahir on 26/05/2024.
//  Copyright © 2024 Asjd. All rights reserved.
//

import Foundation
import Foundation

struct Config {
    static var secretKeyAWS: String {
        return Bundle.main.infoDictionary?["Secret_Key_AWS"] as? String ?? ""
    }
    static var accessKeyAWS: String {
        return Bundle.main.infoDictionary?["Access_Key_AWS"] as? String ?? ""
    }
}
