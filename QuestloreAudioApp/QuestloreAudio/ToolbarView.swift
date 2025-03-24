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
                    "0.6",
                    "3.2",
                    "5.8",
                ],
                selectedOptionIndex: $selectedFadeInIndex,
                showDropdown: $fadeInButtonExpanded
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
                    "0.6",
                    "3.2",
                    "5.8",
                ],
                selectedOptionIndex: $selectedFadeOutIndex,
                showDropdown: $fadeOutButtonExpanded
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


struct DropDownMenu: View
{
    let options: [String]

    var menuWidth: CGFloat = 80
    var buttonHeight: CGFloat = 36

    @Binding  var selectedOptionIndex: Int
    @Binding  var showDropdown: Bool

    @State  private  var scrollPosition: Int?

    var body: some  View
    {
        VStack
        {
            VStack(spacing: 0)
            {
                // selected item
                Button(
                    action: {
                        withAnimation {
                            showDropdown.toggle()
                        }
                    }
                ){
                    Text(options[selectedOptionIndex])
                }
                .frame(width: menuWidth, height: buttonHeight)


                // selection menu
                if (showDropdown)
                {
                    
                    
                    LazyVStack
                    {
                        ForEach(0..<options.count, id: \.self)
                        { index in
                            Button(
                                action: {
                                    selectedOptionIndex = index
                                    withAnimation {
                                        showDropdown.toggle()
                                    }
                                }
                            ){
                                HStack
                                {
                                    Text(options[index])
                                        .foregroundColor(index == selectedOptionIndex ? .black : .white)
                                }
                            }
                            .frame(width: menuWidth, height: buttonHeight)

                        }
                    }
                }
            }
            .foregroundStyle(Color.white)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray))
        }
        .frame(width: menuWidth, height: buttonHeight, alignment: .top)
        .zIndex(100)
    }
}
