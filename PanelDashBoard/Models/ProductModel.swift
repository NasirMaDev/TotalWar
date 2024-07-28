//
//  ProductModel.swift
//  PanelDashBoard
//
//  Created by Nasir Bin Tahir on 26/05/2024.
//  Copyright © 2024 Asjd. All rights reserved.
//

import Foundation
import UIKit

struct Product {
    let barCode: String
    let barCodePictureUrl: URL?
    
    init?(dictionary: NSDictionary) {
        guard let barCode = dictionary["barCode"] as? String,
              let barCodePictureUrlString = dictionary["barCodePictureUrl"] as? String,
              let barCodePictureUrl = URL(string: barCodePictureUrlString) else {
            return nil
        }
        
        self.barCode = barCode
        self.barCodePictureUrl = barCodePictureUrl
    }
}

struct ProductToUpload: Codable {
    var images : [UIImage]
    var status : String?
    var barcode : String? = ""
    var ismatchbarcode : Bool = false
    var barCodeURLPostFix: String = ""
    
    // Custom encoding/decoding for UIImage
       private enum CodingKeys: String, CodingKey {
           case imageData, status, barcode, ismatchbarcode, barCodeURLPostFix
       }
       
       init(image: [UIImage], status: String?, barcode: String?, ismatchbarcode: Bool, barCodeURLPostFix: String) {
           self.images = image
           self.status = status
           self.barcode = barcode
           self.ismatchbarcode = ismatchbarcode
           self.barCodeURLPostFix = barCodeURLPostFix
       }
       
       init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: CodingKeys.self)
           let imageData = try container.decode([Data].self, forKey: .imageData)
           self.images = imageData.map { UIImage(data: $0)! }
           self.status = try container.decode(String?.self, forKey: .status)
           self.barcode = try container.decode(String?.self, forKey: .barcode)
           self.ismatchbarcode = try container.decode(Bool.self, forKey: .ismatchbarcode)
           self.barCodeURLPostFix = try container.decode(String.self, forKey: .barCodeURLPostFix)
       }
       
       func encode(to encoder: Encoder) throws {
           var container = encoder.container(keyedBy: CodingKeys.self)
           let imageData = images.map { $0.jpegData(compressionQuality: 1.0)! }
           try container.encode(imageData, forKey: .imageData)
           try container.encode(status, forKey: .status)
           try container.encode(barcode, forKey: .barcode)
           try container.encode(ismatchbarcode, forKey: .ismatchbarcode)
           try container.encode(barCodeURLPostFix, forKey: .barCodeURLPostFix)
       }
}

struct Productv2: Codable {
    let productID: String?
    let lotID: String?
    let universe: String?
    let army: String?
    let key: String?
    let quantity: String?
    let figurine: String?
    let type: String?
    let id: String? // Assuming this field might be empty
    let assigned: String?
    let translationEN: String?
    let condition: String?
    let remarks: String?
    let receivedQuantity: String?
    let assembly: String?
    let newValue: String?
    let expectedSale: String?
    let chapter: String?
    let location: String?
    let ebayCategory: String?
    let format: String?
    let listed: String?
    let shortDescriptionEN: String?
    let longDescriptionEN: String?
    let chapterRegiment: String?
    let picURL: String?
    let categoryPS: String?
    let proxy: String?
    let conversion: String?
    let complete: String?
    let brand: String?

    enum CodingKeys: String, CodingKey {
        case productID = "Product ID"
        case lotID = "ID Lot"
        case universe = "Univers"
        case army = "Armée"
        case key = "Clé"
        case quantity = "Nombre"
        case figurine = "Figurine"
        case type = "Type"
        case id = ""
        case assigned = "Attribué"
        case translationEN = "Traduction EN"
        case condition = "Etat"
        case remarks = "Remarques"
        case receivedQuantity = "Quantité reçue"
        case assembly = "Montage"
        case newValue = "valeur neuf"
        case expectedSale = "espérance vente"
        case chapter = "Chapitre"
        case location = "Emplacement"
        case ebayCategory = "categorie ebay"
        case format = "Format"
        case listed = "Mis en vente"
        case shortDescriptionEN = "Short Description EN"
        case longDescriptionEN = "Long Description EN"
        case chapterRegiment = "Chapitre / régiment"
        case picURL = "PIC URL"
        case categoryPS = "Categorie PS"
        case proxy = "Proxy"
        case conversion = "Conversion"
        case complete = "Complet"
        case brand = "Marque"
    }
}
