import RealityKit

// Ensure you register this component in your app’s delegate using:
// BubbleComponent.registerComponent()
public struct BubbleComponent: Component, Codable {

    public var direction: SIMD3<Float> = [0,0,0]
    
    public init() {}
}
