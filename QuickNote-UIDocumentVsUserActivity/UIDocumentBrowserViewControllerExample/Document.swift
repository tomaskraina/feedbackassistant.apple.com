//
//  Document.swift
//  UIDocumentBrowserViewControllerExample
//
//  Created by Tom Kraina on 14.06.2021.
//  Copyright © 2021 Tom Kraina. All rights reserved.
//

import UIKit

class Document: UIDocument {
    
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
    }

    // MARK: NSUserActivity

    override func updateUserActivityState(_ userActivity: NSUserActivity) {
        super.updateUserActivityState(userActivity)

        print(#function)
        dump(userActivity)
    }

    override func restoreUserActivityState(_ userActivity: NSUserActivity) {
        super.restoreUserActivityState(userActivity)

        
    }
}

