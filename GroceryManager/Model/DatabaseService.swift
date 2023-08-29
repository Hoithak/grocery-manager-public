//
//  DatabaseService.swift
//  GroceryManager
//
//  Created by Pranot Kotchakoon on 8/20/23.
//

import Foundation
import SwiftUI

struct DatabaseService {

    static var shared = DatabaseService()
    
    var host_address:String = ""
    var db_name:String = ""
    var db_username:String = ""
    var db_password:String = ""
    var woo_address:String = ""
    var woo_key:String = ""
    var woo_secret:String = ""
    
    init() {
        let defaults = UserDefaults.standard
        host_address = defaults.string(forKey: "host_address") ?? host_address
        db_name = defaults.string(forKey: "db_name") ?? db_name
        db_username = defaults.string(forKey: "db_username") ?? db_username
        db_password = defaults.string(forKey: "db_password") ?? db_password
        woo_address = defaults.string(forKey: "woo_address") ?? woo_address
        woo_key = defaults.string(forKey: "woo_key") ?? woo_key
        woo_secret = defaults.string(forKey: "woo_secret") ?? woo_secret
    }
    
    var default_params: [String: Any] {
        return [
            "host": host_address,
            "dbname": db_name,
            "user": db_username,
            "pwd": db_password
        ]
    }
    
    
    // MARK: SET DEFAULT PARAMS
    mutating func setDatabaseParameters() {
        let defaults = UserDefaults.standard
        host_address = defaults.string(forKey: "host_address") ?? host_address
        db_name = defaults.string(forKey: "db_name") ?? db_name
        db_username = defaults.string(forKey: "db_username") ?? db_username
        db_password = defaults.string(forKey: "db_password") ?? db_password
        woo_address = defaults.string(forKey: "woo_address") ?? woo_address
        woo_key = defaults.string(forKey: "woo_key") ?? woo_key
        woo_secret = defaults.string(forKey: "woo_secret") ?? woo_secret
    }

    
    // MARK: CHECK CONNECTION
    func checkConnection(completion: @escaping (String) -> Void) {
        let request = setRequest(service: "mobile_connection")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let responseString = getResponse(data, response, error)
            if responseString == "Pass" {
                completion("Connect success !!!")
            } else {
                completion("Auth failed !!!")
            }
        }
        task.resume()
    }
    
    
    // MARK: SEARCH PRODUCT
    func searchProduct(product: Product, completion: @escaping ([Result]) -> Void) {
        let parameters: [String: Any] = [
            "name": product.name,
            "code": product.code,
            "category": product.categoryId
        ]
        loadData(service: "mobile_search", extendParams: parameters, parseFunction: { data in
            parseJSON(data: data, mappingFunction: mapToSearchProduct)
        }, completion: completion)
    }
    // Mapping dictionary for parseJSON
    func mapToSearchProduct(jsonDict: NSDictionary) -> Result? {
        guard let id = jsonDict["ID"] as? String,
              let code = jsonDict["CODE"] as? String,
              let name = jsonDict["NAME"] as? String,
              let price = Double(jsonDict["PRICESELL"] as? String ?? "0") else {
            return nil
        }
        return Result(id: id, code: code, name: name, price: price)
    }
    
    // MARK: GET IMAGE
    func getProductImage(code: String, completion: @escaping (UIImage?) -> Void) {
        let request = setRequest(service: "mobile_image", extendParams: ["code": code])
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("Cannot get image data")
                completion(nil)
                return
            }
            if let uiimage = UIImage(data: data) {
                completion(uiimage)
            } else {
                print("No data received when loading image")
                completion(nil)
            }
        }
        task.resume()
    }
    
    // MARK: INSERT PRODUCT
    func insertProduct(product: Product, completion: @escaping (String) -> Void) {
        var expiration:String = ""
        if let exp = product.expiration {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyy/MM/dd"
            expiration = formatter.string(from: exp)
        }
        let parameters: [String: Any] = [
            "name": product.name,
            "code": product.code,
            "pricebuy": product.purchase,
            "pricesell": product.inStorePrice,
            "priceweb": product.websitePrice,
            "stock": product.inStoreStock,
            "expiration": expiration,
            "category": product.categoryId,
            "taxcat": product.taxId,
            "image": product.getImageString()
        ]
        let request = setRequest(service: "mobile_insert_stock", extendParams: parameters)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let responseString = getResponse(data, response, error)
            if responseString == "The product has been inserted successfullyThe stock has been inserted successfully" {
                completion("The insertion was successful")
            } else {
                completion("Insertion failed !!!")
            }
        }
        task.resume()
    }
    
    // MARK: UPDATE PRODUCT
    func updateProduct(product: Product, completion: @escaping (String) -> Void) {
        var expiration:String = ""
        if let exp = product.expiration {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyy/MM/dd"
            expiration = formatter.string(from: exp)
        }
        let parameters: [String: Any] = [
            "id": product.id,
            "name": product.name,
            "code": product.code,
            "pricebuy": product.purchase,
            "pricesell": product.inStorePrice,
            "priceweb": product.websitePrice,
            "stock": product.inStoreStock,
            "expiration": expiration,
            "category": product.categoryId,
            "taxcat": product.taxId,
            "image": product.getImageString(),
            "woo_address": DatabaseService.shared.woo_address,
            "woo_key": DatabaseService.shared.woo_key,
            "woo_secret": DatabaseService.shared.woo_secret,
        ]
        let request = setRequest(service: "mobile_update", extendParams: parameters)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let responseString = getResponse(data, response, error)
            completion(responseString)
        }
        task.resume()
    }

    
    // MARK: GET PRODUCT FOR UPDATE VIEW
    func getProduct(code: String, completion: @escaping ([Product]) -> Void) {
        loadData(service: "mobile_product", extendParams: ["code": code], parseFunction: { data in
            parseJSON(data: data, mappingFunction: mapToProduct)
        }, completion: completion)
    }
    // Mapping dictionary for parseJSON
    func mapToProduct(jsonDict: NSDictionary) -> Product? {
        guard let id = jsonDict["ID"] as? String,
              let code = jsonDict["CODE"] as? String,
              let name = jsonDict["NAME"] as? String,
              let categoryid = jsonDict["CATEGORY"] as? String,
              let taxid = jsonDict["TAXCAT"] as? String,
              let pricebuy = Double(jsonDict["PRICEBUY"] as? String ?? "0"),
              let pricesell = Double(jsonDict["PRICESELL"] as? String ?? "0"),
              let priceweb = Double(jsonDict["PRICEWEB"] as? String ?? "0") else {
            return nil
        }
        return Product(id: id, code: code, name: name, categoryId: categoryid, taxId: taxid, purchase: pricebuy, inStorePrice: pricesell, websitePrice: priceweb)
    }
    
    
    // MARK: GET PRODUCT FOR INFO VIEW
    func getProductInfo(code: String, completion: @escaping ([Product]) -> Void) {
        loadData(service: "mobile_product_info", extendParams: ["code": code], parseFunction: { data in
            parseJSON(data: data, mappingFunction: mapToProductInfo)
        }, completion: completion)
    }
    // Mapping dictionary for parseJSON
    func mapToProductInfo(jsonDict: NSDictionary) -> Product? {
        guard let code = jsonDict["CODE"] as? String,
              let name = jsonDict["NAME"] as? String,
              let category = jsonDict["CNAME"] as? String,
              let pricesell = Double(jsonDict["PRICESELL"] as? String ?? "0"),
              let taxrate = Double(jsonDict["RATE"] as? String ?? "0"),
              let expirationStr = jsonDict["EXPIRATION"] as? String else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyy/MM/dd"
        let expiration = formatter.date(from: expirationStr)
        return Product(code: code, name: name, categoryName: category, taxRate: taxrate, inStorePrice: pricesell, expiration: expiration)
    }
    
    
    // MARK: GET STOCK
    func getStock(code: String, completion: @escaping ([Product]) -> Void) {
        loadData(service: "mobile_stock", extendParams: ["code": code], parseFunction: { data in
            parseJSON(data: data, mappingFunction: mapToStock)
        }, completion: completion)
    }
    // Mapping dictionary for parseJSON
    func mapToStock(jsonDict: NSDictionary) -> Product? {
        guard let stock = Int(jsonDict["STOCK"] as? String ?? "0"),
              let expirationStr = jsonDict["EXPIRATION"] as? String else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyy/MM/dd"
        let expiration = formatter.date(from: expirationStr)
        return Product(inStoreStock: stock, expiration: expiration)
    }
    
    
    // MARK: WOO API
    func getProductInfoUsingWooAPI(code: String, completion: @escaping ([Product]) -> Void) {
        let parameters: [String: Any] = [
            "code": code,
            "woo_address": DatabaseService.shared.woo_address,
            "woo_key": DatabaseService.shared.woo_key,
            "woo_secret": DatabaseService.shared.woo_secret,
        ]
        loadData(service: "mobile_product_wooapi", extendParams: parameters, parseFunction: { data in
            parseJSON(data: data, mappingFunction: mapToProductWooAPI)
        }, completion: completion)
    }
    // Mapping dictionary for parseJSON
    func mapToProductWooAPI(jsonDict: NSDictionary) -> Product? {
        guard let stockweb = Int(jsonDict["STOCK_QUANTITY"] as? String ?? "0"),
              let weight = Double(jsonDict["WEIGHT"] as? String ?? "0") else {
            return nil
        }
        return Product(websiteStock: stockweb, weight: weight)
    }
    
    
    // MARK: GET CATEGORIES
    func getCategoryTable(completion: @escaping ([Category]) -> Void) {
        loadData(service: "mobile_category", extendParams: [:], parseFunction: { data in
            parseJSON(data: data, mappingFunction: mapToCategory)
        }, completion: completion)
    }
    // Mapping dictionary for parseJSON
    func mapToCategory(jsonDict: NSDictionary) -> Category? {
        guard let id = jsonDict["ID"] as? String,
              let name = jsonDict["NAME"] as? String else {
            return nil
        }
        return Category(id: id, name: name)
    }

    
    // MARK: GET TAXES
    func getTaxTable(completion: @escaping ([Tax]) -> Void) {
        loadData(service: "mobile_tax", extendParams: [:], parseFunction: { data in
            parseJSON(data: data, mappingFunction: mapToTax)
        }, completion: completion)
    }
    // Mapping dictionary for parseJSON
    func mapToTax(jsonDict: NSDictionary) -> Tax? {
        guard let category = jsonDict["CATEGORY"] as? String,
              let name = jsonDict["NAME"] as? String,
              let rate = jsonDict["RATE"] as? String else {
            return nil
        }
        return Tax(id: category, name: name, rate: rate)
    }
    
    
    // MARK: CREATE HTTP REQUEST
    func setRequest(service: String, extendParams: [String: Any]? = nil)->URLRequest {
        // Check if there are any additional parameters
        var parameters = default_params
        if let extend = extendParams {
            // Mearge additional parameters to default db params
            parameters = default_params.merging(extend, uniquingKeysWith: { (current, _) in current })
        }
        // Create HTTP request
        let url = URL(string: "http://\(host_address)/service/\(service).php")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = parameters.percentEscaped().data(using: .utf8)
        return request
    }
    
    // MARK: GET HTTP RESPONSE
    func getResponse(_ data:Data?, _ response:URLResponse?, _ error:Error?)->String {
        
        guard let data = data,
            let response = response as? HTTPURLResponse,
            error == nil else { // check for fundamental networking error
            print("error", error ?? "Unknown error")
            return "Network problem"
        }

        guard (200 ... 299) ~= response.statusCode else { // check for http errors
            print("statusCode should be 2xx, but is \(response.statusCode)")
            print("response = \(response)")
            return "Wrong address"
        }
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("ResponseString = \(responseString)")
            return responseString
        }
        else {
            print("Cannot get responses")
            return "Cannot get responses"
        }
        
    }
    
    // MARK: DATA LOADER
    func loadData<T>(service: String, extendParams: [String: Any]?, parseFunction: @escaping (Data) -> [T], completion: @escaping ([T]) -> Void) {
        var locArray = [T]()
        let request = setRequest(service: service, extendParams: extendParams)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error loading data:", error)
                completion(locArray)
                return
            }
            
            if let data = data {
                locArray = parseFunction(data)
                completion(locArray)
            } else {
                print("No data received when loading data")
                completion(locArray)
            }
        }
        task.resume()
    }
    
    // MARK: JSON PARSER
    func parseJSON<T>(data: Data, mappingFunction: (NSDictionary) -> T?) -> [T] {
        var locArray = [T]()
        do {
            let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as! [NSDictionary]
            for jsonResult in jsonArray {
                if let loc = mappingFunction(jsonResult) {
                    locArray.append(loc)
                }
            }
        } catch let error as NSError {
            print(error)
        }
        return locArray
    }
    
}


