//
//  UpdateProductView.swift
//  GroceryManager
//
//  Created by Pranot Kotchakoon on 12/14/19.
//

import SwiftUI
import Combine

struct UpdateProductView: View {
    
    @EnvironmentObject var userData: UserData
    @ObservedObject var iEnhance = ImageProcessing()
    @State var isActionSheetPresent:Bool = false
    @State var actionSheetMode:UpdateActionSheet = .none // .none, .photo, .margin
    @State var isImagePickerPresent:Bool = false
    @State var isImageEnhancingPresent:Bool = true
    @State var image:Image? = Image(systemName: "cube.box.fill")
    @State var uiimage:UIImage? = nil
    @State var imageSourceType:Int = 0  // 0: Camera, 1: Photo gallery
    @State private var isAlertDialogPresent = false
    @State private var alertDialogButton:String = "OK"
    @State private var alertDialogTitle = ""
    @State private var alertDialogMessage = ""
    @State private var insertProductSuccess:Bool = false
    @State private var isExpirationFormPresent:Bool = false
    @State private var isPriceCalculationPresent = false
     
    // Form variable
    @State private var productCodeForm:String = ""
    @State private var productWeightOnWebsiteForm:String = ""
    @State private var productStockQuantityOnWebsiteForm:String = ""
    @State private var productNameForm:String = ""
    @State private var productSellPriceInStoreForm:String = ""
    @State private var productSellPriceOnWebsiteForm:String = ""
    @State private var productPurchasePriceForm:String = ""
    @State private var productStockQuantityInStore:String = ""
    @State private var productExpirationDate:Date = Date()
    @State private var selectedProductCategoryIndex = -1 // -1 means unselected
    @State private var selectedProductTaxeIndex = -1 // -1 means unselected
    
    @State private var productWeightOnWebsite:Double = 0.00
    @State private var productStockQuantityOnWebsite:Int = 0
    @State private var enableAutoGenerateWebPriceButton = false
    

    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            // Header
            HStack {
                Text("Update Product")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(COLOR_BLACK01)
                Spacer()
                Button {
                    userData.ACTIVE_SCREEN = userData.PREVIOUS_SCREEN
                } label: {
                    Image(systemName: "arrowshape.turn.up.backward.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                        .foregroundColor(COLOR_GREEN01)
                }
                
            }
            .padding(.top, 55)
            
            
            // Body View

            VStack {
                
                // Product detail form
                VStack (spacing: 8) {
                    
                    // Image row
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "qrcode")
                                    .foregroundColor(COLOR_GRAY02)
                                Text(productCodeForm)
                                    .font(.subheadline)
                                    .foregroundColor(COLOR_GRAY02)
                            }
                            HStack {
                                Image(systemName: "scalemass.fill")
                                    .foregroundColor(COLOR_GRAY02)
                                Text("\(productWeightOnWebsiteForm) lb")
                                    .font(.subheadline)
                                    .foregroundColor(COLOR_GRAY02)
                            }
                            HStack {
                                Image(systemName: "shippingbox.fill")
                                    .foregroundColor(COLOR_GRAY02)
                                Text("\(productStockQuantityOnWebsiteForm) on web")
                                    .font(.subheadline)
                                    .foregroundColor(COLOR_GRAY02)
                            }
                        }
                        .padding(.leading, 15)
                        
                        Spacer()
                        
