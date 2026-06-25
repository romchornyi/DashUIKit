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

// MARK: - EnterAmountView

@available(iOS 14, macOS 11, *)
public struct EnterAmountView: View {

    @Binding public var value: String
    @Binding public var selectedCurrency: CurrencyOption
    public var options: [CurrencyOption]
    public var onMax: (() -> Void)?
    public var onCurrencyTap: (() -> Void)?

    public init(
        value: Binding<String>,
        selectedCurrency: Binding<CurrencyOption>,
        options: [CurrencyOption],
        onMax: (() -> Void)? = nil,
        onCurrencyTap: (() -> Void)? = nil
    ) {
        self._value = value
        self._selectedCurrency = selectedCurrency
        self.options = options
        self.onMax = onMax
        self.onCurrencyTap = onCurrencyTap
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 40) {
            maxButton
            amountView
            currencyPickerView
        }
    }

    private var maxButton: some View {
        Button {
            onMax?()
        } label: {
            ZStack {
                Circle()
                    .fill(Color.dash.blueAlpha5)
                    .frame(width: 40, height: 40)

                Text(NSLocalizedString("Max", bundle: .module, comment: ""))
                    .font(Font.dash.caption2)
                    .foregroundColor(Color.dash.blue)
            }
        }
    }

    private var amountView: some View {
        SwapAmountView(
            amount: value,
            symbol: selectedCurrency.symbol,
            showDashLogo: selectedCurrency == .dash,
            showCurrencyButton: selectedCurrency.isFiat,
            onCurrencyTap: onCurrencyTap
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var currencyPickerView: some View {
        DashPickerView(
            options: options,
            title: { $0.displayName },
            selected: $selectedCurrency
        )
    }
}

#if DEBUG

@available(iOS 17, macOS 14, *)
#Preview {
    EnterAmountView(
        value: .constant("12.5"),
        selectedCurrency: .constant(.dash),
        options: [.fiat("USD"), .dash, .coin("BTC")]
    )
    .frame(height: 110)
    .background(Color.dash.secondaryBackground)
    .padding(20)
}

#endif
