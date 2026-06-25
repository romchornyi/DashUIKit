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

    public let amount: String
    public var symbol: String? = nil
    public var secondaryText: String? = nil
    public var topText: String? = nil
    public var bottomText: String? = nil
    public var showDashLogo: Bool = false
    public var showCurrencyButton: Bool = false
    public var onCurrencyTap: (() -> Void)? = nil

    public init(
        amount: String,
        symbol: String? = nil,
        secondaryText: String? = nil,
        topText: String? = nil,
        bottomText: String? = nil,
        showDashLogo: Bool = false,
        showCurrencyButton: Bool = false,
        onCurrencyTap: (() -> Void)? = nil
    ) {
        self.amount = amount
        self.symbol = symbol
        self.secondaryText = secondaryText
        self.topText = topText
        self.bottomText = bottomText
        self.showDashLogo = showDashLogo
        self.showCurrencyButton = showCurrencyButton
        self.onCurrencyTap = onCurrencyTap
    }

    public var body: some View {
        VStack(spacing: 2) {
            if let top = topText {
                Text(top)
                    .font(Font.dash.caption1)
                    .foregroundColor(Color.dash.tertiaryText)
            }

            VStack(spacing: 0) {
                primaryRow

                if let secondary = secondaryText {
                    Text(secondary)
                        .font(Font.dash.subhead)
                        .foregroundColor(Color.dash.tertiaryText)
                }
            }

            if let bottom = bottomText {
                Text(bottom)
                    .font(Font.dash.caption1)
                    .foregroundColor(Color.dash.tertiaryText)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var primaryRow: some View {
        // Amount (symbol + number + logo) and the currency chevron scale down together as ONE
        // centered unit, so the chevron stays right next to the amount instead of being pushed to
        // the far edge (scaleToFitWidth fills the width, so it must wrap the whole group, not just
        // the amount). Renders full-size when it fits; shrinks uniformly when it doesn't.
        HStack(spacing: 6) {
            amountView
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

    private var amountView: some View {
        HStack(spacing: 4) {
            if let sym = symbol, !sym.isEmpty {
                Text(sym)
                    .font(Font.dash.largeTitle)
            }

            Text(displayAmount)
                .font(Font.dash.largeTitle)

            if showDashLogo {
                Image(dash: .custom("enter-amount-dash", bundle: .dashUIKit))
            }
        }
    }
}

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

#endif
