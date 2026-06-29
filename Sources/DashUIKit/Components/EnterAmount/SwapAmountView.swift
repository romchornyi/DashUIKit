//
//  Created by Roman Chornyi
//  Copyright © 2026 Dash Core Group. All rights reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://opensource.org/licenses/MIT
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import SwiftUI

// MARK: - SwapAmountView

@available(iOS 14, macOS 11, *)
public struct SwapAmountView: View {

    // MARK: Primary row props

    public let amount: String
    public var symbol: String? = nil
    public var secondaryText: String? = nil
    public var topText: String? = nil
    public var bottomText: String? = nil
    public var showDashLogo: Bool = false
    public var showCurrencyButton: Bool = false
    public var onCurrencyTap: (() -> Void)? = nil

    // MARK: Secondary row props (only used in animated dual-swap mode)

    /// Currency symbol for the B row (secondary logical value). Nil = no symbol.
    public var secondarySymbol: String? = nil
    /// Show the Dash logo on the B row.
    public var showSecondaryDashLogo: Bool = false
    /// Show a currency-select chevron beside the B row's amount.
    public var showSecondaryCurrencyButton: Bool = false
    /// Action fired when the secondary-row chevron is tapped.
    public var onSecondaryCurrencyTap: (() -> Void)? = nil
    /// When non-nil, enables the animated dual-swap ZStack layout and acts as the animation key.
    /// `true` = A row (amount) is the large/top slot; `false` = B row (secondaryText) is.
    /// Nil = static single-amount layout (`.single` usage).
    public var swapAnimationKey: Bool? = nil

    // MARK: Init

    public init(
        amount: String,
        symbol: String? = nil,
        secondaryText: String? = nil,
        topText: String? = nil,
        bottomText: String? = nil,
        showDashLogo: Bool = false,
        showCurrencyButton: Bool = false,
        onCurrencyTap: (() -> Void)? = nil,
        secondarySymbol: String? = nil,
        showSecondaryDashLogo: Bool = false,
        showSecondaryCurrencyButton: Bool = false,
        onSecondaryCurrencyTap: (() -> Void)? = nil,
        swapAnimationKey: Bool? = nil
    ) {
        self.amount = amount
        self.symbol = symbol
        self.secondaryText = secondaryText
        self.topText = topText
        self.bottomText = bottomText
        self.showDashLogo = showDashLogo
        self.showCurrencyButton = showCurrencyButton
        self.onCurrencyTap = onCurrencyTap
        self.secondarySymbol = secondarySymbol
        self.showSecondaryDashLogo = showSecondaryDashLogo
        self.showSecondaryCurrencyButton = showSecondaryCurrencyButton
        self.onSecondaryCurrencyTap = onSecondaryCurrencyTap
        self.swapAnimationKey = swapAnimationKey
    }

    // MARK: Body

    public var body: some View {
        content
    }

