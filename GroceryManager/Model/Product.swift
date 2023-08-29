//
//  Product.swift
//  GroceryManager
//
//  Created by Pranot Kotchakoon on 12/14/19.
//

import Foundation
import SwiftUI

struct Product {
    
    var id: String = ""
    var code: String = ""
    var name: String = ""
    var categoryId:String = ""
    var categoryName:String = ""
    var taxId:String = ""
    var taxRate: Double = 0.00
    var purchase: Double = 0.00
    var inStorePrice: Double = 0.00
    var websitePrice: Double = 0.00
    var inStoreStock: Int = 0
    var websiteStock: Int = 0
    var expiration: Date? = nil
    var weight: Double = 0.00
    var image: UIImage?
    
    
    func getImageString() -> String {
        // Convert image into a string for database insertion
        // Supports only JPEG and PNG file formats
        if let image = image {
            if let imageData = image.jpegData(compressionQuality: 1) {
                return imageData.base64EncodedString()
            } else if let pngData = image.pngData() {
                return pngData.base64EncodedString()
            }
        }
        return ""
    }

}
