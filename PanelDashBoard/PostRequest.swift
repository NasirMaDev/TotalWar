//
//  PostRequest.swift
//  PanelDashBoard
//
//  Created by SilentSol PVT LTD on 23/11/2021.
//  Copyright © 2021 Asjd. All rights reserved.
//

import Foundation
struct POSTRequest: Encodable {
    var valueInputOption = "RAW"
    var data: [POSTData]
}

struct POSTData: Encodable {
    var range: String
    var majorDimension = "ROWS"
    var values: [[String]]
}
