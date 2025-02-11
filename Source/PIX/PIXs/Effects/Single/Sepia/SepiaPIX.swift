//
//  SepiaPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-03-25.
//

import RenderKit
import Resolution
import Foundation
import PixelColor

final public class SepiaPIX: PIXSingleEffect, PIXViewable {
    
    override public var shaderName: String { return "effectSingleSepiaPIX" }
    
    // MARK: - Public Properties
    
    @LiveColor("color") public var color: PixelColor = .orange
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_color]
    }
    
    override public var values: [Floatable] {
        [color]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Sepia", typeName: "pix-effect-single-sepia")
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
}

public extension NODEOut {
    
    func pixSepia(_ color: PixelColor) -> SepiaPIX {
        let sepiaPix = SepiaPIX()
        sepiaPix.name = ":sepia:"
        sepiaPix.input = self as? PIX & NODEOut
        sepiaPix.color = color
        return sepiaPix
    }
    
}

