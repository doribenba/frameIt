//
//  ContentView.swift
//  borderControl
//
//  Created by Dorian Benbassat on 2026/4/26.
//
// TODO: VIDEO MODE / CRASHLYTICS / APP ICONS / CUSTOM MODE

import SwiftUI
import PhotosUI
import StoreKit
import UIKit
import AVFoundation

struct RenderedExportImage: Identifiable {
    let id = UUID()
    let image: UIImage
    let isFinal: Bool
}

struct ContentView: View {
    @Environment(\.requestReview) var requestReview
    @AppStorage("minimalMode") private var minimalMode: Bool = false
    @State private var selectedUIImage: UIImage?
    @State private var pendingReviewPrompt = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedBatchItems: [PhotosPickerItem] = []
    @State private var batchImages: [UIImage] = []
    @State private var selectedVideoURL: URL? // New: for video selection
    @State private var isVideoMode: Bool = false // New: track video mode
    @State private var selectedColor: Color = .white
    @AppStorage("borderSize") private var borderSize: Double = 85
    @State var renderedImage: UIImage?
    @State private var renderedImageQueue: [UIImage] = []
    @State private var renderedImageGeneration = 0
    @State private var batchRenderedImages: [RenderedExportImage] = []
    @State private var isBatchExportAnimationActive = false
    @State private var isBatchExportBackdropVisible = false
    @State private var isBatchExportComplete = false
    @State private var opacity = 0.0

