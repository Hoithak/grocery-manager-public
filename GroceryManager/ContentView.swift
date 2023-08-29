//
//  ContentView.swift
//  GroceryManager
//
//  Created by Pranot Kotchakoon on 12/7/19.
//

import SwiftUI
import Combine

// MARK: COLOR THEME
// Green color sets
let COLOR_GREEN00 = Color(hex: "7AA93C")    // Website (Theme: 5BC43A)
let COLOR_GREEN01 = Color(hex: "5BC43A")    // Button background & Text 5E9D2B

// Gray color sets
let COLOR_GRAY01 = Color(hex: "676C72")     // Icon & Text
let COLOR_GRAY02 = Color(hex: "C6C8C9")     // Tab non-active, Tab border, Cancel button border
let COLOR_GRAY03 = Color(hex: "F3F3F4")     // Background
let COLOR_GRAY04 = Color(hex: "F8F8F8")     // Panel background
let COLOR_GRAY05 = Color(hex: "F5F5F5")     // Cancel Button background
let COLOR_GRAY06 = Color(hex: "797979")     // Cancel Button foreground

// Black color sets
let COLOR_BLACK01 = Color(hex: "0E1722")    // Tab active, Text, Loading Icon
let COLOR_BLACK02 = Color(hex: "0B0B0B")    // Option Button background
let COLOR_BLACK03 = Color(hex: "666666")    // Label


struct ContentView: View {
    
    // All global variables are collected in `userData`.
    @EnvironmentObject var userData: UserData


    var body: some View {
        
        ZStack {
            
            Spacer()
            
            // Current app view control
            VStack {
                switch userData.ACTIVE_SCREEN {
                case .welcome: WelcomeView()
                case .home: HomeView()
                case .info: ProductInfoView()
                case .scan: ScanView()
                case .add: AddNewProductView()
                case .update: UpdateProductView()
                case .search: ProductSearchView()
                case .search_result: SearchResultView()
                case .setting: AppSettingView()
                default: HomeView()
                }
            }

            // Tab menu bar at the bottom of the screen
            if userData.TABBAR_PRESENT {
                VStack {
                    Spacer()
                    HStack{
                        Spacer()
                        // Load each tab menu item
                        ForEach(TabBarModel.allCases, id: \.self) { item in
                            TabBarIcon(viewModel: item)
                        }
                        Spacer()
                    }
                    .frame(height: UIScreen.main.bounds.height / 9) //Adjust tab menu height (optimized for iPhone 12 mini).
                    .frame(maxWidth: .infinity)
                    .background(COLOR_GRAY03)
                    .border(COLOR_GRAY02)
                }
                .frame(height: UIScreen.main.bounds.height)
            }
            
            if userData.LOADING_SCREEN_PRESENT {
                LoadingView() //Display a "Loading in Progress" view while fetching data
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(COLOR_GRAY03)
        .ignoresSafeArea()
        
    }
}



// MARK: PREVIEW
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(UserData())
    }
}


// MARK: EXTENSIONS
extension Color {
    //  Creating RGB color object (0-1) using hexadecicmal values
    //  Example:
    //      let COLOR_GRAY01 = Color(hex: "676C72")
    //      Text("Hello Mom")
    //          .foregroundColor(COLOR_GRAY01)
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        self.init(red: Double(r) / 0xff, green: Double(g) / 0xff, blue: Double(b) / 0xff)
    }
}

extension Dictionary {
    //  Add encoding a dictionary function into a URL query string format
    //  Example:
    //      let parameters: [String: Any] = [
    //          "name": "John Doe",
    //          "age": 30,
    //          "location": "New York"
    //      ]
    //      let queryString = parameters.percentEscaped()
    func percentEscaped() -> String {
        return map { (key, value) in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
    }
}

extension CharacterSet {
    //  Determining the set of characters that should be allowed in
    //  a URL query value is related to the percentEscaped function in the Dictionary
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

extension String {
    //  Enabling access to individual characters within a string
    //  Example:
    //      let myString = "Hello Mom"
    //      let thirdCharacter = myString[2]  // This will be "l"
    //      let seventhCharacter = myString[6] // This will be "M"
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}

extension UIApplication {
    //  Computed property named `appVersion` to the `UIApplication` class.
    //  We can easily retrieve the version of the app
    //  Example:
    //      Text("version \(UIApplication.appVersion ?? "unknown")")
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}


// MARK: CUSTOM MODIFIERS
struct SubmitButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        return content
        .frame(minWidth: 100)
        .padding()
        .foregroundColor(.white)
        .background(COLOR_GREEN01)
        .cornerRadius(10)
    }
}

