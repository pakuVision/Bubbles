//
//  BubblesApp.swift
//  Bubbles
//
//  Created by boardguy.vision on 2024/12/29.
//

import SwiftUI
import RealityKitContent

@main
struct BubblesApp: App {

    @State private var appModel = AppModel()

    init() {
      //  BubbleSystem.registerSystem()
        BubbleComponent.registerComponent()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
     }
}
