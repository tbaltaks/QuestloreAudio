//
//  GestureCanceller.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 19/3/2025.
//

import SwiftUI

struct GestureCanceller<Content: View>: View
{
    let content: () -> Content
    let dragThreshold: CGFloat = 40
    
    @State private var gestureCancelled: Bool = false

    var body: some View
    {
        content()
            .disabled(gestureCancelled)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if abs(value.translation.width) > dragThreshold ||
                           abs(value.translation.height) > dragThreshold {
                            gestureCancelled = true
                        }
                    }
                    .onEnded { _ in
                        gestureCancelled = false
                    }
            )
    }
}
