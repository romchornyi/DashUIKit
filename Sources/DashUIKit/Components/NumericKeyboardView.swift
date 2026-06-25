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

// MARK: - NumericKeyboardView

@available(iOS 14, macOS 11, *)
public struct NumericKeyboardView: View {

    private enum Layout {
        static let rootSpacing: CGFloat = 20
        static let rowsSpacing: CGFloat = 10
        static let rowSpacing: CGFloat = 10
        static let horizontalPadding: CGFloat = 40
        static let keyFontSize: CGFloat = 20
        static let keyFontWeight: Font.Weight = .medium
        static let disabledOpacity: CGFloat = 0.5
        static let enabledOpacity: CGFloat = 1.0

        static let decimalKey = "."
        static let zeroKey = "0"
        static let emptyKey = ""
        static let deleteKey = "⌫"
        static let deleteSymbol = "delete.left"
    }

    @Binding private var value: String
    private let showDecimalSeparator: Bool
    private let actionButtonText: String
    private let actionEnabled: Bool
    private let inProgress: Bool
    private let helperText: String?
    private let actionHandler: () -> Void

    public init(
        value: Binding<String>,
        showDecimalSeparator: Bool,
        actionButtonText: String,
        actionEnabled: Bool,
        inProgress: Bool,
        helperText: String? = nil,
        actionHandler: @escaping () -> Void
    ) {
        self._value = value
        self.showDecimalSeparator = showDecimalSeparator
        self.actionButtonText = actionButtonText
        self.actionEnabled = actionEnabled
        self.inProgress = inProgress
        self.helperText = helperText
        self.actionHandler = actionHandler
    }

    private var rows: [[String]] {
        let lastRow: [String]
        if showDecimalSeparator {
            lastRow = [Layout.decimalKey, Layout.zeroKey, Layout.deleteKey]
        } else {
            lastRow = [Layout.emptyKey, Layout.zeroKey, Layout.deleteKey]
        }

        return [
            ["1", "2", "3"],
            ["4", "5", "6"],
            ["7", "8", "9"],
            lastRow,
        ]
    }

    public var body: some View {
        VStack(spacing: Layout.rootSpacing) {
            keyboardRowsView
            helperTextRow(helperText)
            actionButtonView
        }
        .background(Color.dash.secondaryBackground)
    }

    private var keyboardRowsView: some View {
        VStack(spacing: Layout.rowsSpacing) {
            ForEach(rows, id: \.self) { row in
                keyboardRowView(row)
                    .opacity(inProgress ? Layout.disabledOpacity : Layout.enabledOpacity)
            }
        }
    }

    private func keyboardRowView(_ row: [String]) -> some View {
        HStack(spacing: Layout.rowSpacing) {
            ForEach(row, id: \.self) { key in
                keyButtonView(key)
            }
        }
    }

    private func keyButtonView(_ key: String) -> some View {
        Button {
            handleKeyPress(key)
        } label: {
            keyContentView(key)
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .disabled(inProgress)
    }

    @ViewBuilder
    private func keyContentView(_ key: String) -> some View {
        if key == Layout.deleteKey {
            Image(systemName: Layout.deleteSymbol)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .font(.system(size: Layout.keyFontSize))
                .foregroundColor(Color.dash.primaryText)
        } else {
            Text(key)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .font(.system(size: Layout.keyFontSize, weight: Layout.keyFontWeight))
                .foregroundColor(Color.dash.primaryText)
        }
    }

    private var actionButtonView: some View {
        DashButton(
            text: actionButtonText,
            isEnabled: !value.isEmpty && actionEnabled,
            isLoading: inProgress,
            fillsWidth: true,
            size: .large,
            style: .filledBlue,
            action: actionHandler
        )
        .padding(.horizontal, Layout.horizontalPadding)
    }

    @ViewBuilder
    private func helperTextRow(_ text: String?) -> some View {
        if let text, !text.isEmpty {
            Text(text)
                .font(Font.dash.footnote)
                .foregroundColor(Color.dash.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        } else {
            EmptyView()
        }
    }

    private func handleKeyPress(_ key: String) {
        if key == Layout.deleteKey {
            if !value.isEmpty {
                value.removeLast()
            }
        } else if key == Layout.decimalKey {
            if showDecimalSeparator && !value.contains(".") {
                value += Layout.decimalKey
            }
        } else if !key.isEmpty {
            value += key
        }
    }
}

#if DEBUG

@available(iOS 17, macOS 14, *)
#Preview {
    VStack {
        Spacer()

        NumericKeyboardView(
            value: .constant(""),
            showDecimalSeparator: true,
            actionButtonText: "Verify",
            actionEnabled: true,
            inProgress: false,
            actionHandler: { print("Action button tapped") }
        )
        .padding(.horizontal, 20)
        .background(.red.opacity(0.3))
    }
}

#endif
