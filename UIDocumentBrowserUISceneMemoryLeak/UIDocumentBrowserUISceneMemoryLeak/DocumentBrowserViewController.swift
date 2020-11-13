//
//  DocumentBrowserViewController.swift
//  UIDocumentBrowserUISceneMemoryLeak
//
//  Created by Tom Kraina on 12/11/2020.
//

import UIKit


class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
    }
}
