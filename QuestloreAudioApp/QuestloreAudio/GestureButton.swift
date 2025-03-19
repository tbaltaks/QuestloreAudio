//
//  GestureButton.swift
//  QuestloreAudio
//
//  Created by Tom Baltaks on 19/3/2025.
//

import SwiftUI

struct GestureButton<Label: View>: View
{
    init(
        doubleTapTimeout: TimeInterval = 0.5,
        longPressTime: TimeInterval = 1,
        completeTime: TimeInterval = 1,
        pressAction: @escaping () -> Void = {},
        releaseAction: @escaping () -> Void = {},
        doubleTapAction: @escaping () -> Void = {},
        longPressAction: @escaping () -> Void = {},
        cancelAction: @escaping () -> Void = {},
        completeAction: @escaping () -> Void = {},
        endAction: @escaping () -> Void = {},
        label: @escaping () -> Label
    ) {
        self.style = GestureButtonStyle(
            doubleTapTimeout: doubleTapTimeout,
            longPressTime: longPressTime,
            completeTime: completeTime,
            pressAction: pressAction,
            releaseAction: releaseAction,
            doubleTapAction: doubleTapAction,
            longPressAction: longPressAction,
            cancelAction: cancelAction,
            completeAction: completeAction)
        self.label = label
        self.endAction = endAction
    }
    
    var label: () -> Label
    var style: GestureButtonStyle
    var endAction: () -> Void

    var body: some View {
        Button(action: endAction, label: label)
            .buttonStyle(style)
    }
}

struct GestureButtonStyle: ButtonStyle
{
    init(
        doubleTapTimeout: TimeInterval,
        longPressTime: TimeInterval,
        completeTime: TimeInterval,
        pressAction: @escaping () -> Void,
        releaseAction: @escaping () -> Void,
        doubleTapAction: @escaping () -> Void,
        longPressAction: @escaping () -> Void,
        cancelAction: @escaping () -> Void,
        completeAction: @escaping () -> Void)
    {
        self.doubleTapTimeout = doubleTapTimeout
        self.longPressTime = longPressTime
        self.completeTime = completeTime
        self.pressAction = pressAction
        self.releaseAction = releaseAction
        self.doubleTapAction = doubleTapAction
        self.longPressAction = longPressAction
        self.cancelAction = cancelAction
        self.completeAction = completeAction
    }

    private var doubleTapTimeout: TimeInterval
    private var longPressTime: TimeInterval
    private var completeTime: TimeInterval

    private var pressAction: () -> Void
    private var releaseAction: () -> Void
    private var doubleTapAction: () -> Void
    private var longPressAction: () -> Void
    private var cancelAction: () -> Void
    private var completeAction: () -> Void

    @State var doubleTapDate = Date()
    @State var longPressDate = Date()
    @State var didLongPress = false
    @State var didComplete = false

    func makeBody(configuration: Configuration) -> some View
    {
        configuration.label
            .onChange(of: configuration.isPressed) { isPressed in
                longPressDate = Date()
                if isPressed
                {
                    longPressDate = Date()
                    didLongPress = false
                    didComplete = false
                    
                    pressAction()
                    doubleTapDate = tryTriggerDoubleTap() ? .distantPast : .now
                    tryTriggerLongPressAfterDelay(triggered: longPressDate)
                    tryTriggerCompleteAfterDelay(triggered: longPressDate)
                }
                else
                {
                    if !didLongPress {
                        releaseAction()
                    } else if !didComplete {
                        cancelAction()
                    }
                }
            }
    }
}

private extension GestureButtonStyle
{
    func tryTriggerDoubleTap() -> Bool {
        let interval = Date().timeIntervalSince(doubleTapDate)
        guard interval < doubleTapTimeout else { return false }
        doubleTapAction()
        return true
    }

    func tryTriggerLongPressAfterDelay(triggered date: Date) {
        DispatchQueue.main.asyncAfter(deadline: .now() + longPressTime) {
            guard date == longPressDate else { return }
            didLongPress = true
            longPressAction()
        }
    }
    
    func tryTriggerCompleteAfterDelay(triggered date: Date) {
        DispatchQueue.main.asyncAfter(deadline: .now() + longPressTime + completeTime) {
            guard date == longPressDate else { return }
            didComplete = true
            completeAction()
        }
    }
}
