//
//  BookmarkEncoder.swift
//  UIDocumentBrowserViewControllerExample
//
//  Created by Tom Kraina on 14.06.2021.
//  Copyright © 2021 Tom Kraina. All rights reserved.
//

import Foundation


enum MNCBookmarkEncoder {

    static func urlEncodedString(from documentURL: URL) -> String? {
        guard let bookmarkData = documentURL.bookmarkData else { return nil }

        return self.urlEncodedString(from: bookmarkData)
    }

    static func urlEncodedString(from data: Data) -> String? {
        return data.base64EncodedString().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }

    static func bookmarkData(from urlEncodedString: String) -> Data? {
        guard let bookmarkString = urlEncodedString.removingPercentEncoding else { return nil }

        return Data(base64Encoded: bookmarkString)
    }
}

/// Convenience methods to work with (Security-Scoped) Bookmarks
extension URL {

    init?(bookmarkData: Data, relativeTo relativeURL: URL?) {
        var isStale: Bool = false // currently ignored
        try? self.init(resolvingBookmarkData: bookmarkData, options: .withoutUI, relativeTo: relativeURL, bookmarkDataIsStale: &isStale)
    }

    var bookmarkData: Data? {
        return try? self.bookmarkData(options: .suitableForBookmarkFile, includingResourceValuesForKeys: nil, relativeTo: self.absoluteURL)
    }
}
