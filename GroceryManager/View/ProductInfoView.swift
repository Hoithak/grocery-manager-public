//
//  ScannerView.swift
//  GroceryManager
//
//  Created by Pranot Kotchakoon on 12/7/19.
//

import SwiftUI
import AVFoundation

struct ProductInfoView: View {
        
    // App variable
    @EnvironmentObject var userData: UserData
    @State var image:Image?
    @State private var isAlertPresent = false
    
    // Form variable
    @State private var name: String = "???"
    @State private var code: String = "???"
    @State private var category: String = "???"
    @State private var tax: String = "???"
    @State private var price: String = "???"
    @State private var total: String = "???"
    @State private var expirationText: String = "Unknown"
    

    var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            // Header
            HStack {
                Text("Product Infomation")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(COLOR_BLACK01)
                Spacer()
            }
            .padding(.top, 55)
            
            // Body View
            // Product details
            VStack (spacing: 15) {
                
                // Image
                HStack {
                    Spacer()
                    image?
                        .resizable()
                        .frame(width: 150, height: 150)
                        .foregroundColor(COLOR_GRAY01)
                        .cornerRadius(10)
                    Spacer()
                }
                .padding(.top, 15)
                
                // Name
                HStack {
                    Spacer()
                    Text(name)
                        .foregroundColor(COLOR_BLACK01)
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal, 10)
                
                Divider()
                
                // Barcode
                HStack {
                    Text("UPC")
                        .foregroundColor(COLOR_GRAY02)
                        .font(.title3)
                    Text(code)
                        .foregroundColor(COLOR_GRAY02)
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal, 30)
                
                // Category
                HStack {
                    Text("Catagory")
                        .foregroundColor(COLOR_GRAY02)
                        .font(.title3)
                    Text(category)
                        .foregroundColor(COLOR_GRAY02)
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal, 30)
                
                // Expiration
                HStack {
                    Text("Expiration")
                        .foregroundColor(COLOR_GRAY02)
                        .font(.title3)
                    Text(expirationText)
                        .foregroundColor(COLOR_GRAY02)
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal, 30)
                
                // Price & Taxes
                HStack {
                    Text("Before Tax")
                        .foregroundColor(COLOR_GRAY02)
                        .font(.title3)
                    Text(price)
                        .foregroundColor(COLOR_GRAY02)
                        .font(.title3)
                        .fontWeight(.bold)
                    Text(tax)
                        .foregroundColor(COLOR_GRAY02)
                        .font(.title3)
                    Spacer()
                }
                .padding(.horizontal, 30)
                
                
                Divider()
                
                HStack {
                    Spacer()
                    Text("Total:")
                        .foregroundColor(COLOR_BLACK01)
                        .font(.title)
                        .fontWeight(.bold)
                    Text(total)
                        .foregroundColor(COLOR_BLACK01)
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal, 10)
                
                Spacer()
                
            }
            .background(.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(COLOR_GRAY03, lineWidth: 1)
            )
            
            Spacer()
            
            // Submit Button
            HStack {
                Spacer()
                ButtonStyleA(
                    text: "Rescan",
                    icon: "barcode.viewfinder",
                    clicked: self.rescanBarcode)
                .modifier(SubmitButtonModifier())
                Spacer()
            }
            
            Spacer()
            
        }
        .modifier(MainPanelModifier())
        .onAppear {
            self.loadProductInfo()
            self.loadImage(code: self.userData.PRODUCT_CODE)
        }
        .alert(isPresented: $isAlertPresent) {
            Alert(title: Text("Product not found !!!"), message: Text("Re-scan other products or add them to the system"), dismissButton: .default(Text("OK")){
            })
        }
    }
    

    func rescanBarcode() {
        self.userData.ACTIVE_SCREEN = .scan
    }
    

    func loadImage(code:String) {
        DatabaseService.shared.getProductImage(code: self.userData.PRODUCT_CODE) { dbimage in
            if let image = dbimage {
                self.image = Image(uiImage: image)
            }
            else {
                self.image = Image(systemName: "cube.fill")
            }
        }
    }
    

    func loadProductInfo() {
        // Show loading view
        self.userData.LOADING_SCREEN_PRESENT = true
        
        DatabaseService.shared.getProductInfo(code: self.userData.PRODUCT_CODE){ products in
            if (products.count == 1) {
                self.name = products[0].name
                self.code = products[0].code
                self.category = products[0].categoryName
                self.tax = String(format: "(Tax %.0f%%)", products[0].taxRate * 100)
                self.price = String(format: "$%.2f", products[0].inStorePrice)
                self.total = String(format: "$%.2f", products[0].inStorePrice * (1 + products[0].taxRate ))
                if let date = products[0].expiration {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMM d, yyyy"
                    self.expirationText = formatter.string(from: date)
                }
            }
            else {
                self.isAlertPresent = true
            }
            // Turn off loading view
            DispatchQueue.main.async {
                self.userData.LOADING_SCREEN_PRESENT = false
            }
        }
        
    }
    
        
}

// MARK: PREVIEW
struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        ProductInfoView().environmentObject(UserData())
    }
}
