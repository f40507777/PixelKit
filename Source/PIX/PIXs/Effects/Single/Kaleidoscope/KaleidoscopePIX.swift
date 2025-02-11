//
//  KaleidoscopePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-18.
//  Open Source - MIT License
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution

final public class KaleidoscopePIX: PIXSingleEffect, PIXViewable {
    
    override public var shaderName: String { return "effectSingleKaleidoscopePIX" }
    
    // MARK: - Public Properties
    
    @LiveInt("divisions", range: 2...24) public var divisions: Int = 12
    @LiveBool("mirror") public var mirror: Bool = true
    @LiveFloat("rotation", range: -0.5...0.5, increment: 0.125) public var rotation: CGFloat = 0.0
    @LivePoint("position") public var position: CGPoint = .zero
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_divisions, _mirror, _rotation, _position]
    }
    
    override public var values: [Floatable] {
        [divisions, mirror, rotation, position]
    }
    
    public required init() {
        super.init(name: "Kaleidoscope", typeName: "pix-effect-single-kaleidoscope")
        extend = .mirror
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
}

public extension NODEOut {
    
    func pixKaleidoscope(divisions: Int = 12, mirror: Bool = true) -> KaleidoscopePIX {
        let kaleidoscopePix = KaleidoscopePIX()
        kaleidoscopePix.name = ":kaleidoscope:"
        kaleidoscopePix.input = self as? PIX & NODEOut
        kaleidoscopePix.divisions = divisions
        kaleidoscopePix.mirror = mirror
        return kaleidoscopePix
    }
    
}
