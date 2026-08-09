//
//  headerView.swift
//  borderControl
//
//  Created by Dorian Benbassat on 2026/4/30.
//

import SwiftUI
import PhotosUI
import Photos
import LinkPresentation

struct AspectRatioOption: Identifiable, Equatable {
    let id: String
    let title: String
    let symbolName: String
    let ratio: CGFloat?
    
    var isAsymmetrical: Bool {
        id == "asymmetrical"
    }
    
    var isDouble: Bool {
        id == "double"
    }

    var isCustom: Bool {
        id == "custom"
    }
    
    static let original = AspectRatioOption(
        id: "original",
        title: "EVEN",
        symbolName: "photo",
        ratio: nil
    )

    static func custom(width: Int, height: Int) -> AspectRatioOption {
        AspectRatioOption(
            id: "custom",
            title: "\(width):\(height)",
            symbolName: "slider.horizontal.below.rectangle",
            ratio: CGFloat(width) / CGFloat(height)
        )
    }
    
    static let all: [AspectRatioOption] = [
        .original,
        AspectRatioOption(id: "instagram", title: "INSTAGRAM", symbolName: "rectangle.portrait", ratio: 4 / 5),
        AspectRatioOption(id: "square", title: "SQUARE", symbolName: "square", ratio: 1),
        AspectRatioOption(id: "asymmetrical", title: "ASYMMETRICAL", symbolName: "skew", ratio: nil),
        AspectRatioOption(id: "double", title: "DOUBLE", symbolName: "inset.filled.square.dashed", ratio: nil),
        AspectRatioOption(id: "story", title: "STORY", symbolName: "rectangle.portrait", ratio: 9 / 16),
        AspectRatioOption(id: "a4", title: "A4", symbolName: "doc", ratio: 210 / 297)
    ]
    
    static let standard: [AspectRatioOption] = [
        AspectRatioOption(id: "four-three", title: "4:3", symbolName: "rectangle", ratio: 4 / 3),
        AspectRatioOption(id: "three-four", title: "3:4", symbolName: "rectangle.portrait", ratio: 3 / 4),
        AspectRatioOption(id: "three-two", title: "3:2", symbolName: "rectangle", ratio: 3 / 2),
        AspectRatioOption(id: "two-three", title: "2:3", symbolName: "rectangle.portrait", ratio: 2 / 3),
        AspectRatioOption(id: "four-five", title: "5:4", symbolName: "rectangle.portrait", ratio: 5 / 4),
        AspectRatioOption(id: "sixteen-nine", title: "16:9", symbolName: "rectangle", ratio: 16 / 9),
//        AspectRatioOption(id: "custom", title: "CUSTOM", symbolName: "slider.horizontal.below.rectangle", ratio: 4 / 3)
    ]
}

enum DoubleBorderLayer {
    case outer
    case inner
}

struct HeaderView: View {
    @Binding var selectedItem: PhotosPickerItem?
    @Binding var selectedBatchItems: [PhotosPickerItem]
    @Binding var selectedUIImage: UIImage?
    @Binding var batchImages: [UIImage]
    @Binding var selectedAspectRatio: AspectRatioOption
    @Binding var isCustomAspectRatioOverlayVisible: Bool
    @Binding var customAspectRatioWidth: Int
    @Binding var customAspectRatioHeight: Int

    @Environment(\.requestReview) var requestReview

    @State private var shareItem: ShareItem?
    
    let selectedColor: Color
    let borderSize: Float
    let doubleOuterColor: Color
    let doubleOuterBorderSize: Float
    let doubleInnerColor: Color
    let doubleInnerBorderSize: Float
    let overlayText: String
    let image: UIImage
    let isBatchMode: Bool
    let onRenderedImage: (UIImage, Bool, Bool) -> Void
    let onBatchExportComplete: () -> Void
    
    // MARK: - Removable Export Completion State
    @State private var exportErrorMessage: String? = nil
    @State private var isExporting: Bool = false
    @State private var showDiscardAlert = false
    
