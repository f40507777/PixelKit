//
//  WebPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-07-03.
//

import RenderKit
import Resolution
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
#if !os(tvOS)
import WebKit
#endif

#if !os(tvOS)

@available(OSX 10.13, *)
@available(iOS 11, *)
//@available(tvOS 11, *)
final public class WebPIX: PIXResource, NODEResolution, PIXViewable {
    
    #if os(iOS) || os(tvOS)
    override public var shaderName: String { return "contentResourceFlipPIX" }
    #elseif os(macOS)
    override public var shaderName: String { return "contentResourceBGRPIX" }
    #endif
    
    // MARK: - Private Properties
    
    let helper: WebHelper = .init()
    
    // MARK: - Public Properties
    
    @LiveResolution("resolution") public var resolution: Resolution = ._128
    
    public var url: URL = URL(string: "http://pixelkit.net/")! { didSet { refresh() } }
    public var webView: WKWebView = .init()
    
    public override var liveList: [LiveWrap] {
        [_resolution] + super.liveList
    }
    
    // MARK: - Life Cycle
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        
        self.resolution = resolution
                
        super.init(name: "Web", typeName: "pix-content-resource-web")
        
        setup()
    }
    
    public convenience init(at resolution: Resolution = .auto(render: PixelKit.main.render),
                            url: URL) {
        self.init(at: resolution)
        self.url = url
        self.refresh()
    }
    
    public required convenience init() {
        self.init(at: .auto(render: PixelKit.main.render))
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        setup()
    }
    
    // MARK: - Setup
    
    func setup() {
        
        webView.navigationDelegate = helper
        helper.refreshCallback = { [weak self] in
            self?.pixelKit.logger.log(node: self, .info, .resource, "Web refreshed!")
            self?.setNeedsBuffer()
        }
        
        refresh()
        
        setFrame()
        
        applyResolution { [weak self] in
            self?.renderWeb()
        }
        
        _resolution.didSetValue = { [weak self] in
            self?.setFrame()
            self?.applyResolution { [weak self] in
                self?.setNeedsBuffer()
            }
        }
    }
    
    // MARK: - Load
    
    public func refresh() {
        pixelKit.logger.log(node: self, .info, .resource, "Web refresh: \(url)")
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    public func renderWeb() {
        setNeedsBuffer()
    }
    
    // MARK: - Frame
    
    func setFrame() {
        webView.frame = CGRect(origin: .zero, size: (resolution / Resolution.scale).size)
    }
    
    // MARK: - Buffer
    
    func setNeedsBuffer() {
//        let config = WKSnapshotConfiguration()
//        if #available(OSX 10.15, *) {
//            if #available(iOS 13.0, *) {
//                // CHECK
////                config.afterScreenUpdates = false
//            }
//        }
//        config.rect = CGRect(origin: .zero, size: resolution.size)
        webView.takeSnapshot(with: nil) { [weak self] image, error in
            guard let self = self else { return }
            guard error == nil else {
                self.pixelKit.logger.log(node: self, .error, .resource, "Web snapshot failed.", e: error)
                return
            }
            guard let image = image else {
                self.pixelKit.logger.log(node: self, .error, .resource, "Web snapshot image not available.")
                return
            }
            guard let buffer = Texture.buffer(from: image, bits: self.pixelKit.render.bits) else {
                self.pixelKit.logger.log(node: self, .error, .resource, "Pixel Buffer creation failed.")
                return
            }
            self.resourcePixelBuffer = buffer
            self.pixelKit.logger.log(node: self, .info, .resource, "Image Loaded.")
            self.render()
        }
    }
    
}

// MARK: - Web Helper

class WebHelper: NSObject, WKNavigationDelegate {

    var refreshCallback: (() -> ())?

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        refreshCallback?()
    }

}

#endif
