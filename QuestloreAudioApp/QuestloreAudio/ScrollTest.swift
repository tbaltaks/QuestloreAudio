//
//  ScrollTest.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 22/3/2025.
//

import SwiftUI

struct ScrollTest: View
{
    @State var switchColour: Bool = false
    
    var body: some View
    {
        ScrollView
        {
            GestureButton(endAction: { switchColour.toggle() }){
                Text("Yo")
                    .frame(width: 200, height: 200)
                    .background(Color.gray)
            }
//            .buttonStyle(ScalingButtonStyle())
            
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .frame(width: 200, height: 200)
                .background(switchColour ? Color.gray : Color.accentColor)
                .onTapGesture {
                    switchColour.toggle()
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            switchColour.toggle()
                        }
                )
        }
    }
}

struct ScalingButtonStyle: ButtonStyle
{
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .onChange(of: configuration.isPressed) { isPressed in
                for _ in 0...200 {
                    print(10 * pow(4, 6) / 3)
                }
            }
    }
}

struct ScrollTest_Previews: PreviewProvider {
    static var previews: some View {
        ScrollTest()
    }
}
