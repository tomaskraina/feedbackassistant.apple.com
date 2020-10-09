# UIDocumentBrowserViewController Consumes All Keyboard Input After Switching Apps

When using UIDocumentBrowserViewController and presenting a document using a view controller with `modalPresentationStyle` set to `.overFullScreen`, the UIDocumentBrowserViewController consumes all whatever we type on a connected hardware keyboard (Apple Smart Keyboard Folio), effectivelly preventing the presented View Controller to reveive the input and key commands.

We could also use `.fullScreen` value for `modalPresentationStyle` but that result in the animated transition for opening and closing document being broken.

## Steps to reproduce

1. Run the attached project on an iPad with hardware keyboard connected
2. Create a new document using "+" button
3. Press CMD+Tab to another app
4. Press CMD+Tab back to the sample app
5. Press CMD+F

## Expected results
- Alert with title "Search" appears

## Actual results
- Keyboard accessory view appears at the bottom of the screen, a hidden textfield gets all the keyboard input. Moreover, CMD+A highlights invisible text
