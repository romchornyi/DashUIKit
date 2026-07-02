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

public struct SystemMessageView: View {

    public let title: String
    public let subtitle: String
    public let buttonName: String?
    public let onAction: (() -> Void)?

    public init(
        title: String,
        subtitle: String,
        buttonName: String? = nil,
        onAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.buttonName = buttonName
        self.onAction = onAction
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(dash: .custom("warning_triangle", bundle: .dashUIKit))
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .dashFont(.subheadMedium)
                        .foregroundColor(Color.dash.primaryText)

                    Text(subtitle)
                        .dashFont(.subhead)
                        .foregroundColor(Color.dash.secondaryText)
                        .multilineTextAlignment(.leading)
                }

                if let buttonName, let onAction {
                    DashUIKit.DashButton(
                        text: buttonName,
                        size: .small,
                        style: .filledBlue,
                        action: onAction
                    )
                }

            }
            .padding(.trailing, 20)
            .padding(.top, 5)
        }
        .padding(16)
        .background(Color.dash.gray300Alpha10)
        .clipShape(.rect(cornerRadius: 20))
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 17, macOS 14, *)
#Preview {
    SystemMessageView(
        title: "You have a balance on CrowdNode",
        subtitle: "These funds should be withdrawn from CrowdNode. You can transfer these funds to this wallet or via your online account on some other device."
    )
        .padding()
}

#endif // DEBUG