                        image?
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(COLOR_GRAY01)
                            .cornerRadius(5)
                            .padding(.vertical, 20)
                            .padding(.trailing, 30)
                            .overlay(
                                CameraButtonView(showActionSheet: $isActionSheetPresent, actionSheetMode: $actionSheetMode)
                                    .offset(x: 30, y: 45)
                            )
                    }
                    
                    
                    // Name, Category, Tax
                    Group {
                        TextInputTypeB(value: $productNameForm, topic: "Name", text: "Enter product name", width: .infinity, inputWidth: .infinity)
                        if (selectedProductCategoryIndex == -1) {
                            PickerTypeB(selected: $selectedProductCategoryIndex, topic: "Category", values: self.userData.getAllCategoryName(), width: .infinity, defaultText: "???")
                                .padding(.top, 5)
                        }
                        else {
                            PickerTypeB(selected: $selectedProductCategoryIndex, topic: "Category", values: self.userData.getAllCategoryName(), width: .infinity)
                                .padding(.top, 5)
                        }
                        if (selectedProductTaxeIndex == -1) {
                            PickerTypeB(selected: $selectedProductTaxeIndex, topic: "Tax Type", values: self.userData.getAllTaxName(), width: .infinity, defaultText: "???")
                                .padding(.top, 5)
                        }
                        else {
                            PickerTypeB(selected: $selectedProductTaxeIndex, topic: "Tax Type", values: self.userData.getAllTaxName(), width: .infinity)
                                .padding(.top, 5)
                        }
                    }
                    
                    Divider()
                        .padding(.top, 10)
                    
                    // Price
                    HStack (spacing: 0) {
                        
                        // Purchase Price
                        NumberInputTypeB(value: $productPurchasePriceForm, topic: "Purchase", text: "0.00", inputWidth: 60)
                        
                        VStack {
                            
                            // In-Store Price
                            HStack (spacing: 0) {
                                Spacer()
                                NumberInputTypeB(value: $productSellPriceInStoreForm, topic: "Store", text: "0.00", inputWidth: 60)
                                ZStack {
                                    Button(action: {
                                        self.isActionSheetPresent.toggle()
                                        self.actionSheetMode = .margin
                                    }){
                                        Image(systemName: "square.grid.3x3.square")
                                            .resizable()
                                            .frame(width: 24, height: 25)
                                            .foregroundColor(COLOR_GREEN01)
                                            .padding(.trailing, 10)
                                    }
                                }
                            }
                            
                            // Website Price
                            HStack (spacing: 0) {
                                Spacer()
                                NumberInputTypeB(value: $productSellPriceOnWebsiteForm, topic: "Web", text: "0.00", inputWidth: 60)
                                Button(action: {
                                    generateProductSellingPriceOnWebsite()
                                }){
                                    Image(systemName: "square.grid.3x3.square")
                                        .resizable()
                                        .frame(width: 24, height: 25)
                                        .foregroundColor(enableAutoGenerateWebPriceButton ? COLOR_GREEN01 : COLOR_GRAY02)
                                        .padding(.trailing, 10)
                                }
                                .disabled(enableAutoGenerateWebPriceButton == false)
                            }
                            
                        }
                        
                    }
                    .frame(maxWidth: .infinity)
                    
                    Divider()
                        .padding(.bottom, 10)
                    
                    // Stock & expiration date
                    HStack (spacing: 0) {
                        NumberInputTypeB(value: $productStockQuantityInStore, topic: "Stock", text: "0", inputWidth: 65)
                            .padding(.leading, 0)
                            .ignoresSafeArea(.keyboard)
                        Spacer()
                        Text("Expiration")
                            .foregroundColor(COLOR_GRAY02)
                            .padding(.trailing, 10)
                        Toggle("", isOn: $isExpirationFormPresent)
                            .padding(.trailing, 10)
                            .labelsHidden()
                            .tint(COLOR_GREEN01)
                    }
                    
                    if isExpirationFormPresent {
                        HStack (spacing: 0) {
                            Spacer()
                            Text("Select Date")
                                .foregroundColor(COLOR_GRAY02)
                                .padding(.trailing, 10)
                            DatePicker("", selection: $productExpirationDate, displayedComponents: .date)
                                .accentColor(COLOR_GREEN01)
                                .foregroundColor(COLOR_BLACK03)
                                .labelsHidden()
                                .padding(.trailing, 10)
                        }
                        .padding(.top, 15)
                    }
                    
                    Spacer()

                }
                .frame(maxWidth: .infinity)
                .background(.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(COLOR_GRAY03, lineWidth: 1)
                )

            }
            
             
            // Submit Button
            HStack {
                ButtonStyleA(text: "Label", icon: "printer.fill", clicked: self.printProductLabel)
                    .modifier(OptionButtonModifier())
                Spacer()
                ButtonStyleA(
                    text: self.userData.PRODUCT_SUBMIT_MODE == .insert ? "Insert" : "Update",
                    icon: "externaldrive.connected.to.line.below.fill",
                    clicked: self.handleSubmitButtonClick)
                    .modifier(SubmitButtonModifier())
            }
            
            Spacer()
        }
        .modifier(MainPanelModifier())
        .actionSheet(isPresented: $isActionSheetPresent) {
            if self.actionSheetMode == .photo {
                return ActionSheet(title: Text("Select product image"), message: Text("Use the camera or select an image from the photo gallery"), buttons: [
                    ActionSheet.Button.default(Text("Camera"), action: {
                        self.imageSourceType = 0
                        self.isImagePickerPresent.toggle()
                    }),
                    ActionSheet.Button.default(Text("Photo gallery"), action: {
                        self.imageSourceType = 1
                        self.isImagePickerPresent.toggle()
                    }),
                    ActionSheet.Button.cancel()])
            } else {
                return ActionSheet(title: Text("Calculate the in-store selling price"), message: Text("Please select a margin from the options below"), buttons: self.userData.LOCAL_STORE_PROFIT.map { margin in
                        .default(Text(String(format: "%.0f %%", margin*100))) {
                            let storePrice = (Double(self.productPurchasePriceForm) ?? 0.00) * (1 + margin)
                            self.productSellPriceInStoreForm = String(format: "%.2f", Utility.shared.convertToStoreStandardPriceFormat(inputPrice: storePrice))
                        }
                } + [.cancel()]
                )
            }
        }
        .sheet(isPresented: $isImagePickerPresent) {
            ImagePicker(isVisible: self.$isImagePickerPresent, isEnhance: self.$isImageEnhancingPresent, image: self.$image, uiimage: self.$userData.PRODUCT.image, sourceType: self.imageSourceType)
        }
        .onAppear {
            switch userData.PRODUCT_SUBMIT_MODE {
            case .insert:
                self.productCodeForm = self.userData.PRODUCT_CODE
                self.alertDialogTitle = "Add New Product"
                self.alertDialogMessage = "Please enter the product information into the form below"
                self.alertDialogButton = "OK"
                self.userData.PRODUCT.image = nil
                self.isAlertDialogPresent = true
            case .update:
                if !self.userData.PRODUCT_LOADED {
                    self.loadProduct()
                }
            case .delete:
                print("Delete")
            }
        }
        
        // Alert dialog controller
        .alert(isPresented: $isAlertDialogPresent) {
            Alert(title: Text(self.alertDialogTitle), message: Text(self.alertDialogMessage), dismissButton: .default(Text(self.alertDialogButton)){
                switch userData.PRODUCT_SUBMIT_MODE {
                case .insert:
                    if (self.insertProductSuccess) {
                        self.loadProduct()
                        self.userData.PRODUCT_SUBMIT_MODE = .update
                    }
                case .update:
                    self.loadProductInfoUsingWooAPI()
                case .delete:
                    print("Delete Product")
                }
            })
        }
    }
    
     
    // MARK: SUBMIT BUTTON CLICK
    func handleSubmitButtonClick() {
        switch userData.PRODUCT_SUBMIT_MODE {
        case .insert:
            if (self.selectedProductCategoryIndex != -1 && self.selectedProductTaxeIndex != -1) {
                self.insertNewProduct()
            }
            else {
                self.alertDialogTitle = "Validation Failed"
                self.alertDialogMessage = "Please provide CATEGORY and TAX before submit"
                self.alertDialogButton = "OK"
                self.isAlertDialogPresent = true
            }
        default:
            if let webPrice = Double(productSellPriceOnWebsiteForm) {
                if (webPrice <= 0) {
                    self.generateProductSellingPriceOnWebsite()
                }
            }
            self.updateProduct()
        }
    }
    
    
    // MARK: GENERATE WEB PRICE
    func generateProductSellingPriceOnWebsite() {
        if var purchasePrice = Double(productPurchasePriceForm), let sellPrice = Double(productSellPriceInStoreForm) {
            if (purchasePrice <= 0) {
                //  Calculate the purchase price based on the assumption that
                //  the selling price is derived from the purchase price plus a 25% profit margin
                purchasePrice = sellPrice / (1 + self.userData.LOCAL_STORE_PROFIT[0])
            }
            let shippingCost = Utility.shared.calculateShippingCostPerProductUnit(
                purchasePrice: purchasePrice,
                profitMargin: self.userData.ONLINE_PROFIT,
                productWeight: self.productWeightOnWebsite,
                minimumFreeShipping: self.userData.MINIMUM_FREE_SHIPPING,                
                shippingCost: 0,
                shippingCostTable: self.userData.SHIPPING_TABLE_PRICE)
            
            let websiteSellingPrice = purchasePrice + (purchasePrice * self.userData.ONLINE_PROFIT) + shippingCost
            productSellPriceOnWebsiteForm = String(format: "%.2f", Utility.shared.convertToStoreStandardPriceFormat(inputPrice: websiteSellingPrice))
        }
    }
    
    // MARK: PRINT LABEL
    func printProductLabel() {
        self.userData.LOADING_SCREEN_PRESENT = true
        
        PrinterService.shared.printStandardLabel(name: cleanText(text: self.productNameForm), price: self.productSellPriceInStoreForm, code: self.productCodeForm) { result in
            self.alertDialogTitle = "Print Label"
            self.alertDialogMessage = result
            self.alertDialogButton = "OK"
            self.isAlertDialogPresent = true
            DispatchQueue.main.async {
                self.userData.LOADING_SCREEN_PRESENT = false
            }
        }
        
    }
    
    // MARK: INSERT PRODUCT
    func insertNewProduct() {
        
        // Show loading view
        self.userData.LOADING_SCREEN_PRESENT = true
        
        var product = Product()
        product.name = cleanText(text: self.productNameForm)
        product.code = self.productCodeForm
        product.purchase = Double(self.productPurchasePriceForm) ?? 0
        product.inStorePrice = Double(self.productSellPriceInStoreForm) ?? 0
        product.websitePrice = Double(self.productSellPriceOnWebsiteForm) ?? 0
        product.inStoreStock = Int(self.productStockQuantityInStore) ?? 0
        product.categoryId = self.userData.CATEGORY[selectedProductCategoryIndex].id
        product.taxId = self.userData.TAX[selectedProductTaxeIndex].id
        product.image = self.userData.PRODUCT.image
        if self.isExpirationFormPresent {
            product.expiration = self.productExpirationDate
        }
        
        DatabaseService.shared.insertProduct(product: product) { result in
            self.alertDialogTitle = "Insert New Product"
            self.alertDialogMessage = result
            self.alertDialogButton = "OK"
            
            if result == "The insertion was successful" {
                self.insertProductSuccess = true
                self.alertDialogMessage = "Successfully !!!"
            }
            else {
                self.insertProductSuccess = false
            }
            self.isAlertDialogPresent = true
            self.loadProduct()
            
            DispatchQueue.main.async {
                self.userData.PRODUCT_SUBMIT_MODE = .update
                self.userData.LOADING_SCREEN_PRESENT = false
            }
        }
        
    }
    
    // MARK: UPDATE PRODUCT
    func updateProduct() {

        // Loading View
        self.userData.LOADING_SCREEN_PRESENT = true
        
        var product = Product()
        product.id = self.userData.PRODUCT.id
        product.name = cleanText(text:self.productNameForm)
        product.code = self.productCodeForm
        product.purchase = Double(self.productPurchasePriceForm) ?? 0
        product.inStorePrice = Double(self.productSellPriceInStoreForm) ?? 0
        product.websitePrice = Double(self.productSellPriceOnWebsiteForm) ?? 0
        product.inStoreStock = Int(self.productStockQuantityInStore) ?? 0
        product.categoryId = self.userData.CATEGORY[selectedProductCategoryIndex].id
        product.taxId = self.userData.TAX[selectedProductTaxeIndex].id
        product.image = self.userData.PRODUCT.image
        if self.isExpirationFormPresent {
            product.expiration = self.productExpirationDate
        }
        else {
            product.expiration = nil
        }
        
        DatabaseService.shared.updateProduct(product: product) { result in
            self.alertDialogTitle = "Update Result"
            self.alertDialogMessage = result
            self.alertDialogButton = "OK"
            self.isAlertDialogPresent = true
            DispatchQueue.main.async {
                self.userData.LOADING_SCREEN_PRESENT = false
            }
        }
            
    }
    
    // MARK: LOAD IMAGE
    func loadProductImage() {
        DatabaseService.shared.getProductImage(code: self.userData.PRODUCT_CODE) { dbimage in
            if let image = dbimage {
                self.image = Image(uiImage: image)
            }
            else {
                self.image = Image(systemName: "cube.fill")
            }
            DispatchQueue.main.async {
                self.userData.PRODUCT.image = dbimage
            }
        }
    }
        
    // MARK: LOAD PRODUCT
    func loadProduct() {
        
        // Show loading view
        DispatchQueue.main.async {
            self.userData.LOADING_SCREEN_PRESENT = true
        }
        
        // Load product info from database by product code
        DatabaseService.shared.getProduct(code: self.userData.PRODUCT_CODE){ products in
            if (products.count == 1) {
                self.productNameForm = products[0].name
                self.productCodeForm = products[0].code
                self.selectedProductCategoryIndex = self.userData.getCategoryIndexByCategoryName(name: products[0].categoryId)
                self.selectedProductTaxeIndex = self.userData.getTaxIndexByTaxName(name: products[0].taxId)
                self.productPurchasePriceForm = String(format: "%.2f", products[0].purchase)
                self.productSellPriceInStoreForm = String(format: "%.2f", products[0].inStorePrice)
                self.productSellPriceOnWebsiteForm = String(format: "%.2f", products[0].websitePrice)
                DispatchQueue.main.async {
                    self.userData.PRODUCT = products[0]
                    self.userData.PRODUCT_SUBMIT_MODE = .update
                }
                print(products[0].id)
            }
            else if (products.count == 0) {
                self.productCodeForm = self.userData.PRODUCT_CODE
                self.alertDialogTitle = "Product Not Found !!!"
                self.alertDialogMessage = "Please fill the form to insert it as a new product"
                self.alertDialogButton = "OK"
                self.isAlertDialogPresent = true
                self.selectedProductCategoryIndex = -1
                self.selectedProductTaxeIndex = -1
                DispatchQueue.main.async {
                    self.userData.PRODUCT_SUBMIT_MODE = .insert
                }
            }
            else {
                print("Cannot get product data")
            }
            
            self.loadProductImage()
            self.loadProductStock()
            self.loadProductInfoUsingWooAPI()
            DispatchQueue.main.async {
                self.userData.PRODUCT_LOADED = true
                self.userData.LOADING_SCREEN_PRESENT = false
            }
        }

    }
    
    
    // MARK: LOAD STOCK
    func loadProductStock() {
        DatabaseService.shared.getStock(code: self.userData.PRODUCT_CODE){ products in
            if (products.count == 1) {
                self.productStockQuantityInStore = "\(products[0].inStoreStock)"
                if let date = products[0].expiration {
                    self.isExpirationFormPresent = true
                    self.productExpirationDate = date
                }
                DispatchQueue.main.async {
                    self.userData.PRODUCT.inStoreStock = products[0].inStoreStock
                    self.userData.PRODUCT.expiration = products[0].expiration
                }
            }
            else {
                self.isExpirationFormPresent = false
            }
        }
    }
    

    // MARK: LOAD PRODUCT USING WOO API
    func loadProductInfoUsingWooAPI() {
        DatabaseService.shared.getProductInfoUsingWooAPI(code: self.userData.PRODUCT_CODE){ products in
            if (products.count == 1) {
                self.productWeightOnWebsite = products[0].weight
                self.productStockQuantityOnWebsite = products[0].websiteStock
                self.productWeightOnWebsiteForm = "\(self.productWeightOnWebsite)"
                self.productStockQuantityOnWebsiteForm = "\(self.productStockQuantityOnWebsite)"
                self.enableAutoGenerateWebPriceButton = true
            }
            else {
                print("Cannot get product from woo-api")
            }
        }
    }
    
    // MARK: CLEAN TEXT
    func cleanText(text: String) -> String {
        //  Filtering out all characters
        //  that are not present in the set of "okay" characters
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890_")
        return String(text.filter {okayChars.contains($0) })
    }
    
}

// MARK: PREVIEW
struct UpdateView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateProductView().environmentObject(UserData())
    }
}
