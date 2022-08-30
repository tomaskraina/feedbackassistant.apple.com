//
//  ViewController.swift
//  UIFindInteraction-StageManager-UIKit
//
//  Created by Tom Kraina on 29.08.2022.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!

    // MARK: - UIViewController

    override func viewDidLoad() {
        // See Main.storyboard for the UI
        super.viewDidLoad()

        self.textView.isFindInteractionEnabled = true
        let text = """
        # Steps to reproduce
        1. Run this project on iPad Simulator
        2. Enable Stage Manager in Simulator by executing this command in Terminal:
            ```
            xcrun simctl spawn booted defaults write -g SBChamoisWindowingEnabled -bool true
            ```
        3. Tap "Toggle Search" in the app in the navigation ba as many times as you want, it will flick very briefly
        4. Now, disable Stage Manager in Simulator by executing this command in Terminal:
            ```
            xcrun simctl spawn booted defaults write -g SBChamoisWindowingEnabled -bool false
            ```
        5. And tap "Toggle Search" again, now the find panel will work as intended.
        """

        self.textView.text = text.appending("\n\n" + self.textView.text)
    }

    // MARK: - IBAction

    @IBAction func startEditing(_ sender: Any) {
        self.textView.becomeFirstResponder()
    }

    @IBAction func endEditing(_ sender: Any) {
        self.textView.resignFirstResponder()
    }

    @IBAction func toggleSearch(_ sender: Any) {
        if self.textView.findInteraction?.isFindNavigatorVisible == true {
            self.textView.findInteraction?.dismissFindNavigator()
        } else {
            // This presents the find panel but if the textView wasn't already first responder, the panel only flicks and disappears while `isFindNavigatorVisible` returns `true`
            self.textView.findInteraction?.presentFindNavigator(showingReplace: false)
        }
    }
}

