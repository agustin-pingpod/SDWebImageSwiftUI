/*
 * This file is part of the SDWebImage package.
 * (c) DreamPiggy <lizhuoli1126@126.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

import SwiftUI
import SDWebImage

@available(iOS 14.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension ImagePlayer {
    public struct Settings: Equatable {
        /// Max buffer size
        public var maxBufferSize: UInt?

        /// Custom loop count
        public var customLoopCount: UInt?

        /// Animation runloop mode
        public var runLoopMode: RunLoop.Mode = .common

        /// Animation playback rate
        public var playbackRate: Double = 1.0

        /// Animation playback mode
        public var playbackMode: SDAnimatedImagePlaybackMode = .normal

        public init() { }
    }
}

/// A Image observable object for handle aniamted image playback. This is used to avoid `@State` update may capture the View struct type and cause memory leak.
@available(iOS 14.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public final class ImagePlayer : ObservableObject {
    private var player: SDAnimatedImagePlayer?

    public var settings: ImagePlayer.Settings = .init()

    /// Max buffer size
    public var maxBufferSize: UInt? { settings.maxBufferSize }
    
    /// Custom loop count
    public var customLoopCount: UInt? { settings.customLoopCount }
    
    /// Animation runloop mode
    public var runLoopMode: RunLoop.Mode { settings.runLoopMode }
    
    /// Animation playback rate
    public var playbackRate: Double { settings.playbackRate }
    
    /// Animation playback mode
    public var playbackMode: SDAnimatedImagePlaybackMode { settings.playbackMode }

    init(settings: ImagePlayer.Settings? = nil) {
        self.settings = settings ?? .init()
    }

    deinit {
        player?.stopPlaying()
        currentFrame = nil
    }
    
    /// Current playing frame image
    @Published public var currentFrame: PlatformImage?
    
    /// Current playing frame index
    @Published public var currentFrameIndex: UInt = 0
    
    /// Current playing loop count
    @Published public var currentLoopCount: UInt = 0
    
    /// Whether current player is valid for playing. This will check the internal player exist or not
    public var isValid: Bool {
        player != nil
    }
    
    /// Current playing status
    public var isPlaying: Bool {
        player?.isPlaying ?? false
    }
    
    /// Start the animation
    public func startPlaying() {
        player?.startPlaying()
    }
    
    /// Pause the animation
    public func pausePlaying() {
        player?.pausePlaying()
    }
    
    /// Stop the animation
    public func stopPlaying() {
        player?.stopPlaying()
    }
    
    /// Seek to frame and loop count
    public func seekToFrame(at: UInt, loopCount: UInt) {
        player?.seekToFrame(at: at, loopCount: loopCount)
    }
    
    /// Clear the frame buffer
    public func clearFrameBuffer() {
        player?.clearFrameBuffer()
    }
    
    /// Setup the player using Animated Image.
    /// After setup, you can always check `isValid` status, or call `startPlaying` to play the animation.
    /// - Parameter image: animated image
    public func setupPlayer(animatedImage: SDAnimatedImageProvider) {
        if isValid {
            return
        }
        if let imagePlayer = SDAnimatedImagePlayer(provider: animatedImage) {
            imagePlayer.animationFrameHandler = { [weak self] (index, frame) in
                self?.currentFrameIndex = index
                self?.currentFrame = frame
            }
            imagePlayer.animationLoopHandler = { [weak self] (loopCount) in
                self?.currentLoopCount = loopCount
            }
            // Setup configuration
            if let maxBufferSize = maxBufferSize {
                imagePlayer.maxBufferSize = maxBufferSize
            }
            if let customLoopCount = customLoopCount {
                imagePlayer.totalLoopCount = customLoopCount
            }
            imagePlayer.runLoopMode = runLoopMode
            imagePlayer.playbackRate = playbackRate
            imagePlayer.playbackMode = playbackMode
            
            self.player = imagePlayer
        }
    }
}