struct CancelButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        return content
        .frame(minWidth: 100)
        .padding()
        .foregroundColor(COLOR_GRAY06)
        .background(COLOR_GRAY05)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(COLOR_GRAY02, lineWidth: 1)
        )
    }
}

struct OptionButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        return content
        .frame(minWidth: 100)
        .padding()
        .foregroundColor(.white)
        .background(COLOR_BLACK02)
        .cornerRadius(10)        
    }
}

struct HomeButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        return content
        .frame(width: 70, height: 70)
        .padding()
        .foregroundColor(.white)
        .background(COLOR_GREEN01)
        .cornerRadius(20)
    }
}

struct MainPanelModifier: ViewModifier {
    func body(content: Content) -> some View {
        return content
        .padding(.horizontal, 20.0)
        .padding(.bottom, UIScreen.main.bounds.height / 9)
        .frame(maxWidth: .infinity)
        .background(COLOR_GRAY03)
    }
}


// MARK: CUSTOM VIEWS
struct PickerTypeA: View {
    @Binding var selected: Int
    var topic: String
    var values = [String]()
    var width: CGFloat
    var defaultText:String?
    var body: some View {

        HStack {
            Text(topic)
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(COLOR_GRAY02)
                .padding(.trailing, 10)
            Picker("", selection: $selected) {
                ForEach(values.indices, id: \.self) { (index: Int) in
                    Text(self.values[index])
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(COLOR_BLACK01)
                }
                if let defaultText = defaultText {
                    Text(defaultText).tag(-1)
                }
            }
            .accentColor(COLOR_BLACK01)
            .pickerStyle(MenuPickerStyle())
            Spacer()
        }
        .padding()
        .frame(maxWidth: width)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.white)
        )
    }
    
}


struct PickerTypeB: View {
    @Binding var selected: Int
    var topic: String
    var values = [String]()
    var width: CGFloat
    var defaultText:String?
    var body: some View {

        HStack {
            
            Text(topic)
                .font(.body)
                .foregroundColor(COLOR_GRAY02)
                .padding(.trailing, 10)
            
            Picker("", selection: $selected) {
                ForEach(values.indices, id: \.self) { (index: Int) in
                    Text(self.values[index])
                        .font(.body)
                        .foregroundColor(COLOR_BLACK01)
                }
                if let defaultText = defaultText {
                    Text(defaultText).tag(-1)
                }
            }
            .cornerRadius(3)
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(COLOR_GRAY03, lineWidth: 1)
                    .padding(.horizontal, -10)

            )
            .accentColor(COLOR_BLACK01)
            .pickerStyle(MenuPickerStyle())
            
            Spacer()
            
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: width)
        
    }
    
}


struct CustomPicker: View {
    @Binding var value: Int
    var title: String
    var name = [String]()
    var body: some View {
        Picker(selection: $value, label: Text(title).foregroundColor(COLOR_GREEN01)) {
            ForEach(name.indices, id: \.self) { (index: Int) in
                Text(self.name[index]).foregroundColor(COLOR_GRAY01)
            }
        }
        
    }
}

struct NumberInput: View {
    @Binding var value: String
    var title: String
    var text: String
    var width: CGFloat
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(COLOR_GREEN01)
            TextField(text, text: $value)
                .foregroundColor(COLOR_GRAY01)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(minWidth: 0, maxWidth: width)
                .keyboardType(.numbersAndPunctuation)
                .multilineTextAlignment(.trailing)
        }
    }
}


struct InputNumberStyleA: View {
    @Binding var value: String
    var topic: String
    var text: String = "-"
    var width: CGFloat
    var inputWidth: CGFloat
    var body: some View {

        HStack {
            Text(topic)
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(COLOR_GRAY02)
                .padding(.trailing, 10)
            Spacer()
            TextField(text, text: $value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(COLOR_BLACK01)
                .frame(minWidth: 0, maxWidth: inputWidth)
                .keyboardType(.numberPad)

        }
        .padding()
        .frame(maxWidth: width)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.white)
        )
    }
}


