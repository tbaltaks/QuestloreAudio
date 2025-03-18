//
//  HomeIndicatorHider.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 18/3/2025.
//

import SwiftUI

class HomeIndicatorHidingViewController: UIViewController {
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}

struct HomeIndicatorHiddenView<Content: View>: UIViewControllerRepresentable {
    let content: Content

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = HomeIndicatorHidingViewController()
        let hostingController = UIHostingController(rootView: content)
        controller.addChild(hostingController)
        controller.view.addSubview(hostingController.view)
        hostingController.view.frame = controller.view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostingController.didMove(toParent: controller)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