    private var content: some View {
        VStack(spacing: 2) {
            if let top = topText {
                Text(top)
                    .font(Font.dash.caption1)
                    .foregroundColor(Color.dash.tertiaryText)
            }

            if let animKey = swapAnimationKey {
                animatedBody(isPrimaryLarge: animKey)
            } else {
                staticBody
            }

            if let bottom = bottomText {
                Text(bottom)
                    .font(Font.dash.caption1)
                    .foregroundColor(Color.dash.tertiaryText)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Static layout (unchanged from original — drives .single)

    private var staticBody: some View {
        VStack(spacing: 0) {
            primaryRow

            if let secondary = secondaryText {
                Text(secondary)
                    .font(Font.dash.subhead)
                    .foregroundColor(Color.dash.tertiaryText)
            }
        }
    }

    // MARK: Animated dual-swap layout

    /// Thin forwarder — instantiates `AnimatedSwapLayout` which owns the two-phase animation state.
    /// Phase 1 (font/color/icon swap) snaps immediately; phase 2 (offset glide) follows after a delay.
    @ViewBuilder
    private func animatedBody(isPrimaryLarge: Bool) -> some View {
        AnimatedSwapLayout(
            amount: amount,
            symbol: symbol,
            secondaryText: secondaryText,
            showDashLogo: showDashLogo,
            showCurrencyButton: showCurrencyButton,
            onCurrencyTap: onCurrencyTap,
            secondarySymbol: secondarySymbol,
            showSecondaryDashLogo: showSecondaryDashLogo,
            showSecondaryCurrencyButton: showSecondaryCurrencyButton,
            onSecondaryCurrencyTap: onSecondaryCurrencyTap,
            isPrimaryLarge: isPrimaryLarge
        )
    }

    // MARK: Rows

    private var primaryRow: some View {
        // Amount (symbol + number + logo) and the currency chevron scale down together as ONE
        // centered unit, so the chevron stays right next to the amount instead of being pushed to
        // the far edge (scaleToFitWidth fills the width, so it must wrap the whole group, not just
        // the amount). Renders full-size when it fits; shrinks uniformly when it doesn't.
        HStack(spacing: 6) {
            amountView(font: Font.dash.largeTitle, dashSize: .init(width: 19, height: 16))
                .foregroundColor(Color.dash.primaryText)

            if showCurrencyButton {
                Button {
                    onCurrencyTap?()
                } label: {
                    Image(dash: .custom("chevron-down-currency-select", bundle: .dashUIKit))
                        .frame(width: 10, height: 5)
                }
                .buttonStyle(.plain)
            }
        }
        .scaleToFitWidth()
        .frame(maxWidth: .infinity)
    }

    // MARK: Amount content views

    private func amountView(font: Font, dashSize: CGSize? = nil) -> some View {
        HStack(spacing: 4) {
            if let sym = symbol, !sym.isEmpty {
                Text(sym)
                    .font(font)
            }

            Text(displayAmount)
                .font(font)

            if showDashLogo {
                Image(dash: .custom("enter-amount-dash", bundle: .dashUIKit))
                    .resizable()
                    .scaledToFit()
                    .frame(width: dashSize?.width, height: dashSize?.height)
            }
        }
    }

    private func secondaryAmountView(font: Font) -> some View {
        HStack(spacing: 4) {
            if let sym = secondarySymbol, !sym.isEmpty {
                Text(sym)
                    .font(font)
            }

            Text(displaySecondary)
                .font(font)

            if showSecondaryDashLogo {
                Image(dash: .custom("enter-amount-dash", bundle: .dashUIKit))
            }
        }
    }

    // MARK: Display normalisers

    /// The numeric string as shown to the user. Pure display transform:
    /// - empty → "0"
    /// - bare-decimal input gets a leading zero: ".34" → "0.34", "." → "0." (same for ",")
    /// Does NOT trim, reformat, or cap precision — that happens upstream in `sanitize`.
    private var displayAmount: String {
        guard !amount.isEmpty else { return "0" }
        if let first = amount.first, first == "." || first == "," {
            return "0" + amount
        }
        return amount
    }

    private var displaySecondary: String {
        guard let s = secondaryText, !s.isEmpty else { return "0" }
        if let first = s.first, first == "." || first == "," { return "0" + s }
        return s
    }
}

// MARK: - AnimatedSwapLayout

/// Private stateful sub-view that drives the two-phase dual-swap animation.
///
/// **Phase 1 — font/color/icon sizes** (`fontPrimary` state):
/// Snaps immediately when `isPrimaryLarge` changes — no animation modifier applied.
/// The row moving to the large slot gets `largeTitle` + full-brightness color + full-size icons;
/// the row moving to the small slot gets `subhead` + dimmed color + small icons.
///
/// **Phase 2 — offset/opacity** (`offsetPrimary` state):
/// After a `fontPhase` delay, the two rows glide to their new vertical positions via
/// `withAnimation(.easeInOut(duration: offsetPhase))`.
///
/// Rapid re-taps are safe: each phase independently converges to the latest `isPrimaryLarge` value.
@available(iOS 14, macOS 11, *)
private struct AnimatedSwapLayout: View {

    // MARK: Content props (forwarded from SwapAmountView)

    let amount: String
    let symbol: String?
    let secondaryText: String?
    let showDashLogo: Bool
    let showCurrencyButton: Bool
    let onCurrencyTap: (() -> Void)?
    let secondarySymbol: String?
    let showSecondaryDashLogo: Bool
    let showSecondaryCurrencyButton: Bool
    let onSecondaryCurrencyTap: (() -> Void)?
    /// The desired target state driven by the host.
    let isPrimaryLarge: Bool

    // MARK: Phase state

    /// Controls fonts, foreground colors, and icon sizes. Snaps to `isPrimaryLarge` immediately.
    @State private var fontPrimary: Bool
    /// Controls vertical offsets and opacity. Animates to `isPrimaryLarge` after `fontPhase` delay.
    @State private var offsetPrimary: Bool

    // MARK: Timing constants

    /// Seconds to wait after the font snap before starting the offset glide.
    static let fontPhase: Double = 0.15
    /// Duration of the offset glide easing.
    static let offsetPhase: Double = 0.2

    // MARK: Init

    init(
        amount: String,
        symbol: String?,
        secondaryText: String?,
        showDashLogo: Bool,
        showCurrencyButton: Bool,
        onCurrencyTap: (() -> Void)?,
        secondarySymbol: String?,
        showSecondaryDashLogo: Bool,
        showSecondaryCurrencyButton: Bool,
        onSecondaryCurrencyTap: (() -> Void)?,
        isPrimaryLarge: Bool
    ) {
        self.amount = amount
        self.symbol = symbol
        self.secondaryText = secondaryText
        self.showDashLogo = showDashLogo
        self.showCurrencyButton = showCurrencyButton
        self.onCurrencyTap = onCurrencyTap
        self.secondarySymbol = secondarySymbol
        self.showSecondaryDashLogo = showSecondaryDashLogo
        self.showSecondaryCurrencyButton = showSecondaryCurrencyButton
        self.onSecondaryCurrencyTap = onSecondaryCurrencyTap
        self.isPrimaryLarge = isPrimaryLarge
        _fontPrimary = State(initialValue: isPrimaryLarge)
        _offsetPrimary = State(initialValue: isPrimaryLarge)
    }

    // MARK: Body

    var body: some View {
        // Phase 1 derives: font, foreground color, icon sizes
        let aFont: Font         = fontPrimary ? Font.dash.largeTitle : Font.dash.subhead
        let bFont: Font         = fontPrimary ? Font.dash.subhead    : Font.dash.largeTitle
        let aColor: Color       = fontPrimary ? Color.dash.primaryText   : Color.dash.tertiaryText
        let bColor: Color       = fontPrimary ? Color.dash.tertiaryText  : Color.dash.primaryText
        let dashSize: CGSize    = fontPrimary ? .init(width: 19, height: 16) : .init(width: 10, height: 8)
        let chevronSize: CGSize = fontPrimary ? .init(width: 5, height: 2.5) : .init(width: 10, height: 5)

        ZStack(alignment: .center) {
            // A row — always carries the primary logical value
            HStack(spacing: 6) {
                amountContent(font: aFont, dashSize: dashSize)
                    .foregroundColor(aColor)
                if showCurrencyButton {
                    Button { onCurrencyTap?() } label: {
                        Image(dash: .custom("chevron-down-currency-select", bundle: .dashUIKit))
                            .frame(width: 10, height: 5)
                    }
                    .buttonStyle(.plain)
                }
            }
            .scaleToFitWidth()
            .frame(maxWidth: .infinity)
            // Phase 2 drives offset + opacity
            .offset(y: offsetPrimary ? SwapAnimLayout.primaryOffset : SwapAnimLayout.secondaryOffset)
            .opacity(offsetPrimary ? 1.0 : SwapAnimLayout.secondaryOpacity)

            // B row — always carries the secondary logical value; shows optional chevron
            HStack(spacing: 6) {
                secondaryContent(font: bFont, dashSize: dashSize)
                if showSecondaryCurrencyButton {
                    Button { onSecondaryCurrencyTap?() } label: {
                        Image(dash: .custom("chevron-down-currency-select", bundle: .dashUIKit))
                            .resizable()
                            .scaledToFill()
                            .frame(width: chevronSize.width, height: chevronSize.height)
                            .foregroundColor(Color.dash.gray400)
                    }
                    .buttonStyle(.plain)
                }
            }
            .foregroundColor(bColor)
            .scaleToFitWidth()
            .frame(maxWidth: .infinity)
            // Phase 2 drives offset + opacity
            .offset(y: offsetPrimary ? SwapAnimLayout.secondaryOffset : SwapAnimLayout.primaryOffset)
            .opacity(offsetPrimary ? SwapAnimLayout.secondaryOpacity : 1.0)
        }
        .frame(height: SwapAnimLayout.containerHeight)
        .frame(maxWidth: .infinity)
        .onChange(of: isPrimaryLarge) { newValue in
            // Phase 1: font/color/icon sizes snap immediately (no animation)
            fontPrimary = newValue
            // Phase 2: after the font phase settles, glide the offsets
            DispatchQueue.main.asyncAfter(deadline: .now() + Self.fontPhase) {
                withAnimation(.easeInOut(duration: Self.offsetPhase)) {
                    offsetPrimary = newValue
                }
            }
        }
    }

    // MARK: Row content helpers

    private func amountContent(font: Font, dashSize: CGSize) -> some View {
        HStack(spacing: 4) {
            if let sym = symbol, !sym.isEmpty {
                Text(sym).font(font)
            }
            Text(displayAmount).font(font)
            if showDashLogo {
                Image(dash: .custom("enter-amount-dash", bundle: .dashUIKit))
                    .resizable()
                    .scaledToFit()
                    .frame(width: dashSize.width, height: dashSize.height)
            }
        }
    }

    private func secondaryContent(font: Font, dashSize: CGSize) -> some View {
        HStack(spacing: 4) {
            if let sym = secondarySymbol, !sym.isEmpty {
                Text(sym).font(font)
            }
            Text(displaySecondary).font(font)
            if showSecondaryDashLogo {
                Image(dash: .custom("enter-amount-dash", bundle: .dashUIKit))
                    .resizable()
                    .scaledToFit()
                    .frame(width: dashSize.width, height: dashSize.height)
            }
        }
    }

    private var displayAmount: String {
        guard !amount.isEmpty else { return "0" }
        if let first = amount.first, first == "." || first == "," { return "0" + amount }
        return amount
    }

    private var displaySecondary: String {
        guard let s = secondaryText, !s.isEmpty else { return "0" }
        if let first = s.first, first == "." || first == "," { return "0" + s }
        return s
    }
}

// MARK: - Swap animation layout constants

// Internal so DualSwapAmountView can read them if needed; private would hide from the module.
@available(iOS 14, macOS 11, *)
enum SwapAnimLayout {
    // Slot heights (reference: SendAmountAmountsStack)
    static let primaryHeight: CGFloat = 41
    static let slotSpacing: CGFloat = 0
    static let secondaryHeight: CGFloat = 20
    // Fixed container height prevents layout jumps during animation
    static let containerHeight: CGFloat = primaryHeight + slotSpacing + secondaryHeight  // 70

    // Secondary slot renders at half the primary scale (body 17pt / largeTitle 34pt = 0.5)
    static let secondaryScale: CGFloat = 0.5
    static let secondaryOpacity: CGFloat = 0.67

    // Offsets from ZStack center (= containerHeight / 2 = 35).
    // Primary anchor centre:   primaryHeight / 2 = 21  →  offset = 21 − 35 = −14
    // Secondary anchor centre: primaryHeight + slotSpacing + secondaryHeight / 2 = 60  →  offset = 60 − 35 = +25
    static let primaryOffset: CGFloat = -(containerHeight / 2 - primaryHeight / 2)
    static let secondaryOffset: CGFloat = primaryHeight + slotSpacing + secondaryHeight / 2 - containerHeight / 2
}

// MARK: - Previews

#if DEBUG

@available(iOS 17, macOS 14, *)
#Preview("Normal amounts") {
    VStack(spacing: 20) {
        SwapAmountView(
            amount: "1.5",
            secondaryText: "$ 150.00",
            topText: "Enter amount",
            showDashLogo: true
        )
        SwapAmountView(
            amount: "100",
            symbol: "$",
            secondaryText: "Ð 1.0",
            showCurrencyButton: true
        )
    }
    .padding(20)
}

@available(iOS 17, macOS 14, *)
#Preview("Edge cases — scaling") {
    VStack(spacing: 20) {
        SwapAmountView(
            amount: "99999.99999999",
            topText: "Dash — very long",
            showDashLogo: true
        )
        SwapAmountView(
            amount: "123456.78",
            symbol: "$",
            topText: "Fiat — long with button",
            showCurrencyButton: true
        )
        SwapAmountView(
            amount: "0.00012345",
            symbol: "BTC",
            topText: "Crypto — small value"
        )
    }
    .padding(20)
}

@available(iOS 17, macOS 14, *)
#Preview("Edge cases — precision") {
    VStack(spacing: 20) {
        SwapAmountView(
            amount: "0.13",
            symbol: "$",
            topText: "Fiat 0.13 (max 2 dp)",
            showCurrencyButton: true
        )
        SwapAmountView(
            amount: "1",
            topText: "Normalized from 01 → 1",
            showDashLogo: true
        )
        SwapAmountView(
            amount: "0.",
            symbol: "$",
            topText: "In-progress: 0.",
            showCurrencyButton: true
        )
    }
    .padding(20)
}

