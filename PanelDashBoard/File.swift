//
//  File.swift
//  PanelDashBoard
//
//  Created by SilentSol PVT LTD on 23/11/2021.
//  Copyright © 2021 Asjd. All rights reserved.
//

import Foundation
struct FileResponse: Decodable {
    var kind: String
    var files: [File]
}

struct File: Decodable {
    var mimeType: String
    var id: String
    var kind: String
    var name: String
}
