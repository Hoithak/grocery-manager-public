//
//  UserData.swift
//  GroceryManager
//
//  Created by Pranot Kotchakoon on 12/7/19.
//

import SwiftUI
import Combine

final class UserData: ObservableObject  {
    
    // App variable
    @Published var ACTIVE_SCREEN: ActiveScreen = .welcome
    @Published var TABBAR_PRESENT: Bool = false
    @Published var LOADING_SCREEN_PRESENT: Bool = false
    @Published var SCAN_MODE: ScanMode = .read_mode
    @Published var PREVIOUS_SCREEN: ActiveScreen = .none

    // Product variables
    @Published var PRODUCT_CODE = ""
    @Published var PRODUCT = Product()
    @Published var PRODUCT_LOADED: Bool = false
    @Published var PRODUCT_SUBMIT_MODE: SubmitMode = .update
    var CATEGORY = [Category]()
    var TAX = [Tax]()
    var SEARCH_CODE = ""
    var SEARCH_NAME = ""
    var SEARCH_SELECTED_CATEGORY = -1
    
    //  Price calculation variables
    var ONLINE_PROFIT: Double = 0.45 // The online selling profit increased by 45% from the purchase price
    var LOCAL_STORE_PROFIT: [Double] = [0.25, 0.35, 0.45] // The in-store selling profit can be selected according to the product category
    var MINIMUM_FREE_SHIPPING: Double = 49.00 // Minimum total amount that qualifies for free shipping
    
    //  Shipping cost from UPS Ground shipping, last updated on 2019-09-21
    //  Zone 6 for 1 - 100 lbs
    //  Example:
    //      SHIPPING_TABLE_PRICE[0] represents a shipping cost of $10.71 for weights up to 1 lb
    //      SHIPPING_TABLE_PRICE[1] represents a shipping cost of $12.08 for weights greater than 1 lb and up to 2 lbs
    //  Reference: ups.com/assets/resources/webcontent/en_US/daily_rates.pdf
    var SHIPPING_TABLE_PRICE: [Double] = [
        10.71, 12.08, 12.94, 13.48, 14.29, 14.41, 14.68, 15.27, 15.59, 15.77,
        16.28, 16.85, 17.38, 18.39, 19.41, 20.04, 20.88, 21.98, 22.54, 23.31,
        24.27, 25.25, 26.46, 27.46, 27.97, 28.99, 30.13, 31.62, 32.53, 33.02,
        33.74, 34.06, 35.86, 36.28, 36.82, 38.37, 38.54, 39.42, 40.82, 41.26,
        42.57, 43.17, 45.08, 45.47, 45.79, 46.99, 47.63, 48.34, 48.70, 48.71,
        48.77, 48.78, 48.79, 48.80, 48.85, 48.86, 48.91, 48.92, 49.65, 50.10,
        50.55, 50.88, 51.23, 52.07, 52.52, 52.55, 52.97, 53.25, 53.54, 54.61,
        55.58, 55.98, 56.05, 57.45, 57.99, 58.73, 59.07, 59.43, 60.67, 61.69,
        62.49, 62.65, 63.42, 64.38, 65.37, 66.16, 67.03, 67.90, 68.74, 69.72,
        69.87, 70.70, 71.33, 72.16, 72.65, 73.06, 73.85, 74.68, 75.55, 76.47
    ]
    

    func getAllCategoryName()->[String] {
        return CATEGORY.map { $0.name }
    }
    
    func getCategoryIndexByCategoryName(name: String) -> Int {
        if let index = CATEGORY.firstIndex(where: { $0.id == name }) {
            return index
        }
        return -1
    }
    
    func getAllTaxName()->[String] {
        return TAX.map { $0.name }
    }
    
    func getTaxIndexByTaxName(name: String) -> Int {
        if let index = TAX.firstIndex(where: { $0.id == name }) {
            return index
        }
        return -1
    }
    
}

// MARK: ENUM
enum SubmitMode {
    case insert, update, delete
}

enum ScanMode {
    case read_mode, update_mode
}

enum ActiveScreen {
    case welcome, home, add, info, update, search, search_result, scan, setting, calibate, none
}

enum UpdateActionSheet {
    case none, photo, margin
}
