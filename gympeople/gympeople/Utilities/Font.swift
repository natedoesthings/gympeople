//
//  Font.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/4/25.
//

import SwiftUI
import UIKit

extension Font {
    static func app(_ style: Font.TextStyle) -> Font {
        let base = UIFont.preferredFont(forTextStyle: style.uiKitStyle).pointSize
        return .custom("RobotoMono-Regular", size: base)
    }
}

private extension Font.TextStyle {
    var uiKitStyle: UIFont.TextStyle {
        switch self {
        case .largeTitle:  return .largeTitle
        case .title:       return .title1
        case .title2:      return .title2
        case .title3:      return .title3
        case .headline:    return .headline
        case .subheadline: return .subheadline
        case .body:        return .body
        case .callout:     return .callout
        case .footnote:    return .footnote
        case .caption:     return .caption1
        case .caption2:    return .caption2
        @unknown default:  return .body
        }
    }
}
