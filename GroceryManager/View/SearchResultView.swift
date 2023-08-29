//
//  SearchResultView.swift
//  GroceryManager
//
//  Created by Pranot Kotchakoon on 1/30/20.
//

import SwiftUI
import Combine

struct SearchResultView: View {
    
    // App variable
    @EnvironmentObject var userData: UserData
    @State private var isAlertPresent = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var results = [Result]()
    
    var body: some View {
   
        VStack(alignment: .leading, spacing: 10) {
            
            Spacer()

            // Header
            HStack {
                Text("Search Result")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(COLOR_BLACK01)
                Spacer()
                Button {
                    userData.ACTIVE_SCREEN = .search
                } label: {
                    Image(systemName: "arrowshape.turn.up.backward.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                        .foregroundColor(COLOR_GREEN01)
                }
                
            }
            .padding(.top, 55)
            
            // Result list
            ScrollView {
                VStack {
                    ForEach(results) { result in
                        ProductRowView(result: result)
                    }
                }
            }
            
            Spacer()

        }
        .frame(maxWidth: .infinity)
        .modifier(MainPanelModifier())
        .alert(isPresented: $isAlertPresent) {
            Alert(title: Text(self.alertTitle), message: Text(self.alertMessage), dismissButton: .default(Text("OK")){
                self.userData.ACTIVE_SCREEN = .search
            })
        }
        .onAppear {
            self.userData.PRODUCT_LOADED = false
            self.search()
        }

    }
    
    // MARK: SEARCH
    func search() {
        // Show loading view
        self.userData.LOADING_SCREEN_PRESENT = true
        
        var product = Product()
        product.code = userData.SEARCH_CODE
        product.name = userData.SEARCH_NAME
        if (userData.SEARCH_SELECTED_CATEGORY != -1){
            product.categoryId = self.userData.CATEGORY[userData.SEARCH_SELECTED_CATEGORY].id
        }
        
        DatabaseService.shared.searchProduct(product: product){ results in
            if (results.count == 0) {
                self.alertTitle = "Product not found"
                self.alertMessage = "Please use other keywords"
                self.isAlertPresent = true
            }
            else {
                self.results = results
            }
            // Hide loding view
            DispatchQueue.main.async {
                self.userData.LOADING_SCREEN_PRESENT = false
            }
        }
    }
    
}

// MARK: PREVIEW
struct SearchResultView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultView().environmentObject(UserData())
    }
}
