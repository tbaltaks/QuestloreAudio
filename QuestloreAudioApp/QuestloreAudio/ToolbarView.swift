//
//  ToolbarView.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 18/3/2025.
//

import SwiftUI

struct Toolbar: View
{
    @EnvironmentObject var globalColors: GlobalColors
    
    var height: CGFloat
    var bottomOffset: CGFloat
    
    @State var fadeInButtonExpanded: Bool = false
    @State var fadeInOptions: [TimeInterval] = [0.6, 3.2, 5.8]
    @State var selectedFadeInIndex = 1
    
    @State var fadeOutButtonExpanded: Bool = false
    @State var fadeOutOptions: [TimeInterval] = [0.6, 3.2, 5.8]
    @State var selectedFadeOutIndex = 1
    
    var body: some View
    {
        HStack
        {
            let fadeButtonHeight = height * 0.6
            
            Spacer(minLength: 10)
            
            DropDownMenu(
                options: fadeInOptions,
                selectedOptionIndex: $selectedFadeInIndex,
                showDropdown: $fadeInButtonExpanded,
                buttonHeight: min(fadeButtonHeight, 38),
                backgroundColor: globalColors.toolbarPrimary,
                foregroundColor: globalColors.toolbarForeground,
                dropDownColor: globalColors.dropDownBackground.opacity(0.2)
            )
            
            Spacer(minLength: 10)
            
            Image("QLAudioLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: height * 0.8)
                .colorMultiply(globalColors.toolbarPrimary)
            
            Spacer(minLength: 10)
            
            DropDownMenu(
                options: fadeOutOptions,
                selectedOptionIndex: $selectedFadeOutIndex,
                showDropdown: $fadeOutButtonExpanded,
                buttonHeight: min(fadeButtonHeight, 38),
                backgroundColor: globalColors.toolbarPrimary,
                foregroundColor: globalColors.toolbarForeground,
                dropDownColor: globalColors.dropDownBackground.opacity(0.2)
            )
            
            Spacer(minLength: 10)
        }
        .zIndex(100)
        .frame(height: height)
        .padding(.bottom, bottomOffset)
        .background(globalColors.toolbarBackground)
//        .border(.red)
    }
    
    
    struct SceneView_Previews: PreviewProvider
    {
        static var previews: some View
        {
            AudioStage()
                .previewInterfaceOrientation(.landscapeRight)
                .preferredColorScheme(.light)
                .environmentObject(GlobalColors(colorScheme: .light))
            
            AudioStage()
                .previewInterfaceOrientation(.landscapeRight)
                .preferredColorScheme(.dark)
                .environmentObject(GlobalColors(colorScheme: .dark))
        }
    }
}


struct DropDownMenu<T: CustomStringConvertible>: View
{
    let options: [T]
    
    @Binding  var selectedOptionIndex: Int
    @Binding  var showDropdown: Bool

    var menuWidth: CGFloat = 60
    var buttonHeight: CGFloat = 36
    var backgroundColor: Color = .secondary
    var foregroundColor: Color = .primary
    var dropDownColor: Color = .black.opacity(0.1)
    var selectedColor: Color = .primary

    var body: some  View
    {
        let cornerRadius = menuWidth * 0.2
        
        VStack
        {
            VStack(spacing: 0)
            {
                Button(
                    action: {
                        withAnimation(.easeInOut(duration: 0.24)) {
                            showDropdown.toggle()
                        }
                    }
                ){
                    Text(options[selectedOptionIndex].description)
                }
                .frame(width: menuWidth, height: buttonHeight)
                .contentShape(RoundedRectangle(cornerRadius: cornerRadius))

                if showDropdown
                {
                    VStack (spacing: 0)
                    {
                        ForEach(0..<options.count, id: \.self)
                        { index in
                            Button(
                                action: {
                                    selectedOptionIndex = index
                                    withAnimation(.easeInOut(duration: 0.24)) {
                                        showDropdown.toggle()
                                    }
                                }
                            ){
                                HStack
                                {
                                    Text(options[index].description)
                                        .foregroundColor(index == selectedOptionIndex ? selectedColor : foregroundColor)
                                }
                            }
                            .frame(width: menuWidth, height: buttonHeight)
                            
                            let lastIndex = options.count - 1
                            if index < lastIndex {
                                Rectangle()
                                    .fill(foregroundColor.opacity(0.5))
                                    .frame(width: menuWidth * 0.72, height: 1)
                            }
                        }
                    }
                    .background(dropDownColor)
                }
            }
            .foregroundStyle(foregroundColor)
            .background(backgroundColor.opacity(showDropdown ? 0.74 : 1))
            .cornerRadius(cornerRadius)
        }
        .frame(width: menuWidth, height: buttonHeight, alignment: .top)
        .zIndex(101)
    }
}
