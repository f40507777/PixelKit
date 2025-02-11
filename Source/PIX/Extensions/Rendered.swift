//
//  PIXRendered.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-12.
//  Open Source - MIT License
//

import RenderKit
import Resolution
import MetalKit
import simd
import PixelColor

public extension PIX {
    
    var renderedTexture: MTLTexture? { return texture } // CHECK copy?
    
    var renderedCIImage: CIImage? {
        guard let texture = renderedTexture else {
            pixelKit.logger.log(.error, .texture, "Texture is not available.")
            return nil
        }
        return Texture.ciImage(from: texture, colorSpace: pixelKit.render.colorSpace)
    }
    
    var renderedCGImage: CGImage? {
        guard let ciImage = renderedCIImage else {
            pixelKit.logger.log(.error, .texture, "CIImage could not be generated.")
            return nil
        }
        #if os(macOS)
        let vFlip: Bool = true
        #else
        let vFlip: Bool = true
        #endif
        return Texture.cgImage(from: ciImage, at: finalResolution.size, colorSpace: pixelKit.render.colorSpace, bits: pixelKit.render.bits, vFlip: vFlip)
    }
    
    #if os(iOS) || os(tvOS)
    typealias _Image = UIImage
    #elseif os(macOS)
    typealias _Image = NSImage
    #endif
    var renderedImage: _Image? {
        guard let cgImage = renderedCGImage else {
            pixelKit.logger.log(.error, .texture, "CGImage could not be generated.")
            return nil
        }
        return Texture.image(from: cgImage, at: finalResolution.size)
    }
    
    var renderedTileTexture: MTLTexture? {
        guard let nodeTileable2d = self as? NODETileable2D else {
            pixelKit.logger.log(.error, .texture, "PIX is not tilable.")
            return nil
        }
        guard let textures = nodeTileable2d.tileTextures else {
            pixelKit.logger.log(.error, .texture, "Tile textures not available.")
            return nil
        }
        do {
            return try Texture.mergeTiles2d(textures: textures, on: pixelKit.render.metalDevice, in: pixelKit.render.commandQueue)
        } catch {
            pixelKit.logger.log(.error, .texture, "Tile texture merge failed.", e: error)
            return nil
        }
    }
    
    var renderedTileImage: _Image? {
        guard let texture = renderedTileTexture else { return nil }
        guard let ciImage = Texture.ciImage(from: texture, colorSpace: pixelKit.render.colorSpace) else {
            pixelKit.logger.log(.error, .texture, "CIImage could not be generated.")
            return nil
        }
        guard let cgImage = Texture.cgImage(from: ciImage, at: finalResolution.size, colorSpace: pixelKit.render.colorSpace, bits: pixelKit.render.bits) else {
            pixelKit.logger.log(.error, .texture, "CGImage could not be generated.")
            return nil
        }
        return Texture.image(from: cgImage, at: finalResolution.size)
    }
    
    func renderedTileImage(at tileIndex: TileIndex) -> _Image? {
        guard let nodeTileable2d = self as? NODETileable2D else {
            pixelKit.logger.log(.error, .texture, "PIX is not tilable.")
            return nil
        }
        guard let textures = nodeTileable2d.tileTextures else {
            pixelKit.logger.log(.error, .texture, "Tile textures not available.")
            return nil
        }
        guard tileIndex.y < textures.count && tileIndex.x < textures.first!.count else {
            pixelKit.logger.log(.error, .texture, "Tile index out of bounds.")
            return nil
        }
        let texture = textures[tileIndex.y][tileIndex.x]
        guard let ciImage = Texture.ciImage(from: texture, colorSpace: pixelKit.render.colorSpace) else {
            pixelKit.logger.log(.error, .texture, "CIImage could not be generated.")
            return nil
        }
        let size = CGSize(width: texture.width, height: texture.height)
        guard let cgImage = Texture.cgImage(from: ciImage, at: size, colorSpace: pixelKit.render.colorSpace, bits: pixelKit.render.bits) else {
            pixelKit.logger.log(.error, .texture, "CGImage could not be generated.")
            return nil
        }
        return Texture.image(from: cgImage, at: size)
    }
    
    var renderedPixelBuffer: CVPixelBuffer? {
        guard let cgImage = renderedCGImage else { pixelKit.logger.log(node: self, .error, nil, "renderedPixelBuffer: no cgImage."); return nil }
        do {
            return try Texture.pixelBuffer(from: cgImage, colorSpace: PixelKit.main.render.colorSpace, bits: PixelKit.main.render.bits)
        } catch {
            pixelKit.logger.log(node: self, .error, nil, "renderedPixelBuffer failed.", e: error);
            return nil
        }
    }
    
//    var dynamicTexture: MTLTexture? {
//        if PixelKit.main.render.engine.renderMode.isTile {
//            return renderedTileTexture
//        } else {
//            return renderedTexture
//        }
//    }
    
    /// coaints all 4 channels of all pixels in this flat array
    var renderedRaw8: [UInt8]? {
        guard let texture: MTLTexture = texture else { return nil }
        do {
            #if os(macOS)
            return try Texture.rawCopy8(texture: texture, on: pixelKit.render.metalDevice, in: pixelKit.render.commandQueue)
            #else
            return try Texture.raw8(texture: texture)
            #endif
        } catch {
            pixelKit.logger.log(node: self, .error, .texture, "Raw 8 Bit texture failed.", e: error)
            return nil
        }
    }
    
