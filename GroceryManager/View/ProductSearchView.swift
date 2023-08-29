//
//  SearchView.swift
//  GroceryManager
//
//  Created by Pranot Kotchakoon on 1/29/20.
//

import SwiftUI
import Combine

struct ProductSearchView: View {
    
    @EnvironmentObject var userData: UserData
    
    // Form variable
    @State private var codeText:String = ""
    @State private var nameText:String = ""
    @State private var selectedCategory = -1 // -1 means all categories
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 10) {
            
            Spacer()

            // Header
            HStack {
                Text("Search")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(COLOR_BLACK01)
                .padding(.top, 55)
                Spacer()
            }
            
            // Subheader
            HStack {
                Text("By using keywords such as product code, name, or category")
                    .font(.subheadline)
                .foregroundColor(COLOR_GRAY01)
                Spacer()
            }
            
            // Input
            HStack {
                Spacer()
                VStack(spacing: 10) {
                    InputNumberStyleA(value: $codeText, topic: "Code", width: 300, inputWidth: 200)
                    TextInputTypeA(value: $nameText, topic: "Name", width: 300, inputWidth: 200)
                    PickerTypeA(
                        selected: $selectedCategory,
                        topic: "Category",
                        values: self.userData.getAllCategoryName(),
                        width: 300,
                        defaultText: "All Categories")
                }
                Spacer()
            }
            .padding(.top, 35)
            
            HStack {
                Spacer()
                ButtonStyleA(text: "Clear", clicked: self.clear, width: 100)
                    .modifier(CancelButtonModifier())
                Spacer()
                ButtonStyleA(text: "Search", clicked: self.search, width: 100)
                    .modifier(SubmitButtonModifier())
                Spacer()
            }
            .padding(.top, 50)
            
            Spacer()
        }
        .padding(.bottom, 50)
        .modifier(MainPanelModifier())
        .onAppear {
            self.loadPreviousKeyword()
        }
    }
    
    
    func loadPreviousKeyword() {
        self.codeText = userData.SEARCH_CODE
        self.nameText = userData.SEARCH_NAME
        self.selectedCategory = userData.SEARCH_SELECTED_CATEGORY
    }
    
    
    func search() {
        userData.SEARCH_CODE = self.codeText
        userData.SEARCH_NAME = self.nameText
        userData.SEARCH_SELECTED_CATEGORY = self.selectedCategory
        userData.ACTIVE_SCREEN = .search_result
        userData.PREVIOUS_SCREEN = .search
    }
    
    
    func clear(){
        codeText = ""
        nameText = ""
        selectedCategory = -1
    }
    
}

// MARK: PREVIEW
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        ProductSearchView().environmentObject(UserData())
    }
}
