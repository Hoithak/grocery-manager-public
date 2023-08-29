//
//  HomeView.swift
//  GroceryManager
//
//  Created by Pranot Kotchakoon on 12/11/19.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var userData: UserData

    var body: some View {
        
        VStack(alignment: .center, spacing: 15) {
            Spacer()
            HStack {
                Text("Home")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(COLOR_GREEN01)
                .padding(.top, 30)
                Spacer()
            }
            .padding(.bottom, 30)
            HomeButtonView(title: "Product Info", subtitle: "Show product details", icon: "info.circle", clicked: self.setActiveProductInfoView)
            HomeButtonView(title: "Add New Product", subtitle: "Insert manually using the UPC", icon: "plus.circle", clicked: self.setActiveAddNewProductView)
            HomeButtonView(title: "Update", subtitle: "Existed product details", icon: "repeat.circle", clicked: self.setActiveUpdateProductView)
            HomeButtonView(title: "Search", subtitle: "By using keyword", icon: "magnifyingglass", clicked: self.setActiveProductSearchView)
            HomeButtonView(title: "Setting", subtitle: "Database and REST API", icon: "gearshape", clicked: self.setActiveAppSettingView)
            Spacer()
        }
        .modifier(MainPanelModifier())
        .onAppear {
            self.userData.PRODUCT_LOADED = false
        }
    }
    
    func setActiveProductInfoView() {
        userData.SCAN_MODE = .read_mode
        userData.PREVIOUS_SCREEN = .scan
        userData.ACTIVE_SCREEN = .scan
    }
    
    func setActiveAddNewProductView() {
        userData.SCAN_MODE = .update_mode
        userData.PREVIOUS_SCREEN = .scan
        userData.ACTIVE_SCREEN = .add
    }
    
    func setActiveUpdateProductView() {
        userData.SCAN_MODE = .update_mode
        userData.PRODUCT_SUBMIT_MODE = .update
        userData.PRODUCT_LOADED = false
        userData.PREVIOUS_SCREEN = .scan
        userData.ACTIVE_SCREEN = .scan
    }
    
    func setActiveProductSearchView() {
        userData.ACTIVE_SCREEN = .search
        userData.SCAN_MODE = .update_mode
    }
    
    func setActiveAppSettingView() {
        userData.ACTIVE_SCREEN = .setting
        userData.TABBAR_PRESENT = false
    }
    
}

// MARK: PREVIEW
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(UserData())
    }
}
