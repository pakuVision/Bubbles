//
//  ImmersiveView.swift
//  Bubbles
//
//  Created by boardguy.vision on 2024/12/29.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {

    @State var predicate = QueryPredicate<Entity>.has(ModelComponent.self)
    @State var timer: Timer?
    
    @State var bubble: Entity?
    
    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            guard let scene = try? await Entity(named: "BubbleScene", in: realityKitContentBundle) else {
                fatalError()
            }
            
            bubble = scene.findEntity(named: "Bubble")
            
            for _ in 1...20 {
                guard let bubbleClone = bubble?.clone(recursive: true) else { return }
                
                var pbComponent = PhysicsBodyComponent()
                pbComponent.linearDamping = 0 // 0じゃないと速度が落ちて0になり、animationが止まるので 0を設定する必要がある
                pbComponent.isAffectedByGravity = false
                
                bubbleClone.components[PhysicsBodyComponent.self] = pbComponent
                
                let velocityX = Float.random(in: -0.05...0.05)
                let velocityY = Float.random(in: -0.05...0.05)
                let velocityZ = Float.random(in: -0.05...0.05)

                var pmCompont = PhysicsMotionComponent(
                    linearVelocity: .init(velocityX, velocityY, velocityZ)
                )
                bubbleClone.components[PhysicsMotionComponent.self] = pmCompont
                                                       
                // create random position
                let x = Float.random(in: -1.5...1.5)
                let y = Float.random(in: 1...1.5)
                let z = Float.random(in: -1.5...1.5)
                
                bubbleClone.position = .init(x, y, z)
                
                
                content.add(bubbleClone)
            }
        }
        .gesture(
            SpatialTapGesture()
                .targetedToEntity(where: predicate)
                .onEnded({ value in
                    popAnimateBubble(value: value)
                }
            )
        )
    }
    
    func popAnimateBubble(value: EntityTargetValue<SpatialTapGesture.Value>) {
        let entity = value.entity
        // タップしたentityのmaterialをShaderGraphMaterialとして取得 (composerProで設定したmaterial)
        guard var material = entity.components[ModelComponent.self]?.materials.first as? ShaderGraphMaterial else { return }
        
        // 1秒ごと60frams = 60FPS (0.016666666...)
        let frameRate: TimeInterval = 1.0/60.0
        let duration: TimeInterval = 0.25 //秒
        
        // durationを fpsに変換した値
        // duration: 1秒だと 1 / 0.01666.. = 60FPS
        // duration: 0.25だと 0.25 / 0.01666... = 15FPS つまり、15fps目にtimerが終わる
        let totalFrames = Int(duration / frameRate) // 15.0
        
        var currentFrame = 0
        var opaticy: Float = 0
        
        timer?.invalidate()
        
        // 1/60 = 0.1666秒ごとに timerが呼ばれる、つまり 1秒に60回呼ばれる
        timer = Timer.scheduledTimer(withTimeInterval: frameRate, repeats: true, block: { timer in
                            
            currentFrame += 1
            
            // (6%) 0.6 - 1/15
            // (33%) 0.33.. - 5/15
            // (100%) 1 - 15/15
            let progress = Float(currentFrame) / Float(totalFrames)
            
            // 1 to 0
            // 15fps == 15呼ばれるので シャボン玉がアニメーションで消えるようなロジックになっている
            opaticy = 1 - progress
            
            do {
                // popという名前のparamに valueを設定し、target Entityのmaterialにアサイン
                try material.setParameter(name: "Pop", value: .float(opaticy))
                entity.components[ModelComponent.self]?.materials = [material]
            } catch {
                print(error.localizedDescription)
            }
            
            if currentFrame >= totalFrames {
                timer.invalidate()
                entity.removeFromParent()
            }
        })
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
