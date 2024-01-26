//
//  ContentView.swift
//  SwiftUI-vs-PhotosPicker
//
//  Created by Tom Kraina on 19.01.2024.
//

import SwiftUI
import PhotosUI


struct ContentView: View {

    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var presentedImagePickerType: ImagePickerType? = nil
    @State private var isPresentingDedicatedPhotosPicker: Bool = false

    @State var embedInNavigationView: Bool = true
    @State var includeClosButtonInToolbar: Bool = true

    @State var photosPickerStyle: PhotosPickerStyle = .inline // we need to use the .inline slyle because it's embedded in ImagePickerView which we presetent as a sheet
    @State var photosPickerDisabledCapatibilities: PHPickerCapabilities = []  // this can remove the Cancel button, we don't want that
    @State var photosPickerAccessoryVisiblity: Visibility = .automatic  // we want to keep the sidebar and

    init() {
        var photosPickerDisabledCapatibilities: PHPickerCapabilities = []
        print(photosPickerDisabledCapatibilities.contains(.selectionActions))
        photosPickerDisabledCapatibilities.insert(.selectionActions)
    }

    var body: some View {
        HStack {
            Form {
                Section("Embedded PhotosPicker + .sheet()") {
                    Button("Present PhotosPicker", systemImage: "photo") {
                        self.presentedImagePickerType = .photos
                    }
                }

                Section {
                    Toggle("Embed in NavigationView", isOn: self.$embedInNavigationView)
                    Toggle("Include Close Button in Toolbar", isOn: self.$includeClosButtonInToolbar)
                }

                Picker(".photosPickerStyle()", selection: self.$photosPickerStyle) {
                    Text(".presentation")
                        .tag(PhotosPickerStyle.presentation)
                    Text(".inline")
                        .tag(PhotosPickerStyle.inline)
                    Text(".compact")
                        .tag(PhotosPickerStyle.compact)
                }

                Picker(".photosPickerAccessoryVisiblity()", selection: self.$photosPickerAccessoryVisiblity) {
                    Text(".automatic")
                        .tag(Visibility.automatic)
                    Text(".visible")
                        .tag(Visibility.visible)
                    Text(".hidden")
                        .tag(Visibility.hidden)
                }

                Section(".photosPickerDisabledCapatibilities()") {
                    Toggle(".collectionNavigation", isOn: self.toggleBinding(for: .collectionNavigation))
                    Toggle(".search", isOn: self.toggleBinding(for: .search))
                    Toggle(".selectionActions", isOn: self.toggleBinding(for: .selectionActions))
                    Toggle(".sensitivityAnalysisIntervention", isOn: self.toggleBinding(for: .sensitivityAnalysisIntervention))
                    Toggle(".stagingArea", isOn: self.toggleBinding(for: .stagingArea))
                }
            }

            Divider()

            Form {
                Section(".photosPicker(isPresented:)") {
                    Button("Present PhotosPicker", systemImage: "photo.badge.plus") {
                        self.isPresentingDedicatedPhotosPicker = true
                    }
                }
            }
        }
        .safeAreaPadding(20)
        .sheet(item: self.$presentedImagePickerType) { pickerType in
            ImagePickerView(
                pickerType: pickerType,
                selectedPhoto: self.$selectedPhoto,
                photosPickerStyle: self.photosPickerStyle,
                photosPickerDisabledCapatibilities: self.photosPickerDisabledCapatibilities,
                photosPickerAccessoryVisiblity: self.photosPickerAccessoryVisiblity,
                embedInNavigationView: self.embedInNavigationView
            )
                .frame(width: 900, height: 700.0)
        }

        // Using .photosPicker() view modifier seems the only way to make the default Cancel button dismis the picker...
        // But that comes with the drawback that we can't embed it in our ImagePickerView.
        .photosPicker(
            isPresented: self.$isPresentingDedicatedPhotosPicker,
            selection: self.$selectedPhoto,
            matching: .images,
            preferredItemEncoding: .current,
            photoLibrary: .shared()
        )
        .onChange(of: self.selectedPhoto) { _, newValue in
            if let newValue {
                print("selectedPhoto:")
                print(newValue)
            }
        }
    }

    private func toggleBinding(for capabilities: PHPickerCapabilities) -> Binding<Bool> {
        .init {
            self.photosPickerDisabledCapatibilities.contains(capabilities)
        } set: { include in
            if include {
                self.photosPickerDisabledCapatibilities.insert(capabilities)
            } else {
                self.photosPickerDisabledCapatibilities.remove(capabilities)
            }
        }
    }
}

#Preview {
    ContentView()
        .frame(idealHeight: 800)
}
