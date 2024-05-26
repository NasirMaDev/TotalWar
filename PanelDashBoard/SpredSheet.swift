//
//  SpredSheet.swift
//  PanelDashBoard
//
//  Created by SilentSol PVT LTD on 23/11/2021.
//  Copyright © 2021 Asjd. All rights reserved.
//

import Foundation
struct Spreadsheet: Decodable {
    var spreadsheetId: String
    var valueRanges: [Sheet]
}

struct Sheet: Decodable {
    var range: String
    var majorDimension: String
    var values: [[String]]
}
