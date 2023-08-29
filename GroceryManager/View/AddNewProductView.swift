//
//  NewView.swift
//  GroceryManager
//
//  Created by Pranot Kotchakoon on 2/18/20.
//

import SwiftUI

struct AddNewProductView: View {
    
    @EnvironmentObject var userData: UserData
    @State private var isAlertPresent = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var productCode:String = ""
    
    var body: some View {
  
        VStack(alignment: .center, spacing: 10) {
            
            Spacer()
            
            HStack {
                Text("Add Product")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(COLOR_BLACK01)
                    .padding(.top, 55)
                Spacer()
            }
            
            HStack {
                Text("Manually insert a new product using a UPC code")
                    .font(.subheadline)
                    .foregroundColor(COLOR_GRAY01)
                Spacer()
            }
            
            InputNumberStyleA(value: $productCode, topic: "UPC", text: "000000", width: 300, inputWidth: 200)
                .padding(.top, 35)
            
            HStack {
                Spacer()
                ButtonStyleA(text: "Back", clicked: self.backToHomeView, width: 100)
                    .modifier(CancelButtonModifier())
                Spacer()
                ButtonStyleA(text: "Add", clicked: self.addNewProduct, width: 100)
                    .modifier(SubmitButtonModifier())
                Spacer()
            }
            .padding(.top, 50)
            
            Spacer()
        }
        .padding(.bottom, 50)
        .modifier(MainPanelModifier())
        .alert(isPresented: $isAlertPresent) {
            Alert(title: Text(self.alertTitle), message: Text(self.alertMessage), dismissButton: .default(Text("Ok")){
            })
        }
    }
    
    func addNewProduct() {
        self.userData.PRODUCT_LOADED = false
        self.userData.PRODUCT_CODE = self.productCode
        self.userData.PREVIOUS_SCREEN = .add
        self.userData.PRODUCT_SUBMIT_MODE = .insert
        self.userData.ACTIVE_SCREEN = .update
    }
    
    func backToHomeView() {
        self.userData.ACTIVE_SCREEN = .home
    }
}

// MARK: PREVIEW
struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewProductView().environmentObject(UserData())
    }
}
