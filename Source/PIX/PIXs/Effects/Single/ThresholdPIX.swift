//
//  ThresholdPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-17.
//  Open Source - MIT License
//


import RenderKit
import CoreGraphics

public class ThresholdPIX: PIXSingleEffect {
    
    override open var shaderName: String { return "effectSingleThresholdPIX" }
    
    // MARK: - Public Properties
    
    public var threshold: CGFloat = 0.5

    // MARK: - Property Helpers
    
    override public var values: [Floatable] {
        return [threshold]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Threshold", typeName: "pix-effect-single-threshold")
    }
    
}

public extension NODEOut {
    
    func _threshold(_ threshold: CGFloat = 0.5) -> ThresholdPIX {
        let thresholdPix = ThresholdPIX()
        thresholdPix.name = ":threshold:"
        thresholdPix.input = self as? PIX & NODEOut
        thresholdPix.threshold = threshold
//        thresholdPix.smooth = true
        return thresholdPix
    }
    
    func _mask(low: CGFloat, high: CGFloat) -> BlendPIX {
        let thresholdLowPix = ThresholdPIX()
        thresholdLowPix.name = "mask:threshold:low"
        thresholdLowPix.input = self as? PIX & NODEOut
        thresholdLowPix.threshold = low
        let thresholdHighPix = ThresholdPIX()
        thresholdHighPix.name = "mask:threshold:high"
        thresholdHighPix.input = self as? PIX & NODEOut
        thresholdHighPix.threshold = high
        return thresholdLowPix - thresholdHighPix
    }
    
}
