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

#if canImport(UIKit)
import SwiftUI
import UIKit

// MARK: - BackgroundBlurView

@available(iOS 14, *)
struct BackgroundBlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

// MARK: - ToastStyle

/// NOTE: Create the 6 imagesets listed below under
/// `Media.xcassets/Icons & Illustrations/Toast/` before shipping.
/// Until they exist, the icon slot renders empty — that is expected.
///
///   toast-warning.imageset
///   toast-info.imageset
///   toast-error.imageset
///   toast-success.imageset
///   toast-copied.imageset
///   toast-loading.imageset   (optional — `loading` uses a spinner by default)
@available(iOS 14, macOS 11, *)
public enum ToastStyle {
    case warning, info, error, success, copied, loading

    var iconName: String {
        switch self {
        case .warning: return "toast-warning"
        case .info:    return "toast-info"
        case .error:   return "toast-error"
        case .success: return "toast-success"
        case .copied:  return "toast-copied"
        case .loading: return "toast-loading"
        }
    }
}

// MARK: - Toast

@available(iOS 14, macOS 11, *)
public struct Toast: View {

    private let style: ToastStyle
    private let message: String
    private let onDismiss: (() -> Void)?

    public init(
        style: ToastStyle,
        message: String,
        onDismiss: (() -> Void)? = nil
    ) {
        self.style = style
        self.message = message
        self.onDismiss = onDismiss
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            HStack(alignment: .top, spacing: 10) {
                leadingIcon
                    .frame(width: 24, height: 24)

                Text(message)
                    .font(Font.dash.subhead)
                    .foregroundColor(Color.dash.toastText)
                    .padding(.vertical, 2)

                Spacer(minLength: 0)
            }

            if let onDismiss = onDismiss {
                Button(action: onDismiss) {
                    Image(dash: .custom("xmark-icon", bundle: .dashUIKit))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 9, height: 9)
                        .padding(8)
                        .background(Circle().fill(Color.dash.whiteAlpha10))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.leading, 12)
        .padding(.trailing, 8)
        .padding(.vertical, 8)
        .background(
            ZStack {
                BackgroundBlurView()
                Color.dash.toastBackground
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var leadingIcon: some View {
        // TODO: Replace with a custom animated icon for the loading style when assets are ready.
        if case .loading = style {
            ProgressView()
                .accentColor(Color.dash.toastText)
        } else {
            Image(dash: .custom(style.iconName, bundle: .dashUIKit))
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
        }
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 17, macOS 14, *)
#Preview {
    VStack(spacing: 12) {
        Toast(style: .warning, message: "Some coins are not available", onDismiss: {})
        Toast(style: .info, message: "Heads up")
        Toast(style: .error, message: "Something went wrong", onDismiss: {})
        Toast(style: .success, message: "Done")
        Toast(style: .copied, message: "Copied to clipboard")
        Toast(style: .loading, message: "Loading…")
    }
    .padding()
    .background(Color.dash.blue)
}

#endif
#endif // canImport(UIKit)
