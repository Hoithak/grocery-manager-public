//
//  ProductListView.swift
//  GroceryManager
//
//  Created by Pranot Kotchakoon on 1/30/20.
//

import SwiftUI

struct ProductRowView: View {
    
    var result: Result
    @EnvironmentObject var userData: UserData
    @State private var image: Image?
    
    var body: some View {
        
        Button {
            userData.PRODUCT_CODE = result.code
            userData.PRODUCT_SUBMIT_MODE = .update
            userData.PRODUCT_LOADED = false
            userData.PREVIOUS_SCREEN = .search_result
            userData.ACTIVE_SCREEN = .update
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(result.name)
                        .font(.headline)
                        .foregroundColor(COLOR_BLACK01)
                    Text(result.code)
                        .font(.subheadline)
                        .foregroundColor(COLOR_GRAY01)
                }
                Spacer()
                image?
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(COLOR_GRAY02)
                    .cornerRadius(5)
            }
        }
        .frame(height: 40)
        .padding()
        .foregroundColor(.white)
        .background(.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(COLOR_GRAY02, lineWidth: 1)
        )
        .onAppear {
            self.loadImage(code: self.result.code)
        }
    }
    
    
    // MARK: [DB Load image] -
    func loadImage(code:String) {
        DatabaseService.shared.getProductImage(code: code) { dbimage in
            DispatchQueue.main.async {
                if let image = dbimage {
                    self.image = Image(uiImage: image)
                }
                else {
                    self.image = Image(systemName: "cube.fill")
                }
            }
        }
    }
    
}

// MARK: PREVIEW
struct ProductRowView_Previews: PreviewProvider {
    static var previews: some View {
        ProductRowView(result: Result())
    }
}