struct NumberInputTypeB: View {
    @Binding var value: String
    var topic: String
    var text: String = "-"
    var width: CGFloat?
    var inputWidth: CGFloat
    var body: some View {
        
        HStack {
            Text(topic)
                .foregroundColor(COLOR_GRAY02)

            TextField(text, text: $value)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(COLOR_BLACK01)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numbersAndPunctuation)
                .multilineTextAlignment(.trailing)
                .frame(minWidth: 0, maxWidth: inputWidth)
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: width)

    }
}

struct NumberInputTypeC: View {
    
    @Binding var value: String
    var topic: String
    var text: String = "-"
    var width: CGFloat?
    var inputWidth: CGFloat

    var body: some View {
        
        HStack {
            Text(topic)
                .foregroundColor(COLOR_GRAY02)
            TextField(text, text: $value)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(COLOR_BLACK01)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(minWidth: 0, maxWidth: inputWidth)
        }
        .padding(.horizontal, 10)
//        .frame(maxWidth: width)

    }
}

struct TextInput: View {
    
    @Binding var value: String
    var title: String
    var text: String
    var width: CGFloat

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(COLOR_GRAY02)
            TextField(text, text: $value)
                .foregroundColor(COLOR_BLACK01)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(minWidth: 0, maxWidth: width)
        }
    }
}

struct TextInputTypeA: View {
    
    @Binding var value: String
    var topic: String
    var text: String = "-"
    var width: CGFloat
    var inputWidth: CGFloat

    var body: some View {

        HStack {
            Text(topic)
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(COLOR_GRAY02)
                .padding(.trailing, 10)
            Spacer()
            TextField(text, text: $value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(COLOR_BLACK01)
                .frame(minWidth: 0, maxWidth: inputWidth)
        }
        .padding()
        .frame(maxWidth: width)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.white)
        )
    }
}

struct TextInputTypeB: View {
    
    @Binding var value: String
    var topic: String
    var text: String = "-"
    var width: CGFloat
    var inputWidth: CGFloat

    var body: some View {
        
        HStack {
            Text(topic)
                .foregroundColor(COLOR_GRAY02)
            TextField(text, text: $value)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(COLOR_BLACK01)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(minWidth: 0, maxWidth: inputWidth)
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: width)

    }
}

struct SecureInputTypeA: View {
    
    @Binding var value: String
    var topic: String
    var text: String = "****"
    var width: CGFloat
    var inputWidth: CGFloat
    @State private var secure: Bool = true

    var body: some View {

        HStack {
            Text(topic)
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(COLOR_GRAY02)
                .padding(.trailing, 10)
            Spacer()
            ZStack(alignment: .trailing) {
                if (secure) {
                    SecureField(text, text: $value)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(COLOR_BLACK01)
                        .frame(minWidth: 0, maxWidth: inputWidth)
                }
                else {
                    TextField(text, text: $value)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(COLOR_BLACK01)
                        .frame(minWidth: 0, maxWidth: inputWidth)
                }
                Button(action: {
                    self.secure.toggle()
                }){
                    Image(systemName: self.secure ? "eye.slash" : "eye")
                        .accentColor(COLOR_GRAY02)
                }
            }
        }
        .padding()
        .frame(maxWidth: width)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.white)
        )
    }
}

struct HomeButtonView: View {
    var title: String
    var subtitle: String
    var icon: String
    var clicked: (() -> Void)
    var body: some View {
        Button(action: clicked) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(COLOR_BLACK01)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(COLOR_GRAY01)
                }
                Spacer()
                Image(systemName: icon)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(COLOR_GRAY02)
            }
        }
        .frame(height: 40)
        .frame(maxWidth: .infinity)
        .padding()
        .foregroundColor(.white)
        .background(.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(COLOR_GRAY02, lineWidth: 1)
        )
    }
}

struct SubmitButtonView: View {
    var title: String
    var image: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: image)
            .font(.title)
            Text(title)
                .fontWeight(.bold)
        }
    }
}

struct ButtonStyleA: View {
    var text: String
    var icon: String?
    var clicked: (() -> Void)
    var width: CGFloat?
    
    var body: some View {
        Button(action: clicked){
            HStack(spacing: 10) {
                if let imageName = icon {
                    Image(systemName: imageName)
                        .font(.title)
                }
                Text(text)
                    .fontWeight(.bold)
            }
        }
        .frame(minWidth: 0, maxWidth: width)
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
                .opacity(0.6)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: COLOR_BLACK01))
                .scaleEffect(3)
        }
    }
}
