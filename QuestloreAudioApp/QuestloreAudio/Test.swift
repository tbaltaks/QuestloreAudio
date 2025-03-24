//
//  Test.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 24/3/2025.
//

import SwiftUI

struct Test: View
{
    var body: some View
    {
        NavigationView
        {
            Text("Main Content")
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Menu {
                            Button("Option 1", action: handleOption1)
                            Button("Option 2", action: handleOption2)
                            Button("Option 3", action: handleOption3)
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .imageScale(.large)
                        }
                        .border(.purple)
                    }
                }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    func handleOption1() { /* Handle action */ }
    func handleOption2() { /* Handle action */ }
    func handleOption3() { /* Handle action */ }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
