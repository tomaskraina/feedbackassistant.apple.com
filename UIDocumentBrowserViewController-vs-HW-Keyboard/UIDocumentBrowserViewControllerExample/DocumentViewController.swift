//
//  DocumentViewController.swift
//  UIDocumentBrowserViewControllerExample
//
//  Created by Tom Kraina on 11.9.2019.
//  Copyright © 2019 Tom Kraina. All rights reserved.
//

import UIKit

class DocumentViewController: UIViewController {
    
    @IBOutlet weak var documentNameLabel: UILabel!
    
    var document: UIDocument?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Access the document
        document?.open(completionHandler: { (success) in
            if success {
                // Display the content of the document, e.g.:
                self.documentNameLabel.text = self.document?.fileURL.lastPathComponent
            } else {
                // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
            }
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.becomeFirstResponder()
    }
}

// MARK: - UIResponder

extension DocumentViewController {

    override var canBecomeFirstResponder: Bool { true }

    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(title: "Search", action: #selector(DocumentViewController.search), input: "F", modifierFlags: .command, discoverabilityTitle: "Perform Search")
        ]
    }
}

// MARK: - Private

extension DocumentViewController {

    @IBAction func dismissDocumentViewController() {
        dismiss(animated: true) {
            self.document?.close(completionHandler: nil)
        }
    }

    @objc func search() {
        let alert = UIAlertController(title: "Search", message: "CMD+F pressed", preferredStyle: .alert)
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
}
