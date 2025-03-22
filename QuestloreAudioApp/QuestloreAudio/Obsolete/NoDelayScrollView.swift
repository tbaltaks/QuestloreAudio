//
//  NoDelayScrollView.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 22/3/2025.
//

import SwiftUI

struct NoDelayScrollView<Content: View>: UIViewRepresentable {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    // Create a coordinator that stores the hosting controller.
    func makeCoordinator() -> Coordinator {
        Coordinator(hostingController: UIHostingController(rootView: content))
    }
    
    class Coordinator: NSObject {
        var hostingController: UIHostingController<Content>
        init(hostingController: UIHostingController<Content>) {
            self.hostingController = hostingController
        }
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = CustomScrollView()
        scrollView.delaysContentTouches = false
        scrollView.alwaysBounceVertical = true

        // Retrieve the hosting controller from the coordinator.
        let hostingController = context.coordinator.hostingController
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the hosting controller's view to the scroll view.
        scrollView.addSubview(hostingController.view)
        
        // Pin the hosting controller's view to the scroll view's content layout guide.
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            // Keep the content width equal to the scroll view’s frame width
            hostingController.view.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // Update the hosting controller's rootView when the SwiftUI content changes.
        context.coordinator.hostingController.rootView = content
    }
}

class CustomScrollView: UIScrollView {
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIControl {
            return true
        }
        return super.touchesShouldCancel(in: view)
    }
}
