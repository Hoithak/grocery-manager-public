//
//  PrintingService.swift
//  GroceryManager
//
//  Created by Pranot Kotchakoon on 8/21/23.
//

import Foundation

struct PrinterService {
    static var shared = PrinterService()
    
    func printStandardLabel(name: String, price: String, code: String, completion: @escaping (String) -> Void) {
        //  Send a printing request to the API to print a product label for placement on the shelf.
        //  The label will display the product name, selling price, UPC, and barcode.
        let defaults = UserDefaults.standard
        let url = URL(string: "http://\(defaults.string(forKey: "dbip") ?? "")/service/mobile_printlabel.php")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let parameters: [String: Any] = [
            "name": name,
            "price": price,
            "code": code
        ]
        request.httpBody = parameters.percentEscaped().data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let responseString = getResponse(data, response, error)
            if responseString == "Print command was sent" {
                completion(responseString)
            } else {
                completion("Error printing label")
            }
        }
        task.resume()
    }
    
    // Get HTTP response
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
    
    
}
