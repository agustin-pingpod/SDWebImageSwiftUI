/*
* This file is part of the SDWebImage package.
* (c) DreamPiggy <lizhuoli1126@126.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

import Foundation
import SwiftUI

/// A  type to build the indicator
@available(iOS 14.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct Indicator {
    public struct Configuration {
        /// A Binding to control the animation. If image is during loading, the value is true, else (like start loading) the value is false.
        public var isAnimating: Binding<Bool>
        /// A Binding to control the progress during loading. Value between [0.0, 1.0]. If no progress can be reported, the value is 0.
        public var progress: Binding<Double>

        public init(isAnimating: Binding<Bool>, progress: Binding<Double>) {
            self.isAnimating = isAnimating
            self.progress = progress
        }
    }

    private let content: (Configuration) -> AnyView

    public init<V: View>(@ViewBuilder content: @escaping (Configuration) -> V) {
        self.content = { AnyView(content($0)) }
    }

    public func makeBody(configuration: Configuration) -> AnyView {
        content(configuration)
    }
}

/// A protocol to report indicator progress
@available(iOS 14.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public protocol IndicatorReportable : ObservableObject {
    /// whether indicator is loading or not
    var isLoading: Bool { get set }
    /// indicator progress, should only be used for indicator binding, value between [0.0, 1.0]
    var progress: Double { get set }
}

/// A implementation detail View Modifier with indicator
/// SwiftUI View Modifier construced by using a internal View type which modify the `body`
/// It use type system to represent the view hierarchy, and Swift `some View` syntax to hide the type detail for users
@available(iOS 14.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
struct IndicatorViewModifier: ViewModifier {
    /// whether indicator is loading or not
    @Binding var isLoading: Bool
    /// indicator progress, should only be used for indicator binding, value between [0.0, 1.0]
    @Binding var progress: Double
    
    /// The indicator
    @Environment(\.indicator) private var indicator
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if let indicator = indicator, isLoading {
                indicator.makeBody(configuration: .init(isAnimating: $isLoading, progress: $progress))
            }
        }
    }
}

@available(iOS 14.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension IndicatorViewModifier {
    init<R: IndicatorReportable>(reporter: ObservedObject<R>.Wrapper) {
        self.init(isLoading: reporter.isLoading, progress: reporter.progress)
    }
}

extension EnvironmentValues {
    @available(iOS 14.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
    private struct IndicatorKey: EnvironmentKey {
        static var defaultValue: Indicator? { nil }
    }

    @available(iOS 14.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
    var indicator: Indicator? {
        get { self[IndicatorKey.self] }
        set { self[IndicatorKey.self] = newValue }
    }
}

// Activity Indicator
@available(iOS 14.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension Indicator {
    /// Activity Indicator
    public static var activity: Self {
        .init { ActivityIndicator($0.isAnimating) }
    }

    /// Activity Indicator
    public static func activity(style: ActivityIndicator.Style) -> Self {
        .init { ActivityIndicator($0.isAnimating, style: style) }
    }
}

// Progress Indicator
@available(iOS 14.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension Indicator {
    /// Progress Indicator
    public static var progress: Self {
        .init { ProgressIndicator($0.isAnimating, progress: $0.progress) }
    }

    /// Progress Indicator
    public static func progress(style: ProgressIndicator.Style) -> Self {
        .init { ProgressIndicator($0.isAnimating, progress: $0.progress, style: style) }
    }
}
