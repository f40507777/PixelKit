//
//  ConvertPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-04-25.
//


import RenderKit
import CoreGraphics

final public class ConvertPIX: PIXSingleEffect, BodyViewRepresentable {
    
    override public var shaderName: String { return "effectSingleConvertPIX" }
    
    var bodyView: UINSView { pixView }
    
    var resScale: CGSize {
        switch mode {
        case .domeToEqui: return CGSize(width: 2.0, height: 1.0)
        case .equiToDome: return CGSize(width: 0.5, height: 1.0)
        case .cubeToEqui: return CGSize(width: (3.0 / 4.0) * 2.0, height: 1.0)
//        case .equiToCube: return CGSize(width: (4.0 / 3.0) / 2.0, height: 1.0)
        case .squareToCircle: return CGSize(width: 1.0, height: 1.0)
        case .circleToSquare: return CGSize(width: 1.0, height: 1.0)
        }
    }
    
    // MARK: - Public Properties
    
    public enum ConvertMode: String, CaseIterable, Floatable {
        case domeToEqui
        case equiToDome
        case cubeToEqui
//        case equiToCube
        case squareToCircle
        case circleToSquare
        var index: Int {
            switch self {
            case .domeToEqui: return 0
            case .equiToDome: return 1
            case .cubeToEqui: return 2
//            case .equiToCube: return 3
            case .squareToCircle: return 4
            case .circleToSquare: return 5
            }
        }
        public var floats: [CGFloat] { [CGFloat(index)] }
    }
    @Live public var mode: ConvertMode = .squareToCircle
    
    @Live public var xRotation: CGFloat = 0.0
    @Live public var yRotation: CGFloat = 0.0
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_mode, _xRotation, _yRotation]
    }
    
    public override var uniforms: [CGFloat] {
        [CGFloat(mode.index), xRotation, yRotation]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Convert", typeName: "pix-effect-single-convert")
    }
    
}
