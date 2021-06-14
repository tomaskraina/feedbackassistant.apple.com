//
//  DocumentViewController.swift
//  UIDocumentBrowserViewControllerExample
//
//  Created by Tom Kraina on 14.06.2021.
//  Copyright © 2021 Tom Kraina. All rights reserved.
//

import UIKit

class DocumentViewController: UIViewController {

    @IBOutlet weak var documentNameLabel: UILabel!
    
    var document: Document?


    override func viewDidLoad() {
        super.viewDidLoad()
    }

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

        // UIKit automatically creates an NSUserActivity object for documents in iCloud, using the given activity type
        // (When the NSUbiquitousDocumentUserActivityType key is present in a CFBundleDocumentTypes entry)
        if let providedUserActivity = self.document?.userActivity {
            print("NSUserActivity for UIDocument provided by UIKit:")
            dump(providedUserActivity)
            self.configureUserActivity(providedUserActivity)
            // FIXME: NSUserActivity object provided by UIKit for iCloud document won't get "Add Link" in Quick Note althought 'persistentIdentifier' is set
            self.userActivity = providedUserActivity
        } else {
            self.userActivity = self.makeLocalDocumentActivity()
        }

        // TODO: In multi-scene setup, should we assign the userActivity on the window scene too?
//        self.view.window?.windowScene?.userActivity = self.userActivity
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // TODO: In multi-scene setup, clear the userActivity on the window scene if needed
//        self.view.window?.windowScene?.userActivity = nil
    }
}

// MARK: - UIResponder

extension DocumentViewController {

    override var canBecomeFirstResponder: Bool { true }

    override func updateUserActivityState(_ activity: NSUserActivity) {
        super.updateUserActivityState(activity)
        print(#function)

        guard let document = self.document else { return }

        // Update title in case it changed
        activity.title = document.documentTitle

        // The 'userInfo' dict should get cleared before 'updateUserActivityState(_:)' is called and needs to be populated again
//        assert(activity.userInfo == nil, "The 'userInfo' dict should get cleared before 'updateUserActivityState(_:)' is called")
//        assert(activity.requiredUserInfoKeys == nil)
        activity.addUserInfoEntries(from: self.documentURLUserInfo)
        activity.requiredUserInfoKeys = Set(self.documentURLUserInfo.keys)

        dump(activity)
    }

    var documentURLUserInfo: [String: Any] {
        assert(self.document != nil, "Property 'document' should be set at this point")
        guard let document = self.document else { return [:] }

        // TODO: Does the bookmark data change if the document moves/renames or is it stable?
        let bookmark = MNCBookmarkEncoder.urlEncodedString(from: document.fileURL)!

        return [
            UIDocument.userActivityURLKey: document.fileURL,
            "bookmark": bookmark
        ]
    }
}


// MARK: - Private

private extension Document {

    var documentTitle: String { self.fileURL.lastPathComponent }
}

private extension DocumentViewController {

    @IBAction func dismissDocumentViewController() {
        self.presentingViewController?.dismiss(animated: true) {
            self.document?.close(completionHandler: nil)
        }
    }

    func makeLocalDocumentActivity() -> NSUserActivity {
        let userActivity = NSUserActivity(activityType: ActivityType.viewDocument.rawValue)
        userActivity.isEligibleForHandoff = true // local documents can't be handed off
        self.configureUserActivity(userActivity)

        return userActivity
    }

    func configureUserActivity(_ userActivity: NSUserActivity) {
        userActivity.isEligibleForSearch = true
        userActivity.isEligibleForPrediction = true
        userActivity.isEligibleForPublicIndexing = false
        userActivity.delegate = self

        assert(self.document != nil, "Property 'document' should be set at this point.")
        if let document = self.document {
            let absoluteFileURLString = document.fileURL.absoluteString

            // We need to provide either 'targetContentIdentifier' or 'persistentIdentifier' before
            // the created user activity is assigned to self.userActivity is called.
            // Failing to do so results in missing "Add link" button in Quick Note window.

            // This string provides a unique identifier for specific content in your app, like a particular document
            // If you set this property, when the system delivers an NSUserActivity object to an app with multiple scenes, it chooses the UIScene whose UISceneActivationConditions have the best match with the target content identifier. For more information, see UISceneActivationConditions.
            userActivity.targetContentIdentifier = absoluteFileURLString

            // Set this property to a value that identifies the user activity so you can later delete it
            // with deleteSavedUserActivities(withPersistentIdentifiers:completionHandler:)
            userActivity.persistentIdentifier = absoluteFileURLString

            userActivity.userInfo = self.documentURLUserInfo
            userActivity.requiredUserInfoKeys = Set(self.documentURLUserInfo.keys)
            userActivity.needsSave = true
        }
    }
}

// MARK: - NSUserActivityDelegate

extension DocumentViewController: NSUserActivityDelegate {

    func userActivityWillSave(_ userActivity: NSUserActivity) {
        print(#function)
        dump(userActivity)

        assert(userActivity.userInfo?.keys.contains(UIDocument.userActivityURLKey) == true)
        assert(userActivity.userInfo?.keys.contains("bookmark") == true)
    }
}