@available(iOS 17, macOS 14, *)
#Preview("Leading zero — bare decimal") {
    VStack(spacing: 20) {
        SwapAmountView(
            amount: ".34",
            topText: "Bare decimal: .34 → 0.34",
            showDashLogo: true
        )
        SwapAmountView(
            amount: ".",
            symbol: "$",
            topText: "In-progress: . → 0.",
            showCurrencyButton: true
        )
    }
    .padding(20)
}

@available(iOS 17, macOS 14, *)
#Preview("Animated dual-swap (interactive)") {
    VStack {
        SwapAmountView(
            amount: "1.5",
            secondaryText: "$ 150.00",
            topText: "Enter amount",
            showDashLogo: true
        )

        SwapAmountAnimatedPreview()
            .background(Color.dash.secondaryBackground)
            .padding(20)
    }
}

@available(iOS 17, macOS 14, *)
private struct SwapAmountAnimatedPreview: View {
    @State private var isPrimarySelected = true

    var body: some View {
        VStack(spacing: 16) {
            Text(isPrimarySelected ? "Dash is primary (large)" : "Fiat is primary (large)")
                .font(Font.dash.caption1)
                .foregroundColor(Color.dash.tertiaryText)

            SwapAmountView(
                amount: "1.23456",
                symbol: nil,
                secondaryText: "150.00",
                topText: "Enter amount",
                showDashLogo: true,
                secondarySymbol: "$",
                showSecondaryCurrencyButton: true,
                onSecondaryCurrencyTap: {},
                swapAnimationKey: isPrimarySelected
            )
            .contentShape(Rectangle())
            .onTapGesture { isPrimarySelected.toggle() }

            Button("Tap to swap") { isPrimarySelected.toggle() }
                .font(Font.dash.footnote)
                .foregroundColor(Color.dash.blue)
        }
    }
}

#endif
