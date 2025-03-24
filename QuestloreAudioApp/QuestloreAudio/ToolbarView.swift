//
//  ToolbarView.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 18/3/2025.
//

import SwiftUI

struct Toolbar: View
{
    var height: CGFloat
    var bottomOffset: CGFloat
    var color: Color
    
    @State var fadeInButtonExpanded: Bool = false
    @State var selectedFadeInIndex = 1
    
    @State var fadeOutButtonExpanded: Bool = false
    @State var selectedFadeOutIndex = 1
    
    var body: some View
    {
        HStack
        {
            Spacer(minLength: 10)
            
            DropDownMenu(
                options: [
                    0.6,
                    3.2,
                    5.8,
                ],
                selectedOptionIndex: $selectedFadeInIndex,
                showDropdown: $fadeInButtonExpanded,
                buttonHeight: height * 0.6
            )
            
            Spacer(minLength: 10)
            
            Image("QLAudioLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: height * 0.8)
                .colorMultiply(.gray)
            
            Spacer(minLength: 10)
            
            DropDownMenu(
                options: [
                    0.6,
                    3.2,
                    5.8,
                ],
                selectedOptionIndex: $selectedFadeOutIndex,
                showDropdown: $fadeOutButtonExpanded,
                buttonHeight: height * 0.6
            )
            
            Spacer(minLength: 10)
        }
        .zIndex(100)
        .frame(height: height)
        .padding(.bottom, bottomOffset)
        .background(color)
//        .border(.red)
    }
    
    
    struct SceneView_Previews: PreviewProvider
    {
        static var previews: some View
        {
            AudioStage()
                .previewInterfaceOrientation(.landscapeRight)
                .preferredColorScheme(.light)
            
            AudioStage()
                .previewInterfaceOrientation(.landscapeRight)
                .preferredColorScheme(.dark)
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

    var body: some  View
    {
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

                if (showDropdown)
                {
                    Rectangle()
                        .fill(.black.opacity(0.12))
                        .frame(width: menuWidth, height: 3)
                        .padding(.bottom, 6)
                    
                    VStack (spacing: 2)
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
                                        .foregroundColor(index == selectedOptionIndex ? .black : .white)
                                }
                            }
                            .frame(width: menuWidth, height: buttonHeight)
                            
                            Rectangle()
                                .fill(.black.opacity(0.18))
                                .frame(width: menuWidth * 0.72, height: 1)
                        }
                    }
                }
            }
            .foregroundStyle(Color.white)
            .background(.gray)
            .cornerRadius(menuWidth * 0.2)
        }
        .frame(width: menuWidth, height: buttonHeight, alignment: .top)
        .zIndex(101)
    }
}