    var body: some View {
        ZStack{
            //selectedColor.inverted()
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .ignoresSafeArea()
//                .animation(.easeInOut(duration: 0.3), value: selectedColor)
            (selectedColor.isdark ? Color.white : Color.black)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.3), value: selectedColor)
            ZStack {
                if renderedImage != nil || isBatchExportAnimationActive {
                    SplashView(
                        selectedColor: selectedColor,
                        selectedItem: $selectedItem,
                        selectedBatchItems: $selectedBatchItems,
                        renderedImage: $renderedImage,
                        batchRenderedImages: $batchRenderedImages,
                        isBatchExportAnimationActive: isBatchExportAnimationActive,
                        renderedImageGeneration: renderedImageGeneration,
                        onRenderedImageDismissed: showNextRenderedImage,
                        onBatchRenderedImageDismissed: removeBatchRenderedImage
                    )
                    .transition(.opacity)
                } else if isBatchExportBackdropVisible {
                    Color.clear
                        .transition(.opacity)
                } else if let image = selectedUIImage {
                    EditorView(
                        selectedItem: $selectedItem,
                        selectedBatchItems: $selectedBatchItems,
                        selectedUIImage: $selectedUIImage,
                        batchImages: $batchImages,
                        selectedColor: $selectedColor,
                        borderSize: borderSizeBinding,
                        image: image,
                        onRenderedImage: showRenderedImage,
                        onBatchExportComplete: finishBatchExportAnimation
                    )
                    .transition(.opacity)
//                } else if let videoURL = selectedVideoURL, isVideoMode {
//                    // New: Video editor view
//                    VideoEditorView(
//                        selectedItem: $selectedItem,
//                        selectedVideoURL: $selectedVideoURL,
//                        isVideoMode: $isVideoMode,
//                        selectedColor: $selectedColor,
//                        videoURL: videoURL,
//                        onRenderedImage: showRenderedImage, // Reuse for compatibility
//                        onBatchExportComplete: finishBatchExportAnimation
//                    )
//                    .transition(.opacity)
                } else if !batchImages.isEmpty {
                    EditorView(
                        selectedItem: $selectedItem,
                        selectedBatchItems: $selectedBatchItems,
                        selectedUIImage: $selectedUIImage,
                        batchImages: $batchImages,
                        selectedColor: $selectedColor,
                        borderSize: borderSizeBinding,
                        image: batchImages[0],
                        isBatchMode: true,
                        onRenderedImage: showRenderedImage,
                        onBatchExportComplete: finishBatchExportAnimation
                    )
                    .transition(.opacity)
                } else {
                    SplashView(
                        selectedColor: selectedColor,
                        selectedItem: $selectedItem,
                        selectedBatchItems: $selectedBatchItems,
                        renderedImage: $renderedImage,
                        batchRenderedImages: $batchRenderedImages,
                        isBatchExportAnimationActive: isBatchExportAnimationActive,
                        renderedImageGeneration: renderedImageGeneration,
                        onRenderedImageDismissed: showNextRenderedImage,
                        onBatchRenderedImageDismissed: removeBatchRenderedImage
                    )
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.26), value: renderedImage != nil)
            .animation(.easeInOut(duration: 0.26), value: isBatchExportAnimationActive)
            .animation(.easeInOut(duration: 0.26), value: isBatchExportBackdropVisible)
            .animation(.easeInOut(duration: 0.26), value: selectedUIImage != nil)
            .animation(.easeInOut(duration: 0.26), value: batchImages.isEmpty)
            .animation(.easeInOut(duration: 0.26), value: selectedVideoURL != nil)
            .animation(.easeInOut(duration: 0.26), value: isVideoMode)
        }
        .statusBarHidden(minimalMode)
        .animation(.easeInOut(duration: 0.2), value: minimalMode)
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeIn(duration: 0.6)) {
                opacity = 1
            }
        }
        .onChange(of: selectedItem) { oldValue, newValue in
            Task {
                guard let newValue else { return }

                // Check what type of media was selected
                let isImage = try? await newValue.loadTransferable(type: Data.self) != nil
                let isVideo = try? await newValue.loadTransferable(type: URL.self) != nil

                if isImage == true {
                    // Handle image selection
                    // Reset video mode when selecting image
                    isVideoMode = false
                    selectedVideoURL = nil

                    if let data = try? await newValue.loadTransferable(type: Data.self) {
                        if let image = UIImage(data: data) {
                            withAnimation {
                                selectedBatchItems = []
                                batchImages = []
                                selectedUIImage = image
                            }
                        }
                    }
                } else if isVideo == true {
                    // Handle video selection
                    // Reset image mode when selecting video
                    isVideoMode = true
                    selectedUIImage = nil
                    selectedBatchItems = []
                    batchImages = []

                    if let url = try? await newValue.loadTransferable(type: URL.self) {
                        // Validate video size (< 1GB)
                        do {
                            let fileSize = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
                            let sizeInGB = Double(fileSize) / (1024 * 1024 * 1024)

                            if sizeInGB > 1.0 {
                                // Show error - video too large
                                // For now, we'll just reset and let user try again
                                // In a full implementation, we'd show an alert
                                selectedVideoURL = nil
                                isVideoMode = false
                            } else {
                                selectedVideoURL = url
                            }
                        } catch {
                            selectedVideoURL = nil
                            isVideoMode = false
                        }
                    }
                }
            }
        }
        .onChange(of: selectedBatchItems) { oldValue, newValue in
            Task {
                let pickedItems = Array(newValue.prefix(10))
                guard !pickedItems.isEmpty else {
                    await MainActor.run {
                        withAnimation {
                            batchImages = []
                        }
                    }
                    return
                }

                var loadedImages: [UIImage] = []

                for item in pickedItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        loadedImages.append(image)
                    }
                }

                await MainActor.run {
                    withAnimation {
                        selectedItem = nil
                        if loadedImages.count == 1 {
                            selectedBatchItems = []
                            selectedUIImage = loadedImages[0]
                            batchImages = []
                        } else {
                            selectedUIImage = nil
                            batchImages = loadedImages
                        }
                    }
                }
            }
        }
    }

    private func showRenderedImage(_ image: UIImage, isBatch: Bool = false, showsConfetti: Bool = false) {
        if isBatch {
            withAnimation(.easeInOut(duration: 0.26)) {
                isBatchExportComplete = false
                isBatchExportBackdropVisible = true
                batchRenderedImages.append(RenderedExportImage(image: image, isFinal: showsConfetti))
            }
            startBatchExportAnimationAfterEditorFade()
            return
        }

        if showsConfetti {
            pendingReviewPrompt = true
        }

        withAnimation(.easeInOut(duration: 0.26)) {
            if renderedImage == nil {
                renderedImage = image
                renderedImageGeneration += 1
            } else {
                renderedImageQueue.append(image)
            }
        }
    }

    // New: Handle video export completion
    private func showRenderedVideo(_ videoURL: URL, isBatch: Bool = false) {
        if isBatch {
            withAnimation(.easeInOut(duration: 0.26)) {
                isBatchExportComplete = false
                isBatchExportBackdropVisible = true
                batchRenderedImages.append(RenderedExportImage(image: videoURL.thumbnailImage(), isFinal: true))
            }
            startBatchExportAnimationAfterEditorFade()
            return
        }

        withAnimation(.easeInOut(duration: 0.26)) {
            if renderedImage == nil {
                renderedImage = videoURL.thumbnailImage()
                renderedImageGeneration += 1
            } else {
                renderedImageQueue.append(videoURL.thumbnailImage())
            }
        }
    }

    private func showNextRenderedImage() {
        guard renderedImage == nil, !renderedImageQueue.isEmpty else {
            if renderedImage == nil && pendingReviewPrompt {
                triggerReviewIfNeeded()
            }
            return
        }

        withAnimation(.easeInOut(duration: 0.26)) {
            renderedImage = renderedImageQueue.removeFirst()
            renderedImageGeneration += 1
        }
    }

    private func finishBatchExportAnimation() {
        isBatchExportComplete = true
        finishBatchExportAnimationIfReady()
    }

    private func removeBatchRenderedImage(_ id: RenderedExportImage.ID) {
        batchRenderedImages.removeAll { $0.id == id }
        finishBatchExportAnimationIfReady()
    }

    private func finishBatchExportAnimationIfReady() {
        guard isBatchExportComplete, batchRenderedImages.isEmpty else { return }

        withAnimation(.easeInOut(duration: 0.26)) {
            isBatchExportAnimationActive = false
            isBatchExportBackdropVisible = false
            isBatchExportComplete = false
        }

        triggerReviewIfNeeded()
    }

    private func startBatchExportAnimationAfterEditorFade() {
        guard !isBatchExportAnimationActive else { return }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 280_000_000)

            guard isBatchExportBackdropVisible, !batchRenderedImages.isEmpty else { return }

            withAnimation(.easeInOut(duration: 0.26)) {
                isBatchExportAnimationActive = true
            }
        }
    }

    private func triggerReviewIfNeeded() {
        guard pendingReviewPrompt else { return }

        let currentCount = UserDefaults.standard.integer(forKey: "successful_exports_count")
        let hasPrompted = UserDefaults.standard.bool(forKey: "has_prompted_for_review")

        if currentCount >= 5 && !hasPrompted {
            requestReview()
            UserDefaults.standard.set(true, forKey: "has_prompted_for_review")
        }

        pendingReviewPrompt = false
    }

    private var borderSizeBinding: Binding<Float> {
        Binding(
            get: { Float(borderSize) },
            set: { borderSize = Double($0) }
        )
    }
}

// Extension to get thumbnail from URL
extension URL {
    func thumbnailImage() -> UIImage {
        let asset = AVAsset(url: self)
        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time : CMTime = CMTimeMake(value: 1, timescale: 2)
        let img = try? assetImgGenerate.copyCGImage(at: time, actualTime: nil)
        if let cgImage = img {
            return UIImage(cgImage: cgImage)
        } else {
            return UIImage() // Return empty image if thumbnail generation fails
        }
    }
}

#Preview {
    ContentView()
}
