//
//  ImagePickerView.swift
//  SwiftUI-vs-PhotosPicker
//
//  Created by Tom Kraina on 23.01.2024.
//

import Foundation
import PhotosUI
import SwiftUI


// MARK: - ImagePickerType

enum ImagePickerType: Hashable, Identifiable {
    case photos

    var id: ImagePickerType { self }
}

// MARK: - ImagePickerView

struct ImagePickerView: View {

    @Environment(\.dismiss) private var dismiss: DismissAction

    let pickerType: ImagePickerType
    @Binding var selectedPhoto: PhotosPickerItem?

    var photosPickerStyle: PhotosPickerStyle = .inline // we need to use the .inline slyle because it's embedded in ImagePickerView which we presetent as a sheet
    var photosPickerDisabledCapatibilities: PHPickerCapabilities = []  // this can remove the Cancel button, we don't want that
    var photosPickerAccessoryVisiblity: Visibility = .automatic  // we want to keep the sidebar and other accesories

    var embedInNavigationView: Bool = false
    var includeCloseButtonInToolbar: Bool = true

    var body: some View {
        Group {
            switch self.pickerType {
            case .photos:
                if self.embedInNavigationView {
                    // This results in a ugly-looking navigation bar that takes excessive space and a clipped top of the sidebar
                    NavigationView {
                        self.photosPicker
                            .toolbar {
                                self.closeButtonToolbarItem
                            }
                    }
                } else {
                    self.photosPicker
                        .toolbar {
                            self.closeButtonToolbarItem
                        }
                }
            }
        }
    }
}

// MARK: - Private

private extension ImagePickerView {

    @ToolbarContentBuilder
    var closeButtonToolbarItem: some ToolbarContent {
        if self.includeCloseButtonInToolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    self.dismiss()
                }
            }
        }
    }

    @ViewBuilder
    var photosPicker: some View {
        PhotosPicker(
            "Select Photo",
            selection: self.$selectedPhoto,
            matching: .images,
            preferredItemEncoding: .current,
            photoLibrary: .shared()
        )
        .photosPickerStyle(self.photosPickerStyle)
        .photosPickerDisabledCapabilities(self.photosPickerDisabledCapatibilities)
        .photosPickerAccessoryVisibility(self.photosPickerAccessoryVisiblity)
    }
}