    #if !os(macOS) && !targetEnvironment(macCatalyst)
    /// coaints all 4 channels of all pixels in this flat array
    @available(iOS 14.0, *)
    @available(tvOS 14.0, *)
    @available(macOS 11.0, *)
    var renderedRaw16: [Float16]? {
        guard let texture: MTLTexture = texture else { return nil }
        do {
            return try Texture.raw16(texture: texture)
        } catch {
            pixelKit.logger.log(node: self, .error, .texture, "Raw 16 Bit texture failed.", e: error)
            return nil
        }
    }
    #endif
    
    /// coaints all 4 channels of all pixels in this flat array
    var renderedRaw32: [Float]? {
        guard let texture: MTLTexture = texture else { return nil }
        do {
            return try Texture.raw32(texture: texture)
        } catch {
            pixelKit.logger.log(node: self, .error, .texture, "Raw 32 Bit texture failed.", e: error)
            return nil
        }
    }
    
    /// coaints all 4 channels of all pixels in this flat array, normalized (0.0...1.0)
    var renderedRawNormalized: [CGFloat]? {
        guard let texture: MTLTexture = texture else { return nil }
        do {
            #if os(macOS) || targetEnvironment(macCatalyst)
            return try Texture.rawNormalizedCopy(texture: texture, bits: pixelKit.render.bits, on: pixelKit.render.metalDevice, in: pixelKit.render.commandQueue)
            #else
            return try Texture.rawNormalized(texture: texture, bits: pixelKit.render.bits)
            #endif
        } catch {
            pixelKit.logger.log(node: self, .error, .texture, "Raw Normalized texture failed.", e: error)
            return nil
        }
    }
    
    struct PixelPack {
        public let resolution: Resolution
        public let raw: [[Pixel]]
        public func pixel(x: Int, y: Int) -> Pixel {
            return raw[y][x]
        }
        public func pixel(uv: CGVector) -> Pixel {
            let xMax = resolution.width - 1
            let yMax = resolution.height - 1
            let x = max(0, min(Int(round(uv.dx * xMax + 0.5)), Int(xMax)))
            let y = max(0, min(Int(round(uv.dy * yMax + 0.5)), Int(yMax)))
            return pixel(pos: CGPoint(x: x, y: y))
        }
        public func pixel(pos: CGPoint) -> Pixel {
            let xMax = resolution.width - 1
            let yMax = resolution.height - 1
            let x = max(0, min(Int(round(pos.x)), Int(xMax)))
            let y = max(0, min(Int(round(pos.y)), Int(yMax)))
            return raw[y][x]
        }
        public var average: PixelColor {
            var color: PixelColor!
            for row in raw {
                for px in row {
                    guard color != nil else {
                        color = px.color
                        continue
                    }
                    color = PixelColor(red: color.red + px.color.red,
                                       green: color.green + px.color.green,
                                       blue: color.blue + px.color.blue,
                                       alpha: color.alpha + px.color.alpha)
                }
            }
            let count = CGFloat(resolution.count)
            color = PixelColor(red: color.red / count,
                               green: color.green / count,
                               blue: color.blue / count,
                               alpha: color.alpha / count)
            
            return color
        }
        @available(*, deprecated, renamed: "averageBrightness")
        public var averageLuminance: CGFloat { averageBrightness }
        public var averageBrightness: CGFloat {
            var luminance: CGFloat = 0.0
            for row in raw {
                for px in row {
                    luminance += px.color.brightness
                }
            }
            luminance /= CGFloat(resolution.count)
            return luminance
        }
        public var maximum: PixelColor {
            var color: PixelColor!
            for row in raw {
                for px in row {
                    guard color != nil else {
                        color = px.color
                        continue
                    }
                    if px.color.brightness > color!.brightness {
                        color = px.color
                    }
                }
            }
            return color
        }
        public var minimum: PixelColor {
            var color: PixelColor!
            for row in raw {
                for px in row {
                    guard color != nil else {
                        color = px.color
                        continue
                    }
                    if px.color.brightness < color!.brightness {
                        color = px.color
                    }
                }
            }
            return color
        }
    }
    
    var renderedPixels: PixelPack? {
        guard let resolution = derivedResolution else { return nil }
        guard let rawPixels = renderedRawNormalized else { return nil }
        var pixels: [[Pixel]] = []
        let w = Int(resolution.width)
        let h = Int(resolution.height)
        for y in 0..<h {
            let v = (CGFloat(y) + 0.5) / CGFloat(h)
            var pixelRow: [Pixel] = []
            for x in 0..<w {
                let u = (CGFloat(x) + 0.5) / CGFloat(w)
                var c: [CGFloat] = []
                for i in 0..<4 {
                    let j = y * w * 4 + x * 4 + i
                    guard j < rawPixels.count else { return nil }
                    let chan = rawPixels[j]
                    c.append(chan)
                }
                let color = PixelColor(red: c[0], green: c[1], blue: c[2], alpha: c[3])
                let uv = CGVector(dx: u, dy: v)
                let pixel = Pixel(x: x, y: y, uv: uv, color: color)
                pixelRow.append(pixel)
            }
            pixels.append(pixelRow)
        }
        return PixelPack(resolution: resolution, raw: pixels)
    }
    
}
