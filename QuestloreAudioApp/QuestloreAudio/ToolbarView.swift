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
    @EnvironmentObject var audioSettings: AudioSettings
    
    @Binding var fadeInButtonExpanded: Bool
    @Binding var fadeOutButtonExpanded: Bool
    
    var height: CGFloat
    var bottomOffset: CGFloat
    
    var body: some View
    {
        ZStack
        {
            if fadeInButtonExpanded || fadeOutButtonExpanded
            {
                DismissalOverlay(
                    action: {
                        fadeInButtonExpanded = false
                        fadeOutButtonExpanded = false
                    }
                )
//                .border(.indigo)
            }
            
            HStack
            {
                let fadeButtonHeight = height * 0.6
                
                Spacer(minLength: 10)
                
                DropDownMenu(
                    options: audioSettings.fadeInOptions,
                    selectedOptionIndex: $audioSettings.selectedFadeInIndex,
                    showDropdown: $fadeInButtonExpanded,
                    height: min(fadeButtonHeight, 38),
                    backgroundColor: globalColors.toolbarPrimary,
                    foregroundColor: globalColors.toolbarForeground,
                    dropDownColor: globalColors.dropDownBackground.opacity(0.2),
                    dismissAction: { fadeOutButtonExpanded = false }
                )
                
                Spacer(minLength: 10)
                
                Image("QLAudioLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: height * 0.8)
                    .colorMultiply(globalColors.toolbarPrimary)
                    .allowsHitTesting(false)
                
                Spacer(minLength: 10)
                
                DropDownMenu(
                    options: audioSettings.fadeOutOptions,
                    selectedOptionIndex: $audioSettings.selectedFadeOutIndex,
                    showDropdown: $fadeOutButtonExpanded,
                    height: min(fadeButtonHeight, 38),
                    backgroundColor: globalColors.toolbarPrimary,
                    foregroundColor: globalColors.toolbarForeground,
                    dropDownColor: globalColors.dropDownBackground.opacity(0.2),
                    dismissAction: { fadeInButtonExpanded = false }
                )
                
                Spacer(minLength: 10)
            }
            .frame(height: height)
            .padding(.bottom, bottomOffset)
//            .border(.mint)
        }
        .zIndex(10)
        .background(globalColors.toolbarBackground)
//        .border(.red)
        .onChange(of: audioSettings.selectedFadeInIndex) { _ in
            AudioManager.shared.fadeInDuration = audioSettings.currentFadeInTime
        }
        .onChange(of: audioSettings.selectedFadeOutIndex) { _ in
            AudioManager.shared.fadeOutDuration = audioSettings.currentFadeOutTime
        }
    }
    
    
    struct Previews: PreviewProvider
    {
        static var previews: some View
        {
            App_Previews.previews
        }
    }
}


struct DropDownMenu<T: CustomStringConvertible>: View
{
    let options: [T]
    
    @Binding var selectedOptionIndex: Int
    @Binding var showDropdown: Bool

    var width: CGFloat = 60
    var height: CGFloat = 36
    var backgroundColor: Color = .secondary
    var foregroundColor: Color = .primary
    var dropDownColor: Color = .black.opacity(0.1)
    var selectedColor: Color = .primary
    var dismissAction: () -> Void = {}

    var body: some  View
    {
        let cornerRadius: CGFloat = 12.0
        
        VStack
        {
            VStack(spacing: 0)
            {
                Button(
                    action: {
                        showDropdown.toggle()
                        dismissAction()
                    }
                ){
                    Text(options[selectedOptionIndex].description)
                }
                .frame(width: width, height: height)
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
                                    showDropdown.toggle()
                                    dismissAction()
                                }
                            ){
                                HStack
                                {
                                    Text(options[index].description)
                                        .foregroundColor(index == selectedOptionIndex ? selectedColor : foregroundColor)
                                }
                            }
                            .frame(width: width, height: height)
                            
                            let lastIndex = options.count - 1
                            if index < lastIndex {
                                Rectangle()
                                    .fill(foregroundColor.opacity(0.5))
                                    .frame(width: width * 0.72, height: 1)
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
        .zIndex(100)
        .animation(.easeInOut(duration: 0.24), value: showDropdown)
        .frame(width: width, height: height, alignment: .top)
    }
}
