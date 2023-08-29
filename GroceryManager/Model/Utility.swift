//
//  Utility.swift
//  GroceryManager
//
//  Created by Pranot Kotchakoon on 8/25/23.
//

import Foundation

struct Utility {
    static var shared = Utility()
    
    func deleteUserDefault() {
        // Clear all user defaults associated with the current app's bundle identifier
        // Use this when you want to test the save/load mechanism
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        print(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)
    }
    
    func convertToStoreStandardPriceFormat(inputPrice: Double) -> Double {
        //  The function will convert the input price to
        //  a standard price format that ends with a 5 or 9 digit
        //  Example:
        //   For inputPrice = 10.00, the function returns 10.05
        //   For inputPrice = 10.06, the function returns 10.09
        var outputPriceString = ""
        let inputPriceString = String(format: "%.2f", inputPrice)
        let digits = "\(inputPriceString)".components(separatedBy: ".")
        let firstDigit = digits[1][0]
        if let secondDigit = Double(digits[1][1]) {
            if (secondDigit < 6){
                outputPriceString = "\(digits[0]).\(firstDigit)5"
            }
            else {
                outputPriceString = "\(digits[0]).\(firstDigit)9"
            }
        }
        return Double(outputPriceString) ?? 0.00
    }
    
    
    func calculateShippingCostPerProductUnit(
        purchasePrice: Double,
        profitMargin: Double,
        productWeight: Double,
        minimumFreeShipping: Double,
        shippingCost: Double,
        shippingCostTable: [Double]) -> Double {
            //  This function calculates the shipping cost per product unit
            //  by utilizing recursion to determine the minimum shipping cost
            //  for free shipping orders that do not affect the profit margin.
            
            let sellingPrice = purchasePrice + (purchasePrice * profitMargin) + shippingCost
            let quantity = ceil(minimumFreeShipping / sellingPrice)
            let totalWeight = productWeight == 0 ? 1 : ceil(quantity * productWeight)
            
            //  Get shipping cost according to order weight
            //  If the order weight is over 100 lbs,
            //  we will calculate a shipping cost of $80
            let shippingCostPerOrder = totalWeight < 100 ? shippingCostTable[Int(totalWeight) - 1] : 80
            
            var newShippingCost = shippingCostPerOrder / quantity
            if(newShippingCost > shippingCost) {
                newShippingCost = calculateShippingCostPerProductUnit(
                    purchasePrice: purchasePrice,
                    profitMargin: profitMargin,
                    productWeight: productWeight,
                    minimumFreeShipping: minimumFreeShipping,                    
                    shippingCost: newShippingCost,
                    shippingCostTable: shippingCostTable)
            }
            
            return newShippingCost
        }
    
}
