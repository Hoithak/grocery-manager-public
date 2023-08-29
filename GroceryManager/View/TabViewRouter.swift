//
//  Router.swift
//  GroceryManager
//
//  Created by Pranot Kotchakoon on 1/7/22.
//

import SwiftUI

class TabBarViewRouter: ObservableObject {
    @Published var currentItem: TabBarModel = .home
    @EnvironmentObject var userData: UserData
}

enum TabBarModel: CaseIterable {
            
    case home
    case add
    case scan
    case search
    case setting
    
    var imageName: String {
        switch self {
        case .home: return "house.fill"
        case .add: return "plus.circle"
        case .scan: return "barcode.viewfinder"
        case .search: return "magnifyingglass"
        case .setting: return "gearshape"
        }
    }
    
    var activeScreen: ActiveScreen {
        switch self {
        case .home: return ActiveScreen.home
        case .add: return ActiveScreen.add
        case .scan: return ActiveScreen.scan
        case .search: return ActiveScreen.search
        case .setting: return ActiveScreen.setting
        }
    }
    
}

struct TabBarIcon: View {
    
    let viewModel: TabBarModel
    @EnvironmentObject var userData: UserData
        
    var body: some View {
        Button {
            userData.ACTIVE_SCREEN = viewModel.activeScreen
            switch viewModel.activeScreen {
            case .scan:
                userData.SCAN_MODE = .update_mode
                userData.PREVIOUS_SCREEN = .scan
                userData.PRODUCT_SUBMIT_MODE = .update
                userData.PRODUCT_LOADED = false
            case .setting:
                userData.TABBAR_PRESENT = false
            default:
                print("Hit Tab")
            }
        } label: {
            Image(systemName: viewModel.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 22, height: 22)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 25)
                .foregroundColor(viewModel.activeScreen == userData.ACTIVE_SCREEN ? COLOR_BLACK01 : COLOR_GRAY02)
        }
    }
}