    var body: some View {
        VStack{
            HStack{
                Button {
                    showDiscardAlert = true
                } label: {
                    Image(systemName: "x.circle")
                        .tint(selectedColor)
                        .font(.system(size: 16, weight: .bold))
                }
                
                Spacer()
                
                if !isBatchMode {
                    Button {
                        withAnimation{
                            shareImage()
                        }
                    } label: {
                        Text("SHARE")
                            .fontWeight(.bold)
                            .monospaced()
                            .tint(selectedColor)
                    }
                    .disabled(isExporting)
                    
                RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                    .fill(.secondary.opacity(0.55))
                    .frame(width: 2, height: 18)
                    .padding(.horizontal, 3)
                }
                
                Button {
                    if isBatchMode {
                        withAnimation{
                            exportAllImages()
                        }
                    } else {
                        withAnimation{
                            exportImage()
                        }
                    }
                } label: {
                    Text(isBatchMode ? "DONE/EXPORT ALL" : "DONE/EXPORT")
                        .fontWeight(.bold)
                        .monospaced()
                        .tint(selectedColor)
                }
                .disabled(isExporting)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    aspectRatioButtons(AspectRatioOption.all)
                    
                    RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                        .fill(.secondary.opacity(0.55))
                        .frame(width: 2, height: 18)
                        .padding(.horizontal, 3)
                    
                    aspectRatioButtons(AspectRatioOption.standard)
                }
                .padding(.horizontal, 24)
            }
            .mask {
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .black, location: 0.08),
                        .init(color: .black, location: 0.92),
                        .init(color: .clear, location: 1)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
            .padding(.horizontal, -24)
            .padding(.top, 6)
        }
        .alert("EXPORT FAILED", isPresented: Binding(
            get: { exportErrorMessage != nil },
            set: { if !$0 { exportErrorMessage = nil } }
        )) {
            Button("ALRIGHT", role: .cancel) {}
        } message: {
            //Text(exportErrorMessage ?? "The image could not be saved.")
            Text("The application doesn't have your permission to save images. Go fix it.")
        }
        .alert("DISCARD EDITS?", isPresented: $showDiscardAlert) {
            Button("DISCARD", role: .destructive) {
                withAnimation {
                    closeEditor()
                }
                if isBatchMode {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        batchImages = []
                    }
                }
            }
            Button("CANCEL", role: .cancel) {}
        } message: {
            Text("Your current edits won't be saved.")
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(activityItems: [ImageActivityItemSource(image: item.image)])
        }
    }
    
    @ViewBuilder
    private func aspectRatioButtons(_ options: [AspectRatioOption]) -> some View {
        ForEach(options) { option in
            Button {
                withAnimation(.easeInOut(duration: 0.18)) {
                    if option.isCustom {
                        selectedAspectRatio = AspectRatioOption.custom(
                            width: customAspectRatioWidth,
                            height: customAspectRatioHeight
                        )
                        isCustomAspectRatioOverlayVisible.toggle()
                    } else {
                        selectedAspectRatio = option
                        isCustomAspectRatioOverlayVisible = false
                    }
                }
            } label: {
                let isSelected = selectedAspectRatio.id == option.id
                let title = option.isCustom && isSelected ? selectedAspectRatio.title : option.title

                Label(title, systemImage: option.symbolName)
                    .font(.caption)
                    .fontWeight(.bold)
                    .monospaced()
                    .frame(height: 18)
                    .foregroundStyle(isSelected ? selectedColor : .secondary)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(.secondary.opacity(isSelected ? 0.20 : 0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Removable Export Completion Handling
    private func closeEditor() {
        if isBatchMode {
            selectedBatchItems = []
        } else {
            selectedItem = nil
            selectedUIImage = nil
        }
    }
    
    private func shareImage() {
        exportErrorMessage = nil
        
        let borderedImage = createBorder(
            image: image,
            width: calculateBorder(border: borderSize),
            color: selectedColor,
            aspectRatio: selectedAspectRatio.ratio,
            isAsymmetrical: selectedAspectRatio.isAsymmetrical,
            isDouble: selectedAspectRatio.isDouble,
            doubleOuterWidth: doubleOuterBorderSize,
            doubleOuterColor: doubleOuterColor,
            doubleInnerWidth: doubleInnerBorderSize,
            doubleInnerColor: doubleInnerColor,
            overlayText: overlayText
        )
        
        let share = borderedImage
        shareItem = ShareItem(image: share)
    }
    
    private func exportImage() {
        isExporting = true
        exportErrorMessage = nil
        
        let borderedImage = createBorder(
            image: image,
            width: calculateBorder(border: borderSize),
            color: selectedColor,
            aspectRatio: selectedAspectRatio.ratio,
            isAsymmetrical: selectedAspectRatio.isAsymmetrical,
            isDouble: selectedAspectRatio.isDouble,
            doubleOuterWidth: doubleOuterBorderSize,
            doubleOuterColor: doubleOuterColor,
            doubleInnerWidth: doubleInnerBorderSize,
            doubleInnerColor: doubleInnerColor,
            overlayText: overlayText
        )
        
        Task {
            do {
                try await saveToPhotoLibrary(borderedImage)
                incrementExportCount()

                await MainActor.run {
                    isExporting = false
                    onRenderedImage(borderedImage, false, true)

                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedItem = nil
                        selectedUIImage = nil
                    }
                }
            } catch {
                await MainActor.run {
                    isExporting = false
                    exportErrorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func exportAllImages() {
        guard !batchImages.isEmpty else { return }
        
        isExporting = true
        exportErrorMessage = nil
        let imagesToExport = batchImages
        
        Task {
            do {
                for imageIndex in imagesToExport.indices {
                    let image = imagesToExport[imageIndex]
                    let isLastImage = imageIndex == imagesToExport.index(before: imagesToExport.endIndex)
                    let borderedImage = createBorder(
                        image: image,
                        width: calculateBorder(border: borderSize),
                        color: selectedColor,
                        aspectRatio: selectedAspectRatio.ratio,
                        isAsymmetrical: selectedAspectRatio.isAsymmetrical,
                        isDouble: selectedAspectRatio.isDouble,
                        doubleOuterWidth: doubleOuterBorderSize,
                        doubleOuterColor: doubleOuterColor,
                        doubleInnerWidth: doubleInnerBorderSize,
                        doubleInnerColor: doubleInnerColor,
                        overlayText: overlayText
                    )
                    
                    try await saveToPhotoLibrary(borderedImage)
//                    incrementExportCount()

                    await MainActor.run {
                        onRenderedImage(borderedImage, true, isLastImage)
                    }
                    
                    if !isLastImage {
                        try? await Task.sleep(nanoseconds: 620_000_000)
                    }
                }
                
                await MainActor.run {
                    isExporting = false
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedBatchItems = []
                        batchImages = []
                    }
                    onBatchExportComplete()
                }
            } catch {
                await MainActor.run {
                    isExporting = false
                    exportErrorMessage = error.localizedDescription
                    onBatchExportComplete()
                }
            }
        }
    }
    
    private func saveToPhotoLibrary(_ image: UIImage) async throws {
        try await withCheckedThrowingContinuation { continuation in
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } completionHandler: { success, error in
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: error ?? ExportError.photoLibrarySaveFailed)
                }
            }
        }
    }

    private func incrementExportCount() {
        let currentCount = UserDefaults.standard.integer(forKey: "successful_exports_count")
        UserDefaults.standard.set(currentCount + 1, forKey: "successful_exports_count")
    }
}

struct CustomAspectRatioOverlay: View {
    @Binding var width: Int
    @Binding var height: Int
    @Binding var dragOffset: CGSize
    @GestureState private var dragTranslation = CGSize.zero

    let selectedColor: Color
    let onDismiss: () -> Void

    private let numberRange = Array(1...30)

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("CUSTOM")
                    .font(.caption)
                    .fontWeight(.bold)
                    .monospaced()
                    .foregroundStyle(selectedColor)

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .contentShape(Rectangle())
            .gesture(dragGesture)

            HStack(spacing: 14) {
                numberPicker(selection: $width)

                RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                    .fill(.secondary.opacity(0.55))
                    .frame(width: 2, height: 88)

                numberPicker(selection: $height)
            }
            .frame(height: 118)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.secondary.opacity(0.18), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.14), radius: 18, x: 0, y: 10)
        .frame(maxWidth: 260)
        .offset(
            x: dragOffset.width + dragTranslation.width,
            y: dragOffset.height + dragTranslation.height
        )
    }

    private func numberPicker(selection: Binding<Int>) -> some View {
        Picker("", selection: selection) {
            ForEach(numberRange, id: \.self) { number in
                Text("\(number)")
                    .font(.system(size: 28, weight: .black, design: .monospaced))
                    .tag(number)
            }
        }
        .pickerStyle(.wheel)
        .labelsHidden()
        .frame(width: 82, height: 118)
        .clipped()
    }

    private var dragGesture: some Gesture {
        DragGesture(coordinateSpace: .global)
            .updating($dragTranslation) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                dragOffset.width += value.translation.width
                dragOffset.height += value.translation.height
            }
    }
}

private enum ExportError: LocalizedError {
    case photoLibrarySaveFailed
    
    var errorDescription: String? {
        "The image could not be saved."
    }
}

private struct ShareItem: Identifiable {
    let id = UUID()
    let image: UIImage
}

private struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

private final class ImageActivityItemSource: NSObject, UIActivityItemSource {
    private let image: UIImage
    
    init(image: UIImage) {
        self.image = image
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        image
    }
    
    func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        image
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = "Share Image"
        metadata.imageProvider = NSItemProvider(object: image)
        metadata.iconProvider = NSItemProvider(object: image)
        return metadata
    }
}
