//
//  GlobalColors.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 25/3/2025.
//

import SwiftUI

class GlobalColors: ObservableObject
{
    @Published var colorScheme: ColorScheme
    
    init(colorScheme: ColorScheme) {
        self.colorScheme = colorScheme
    }
    
    var sceneBackground: Color {
        colorScheme == .light ? Color(hex: "f1f1f1") : Color(hex: "171717")
    }
    
    var toolbarBackground: Color {
        colorScheme == .light ? Color(hex: "cecece") : Color(hex: "222222")
    }
    
    var toolbarPrimary: Color {
        colorScheme == .light ? Color(hex: "9e9e9e") : Color(hex: "686868")
    }
    
    var toolbarForeground: Color {
        colorScheme == .light ? Color(hex: "686868") : Color(hex: "9e9e9e")
//        colorScheme == .light ? Color(hex: "2a2a2a") : Color(hex: "cecece")
    }
    
    var dropDownBackground: Color {
        colorScheme == .light ? .white : .black
    }
    
    var cellBackground: Color {
        colorScheme == .light ? .white : Color(hex: "222222")
    }
}


// Extension to create a Color from a hex string.
extension Color
{
    private static var colorCache: [String: Color] = [:]
    
    init(hex: String)
    {
        // Check cache first
        if let cached = Color.colorCache[hex] {
            self = cached
            return
        }
        
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        
        switch hex.count
        {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        let color = Color(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
        
        // Cache the result
        Color.colorCache[hex] = color
        self = color
    }
}
