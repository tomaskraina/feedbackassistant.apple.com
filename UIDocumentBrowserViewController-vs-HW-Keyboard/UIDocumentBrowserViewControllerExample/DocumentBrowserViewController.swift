//
//  DocumentBrowserViewController.swift
//  UIDocumentBrowserViewControllerExample
//
//  Created by Tom Kraina on 11.9.2019.
//  Copyright © 2019 Tom Kraina. All rights reserved.
//

import UIKit

class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {

    private lazy var documentTransitionCoordinator: DocumentTransitionCoordinator = .init()

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        allowsDocumentCreation = true
        allowsPickingMultipleItems = false
    }


    // MARK: - UIDocumentBrowserViewControllerDelegate

    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {

        do {
            let folder = URL(fileURLWithPath: NSTemporaryDirectory())
            let newDocumentURL: URL? = folder
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("txt")

            try self.createFolderIfNecesssary(folder)

            if let newDocumentURL = newDocumentURL {
                let document = Document(fileURL: newDocumentURL)
                document.save(to: newDocumentURL, for: .forCreating) { (saved) in
                    if saved {
                        document.close { (closed) in
                            importHandler(newDocumentURL, .copy)
                        }
                    } else {
                        importHandler(nil, .none)
                    }
                }

            } else {
                importHandler(nil, .none)
            }
        } catch {
            print(error)
            importHandler(nil, .none)
        }
    }

    func createFolderIfNecesssary(_ folderURL: URL) throws {
        let fileManager = FileManager()
        guard fileManager.fileExists(atPath: folderURL.path) == false else { return }

        try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
        presentDocument(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
        presentDocument(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
        print(error?.localizedDescription ?? "ukwnown error")
    }
    
    // MARK: Document Presentation
    
    func presentDocument(at documentURL: URL) {
        self.documentTransitionCoordinator.registerTransition(from: self, forURL: documentURL)

        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let documentViewController = storyBoard.instantiateViewController(withIdentifier: "DocumentViewController") as! DocumentViewController
        documentViewController.document = Document(fileURL: documentURL)
        documentViewController.transitioningDelegate = self.documentTransitionCoordinator
        documentViewController.modalPresentationCapturesStatusBarAppearance = true
        documentViewController.modalPresentationStyle = .overFullScreen // .overFullScreen causes HW keyboard input not being passed to the VC after switching apps
//        documentViewController.modalPresentationStyle = .fullScreen // If we use .fullScreen, the transition to and from open document is broken

        self.present(documentViewController, animated: true)
    }
}
