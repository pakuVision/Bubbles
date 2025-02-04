//
//  BubbleSystem.swift
//  Bubbles
//
//  Created by boardguy.vision on 2025/02/04.
//

import RealityKit
import RealityKitContent

class BubbleSystem: System {
    
    private let query = EntityQuery(where: .has(BubbleComponent.self))
    private let speed: Float = 0.0001
    
    required init(scene: Scene) { }
    
    func update(context: SceneUpdateContext) {
        context.scene.performQuery(query).forEach { bubble in
            guard let bubbleComponent = bubble.components[BubbleComponent.self] else {
                return
            }
            bubble.position += bubbleComponent.direction * speed
        }
    }
}
