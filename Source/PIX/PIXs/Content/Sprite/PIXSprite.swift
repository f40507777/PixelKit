//
//  PIXSprite.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-28.
//  Open Source - MIT License
//


import RenderKit
import SpriteKit
import PixelColor

open class PIXSprite: PIXContent, NODEResolution {
    
    override open var shaderName: String { return "spritePIX" }
    
    // MARK: - Public Properties
    
    public var resolution: Resolution { didSet { reSize(); applyResolution { self.setNeedsRender() } } }
    
    @available(*, deprecated, renamed: "backgroundColor")
    public var bgColor: PixelColor {
        get { backgroundColor }
        set { backgroundColor = newValue }
    }
    public var backgroundColor: PixelColor = .black {
        didSet {
            #if os(macOS)
            scene.backgroundColor = backgroundColor.nsColor
            #else
            scene.backgroundColor = backgroundColor.uiColor
            #endif
            setNeedsRender()
        }
    }
    
    var scene: SKScene!
    var sceneView: SKView!
    
    required public init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        fatalError("Please use PIXSprite Sub Classes.")
    }
        
    public init(at resolution: Resolution = .auto(render: PixelKit.main.render), name: String, typeName: String) {
        self.resolution = resolution
        super.init(name: name, typeName: typeName)
        setup()
        applyResolution { self.setNeedsRender() }
    }
    
    func setup() {
        let size = (resolution / Resolution.scale).size
        scene = SKScene(size: size)
        #if os(macOS)
        scene.backgroundColor = backgroundColor.nsColor
        #else
        scene.backgroundColor = backgroundColor.uiColor
        #endif
        sceneView = SKView(frame: CGRect(origin: .zero, size: size))
        sceneView.allowsTransparency = true
        sceneView.presentScene(scene)
    }
    
    func reSize() {
        let size = (resolution / Resolution.scale).size
        scene.size = size
        sceneView.frame = CGRect(origin: .zero, size: size)
    }
    
}
