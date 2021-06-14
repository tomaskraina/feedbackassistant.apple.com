//
//  NSUserActivityExtensions.swift
//  UIDocumentBrowserViewControllerExample
//
//  Created by Tom Kraina on 14.06.2021.
//  Copyright © 2021 Tom Kraina. All rights reserved.
//

import Foundation


// To print NSUserActivity's properties using `po` in console and 'dump()' in code
extension NSUserActivity: CustomReflectable {

    public var customMirror: Mirror {
        let children = KeyValuePairs<String, Any>(dictionaryLiteral:
            ("activityType", activityType),
            ("title", title ?? "nil"),
            ("userInfo", userInfo.debugDescription),
            ("requiredUserInfoKeys", requiredUserInfoKeys as Any),
            ("needsSave", needsSave),
            ("webpageURL", webpageURL?.debugDescription ?? "nil"),
            ("referrerURL", referrerURL?.debugDescription ?? "nil"),
            ("expirationDate", value(forKey: #keyPath(NSUserActivity.expirationDate)) ?? "nil"), // rdar://30972918
            ("keywords", keywords),
            ("supportsContinuationStreams", supportsContinuationStreams),
            ("delegate", delegate ?? "nil"),
            ("targetContentIdentifier", targetContentIdentifier ?? "nil"),
            ("isEligibleForHandoff", isEligibleForHandoff),
            ("isEligibleForSearch", isEligibleForSearch),
            ("isEligibleForPublicIndexing", isEligibleForPublicIndexing),
            ("isEligibleForPrediction", isEligibleForPrediction),
            ("persistentIdentifier", persistentIdentifier?.debugDescription ?? "nil"))

        return Mirror(NSUserActivity.self, children: children, displayStyle: .class, ancestorRepresentation: .suppressed)
    }
}
