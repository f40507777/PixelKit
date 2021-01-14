//
//  SepiaPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-03-25.
//


import RenderKit
import Foundation

public class SepiaPIX: PIXSingleEffect {
    
    override open var shaderName: String { return "effectSingleSepiaPIX" }
    
    // MARK: - Public Properties
    
    public var color: PixelColor = .orange
    
    // MARK: - Property Helpers
    
    override public var values: [Floatable] {
        return [color]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Sepia", typeName: "pix-effect-single-sepia")
    }
    
}
