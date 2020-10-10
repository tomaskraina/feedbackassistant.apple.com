//
//  DocumentBrowserTransitioningCoordinator.swift
//  UIDocumentBrowserViewControllerExample
//
//  Created by Tom Kraina on 10/10/2020.
//  Copyright © 2020 Tom Kraina. All rights reserved.
//

import UIKit


/// Manages transitions when presenting documents from the Document Browser
final class DocumentTransitionCoordinator: NSObject {

    private var transitionController: UIDocumentBrowserTransitionController?

    // MARK: - DocumentTransitionCoordinator

    func registerTransition(from browserViewController: UIDocumentBrowserViewController, forURL documentURL: URL) {
        self.transitionController = browserViewController.transitionController(forDocumentAt: documentURL)
        self.transitionController?.loadingProgress = Progress(totalUnitCount: -1)
    }

    func unregisterTransition() {
        self.transitionController?.loadingProgress = nil
        self.transitionController = nil
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension DocumentTransitionCoordinator: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.transitionController
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.transitionController
    }
}
