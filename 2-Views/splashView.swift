//
//  splash.swift
//  borderControl
//
//  Created by Dorian Benbassat on 2026/4/28.
//

import SwiftUI
import PhotosUI
import ConfettiSwiftUI
import UIKit

struct SplashView: View {
    let selectedColor: Color
    @Binding var selectedItem: PhotosPickerItem?
    @Binding var selectedBatchItems: [PhotosPickerItem]
    @Binding var renderedImage: UIImage?
    @Binding var batchRenderedImages: [RenderedExportImage]
    let isBatchExportAnimationActive: Bool
    let renderedImageGeneration: Int
    let onRenderedImageDismissed: () -> Void
    let onBatchRenderedImageDismissed: (RenderedExportImage.ID) -> Void
    @State private var confetti: Int = 0
    @State private var showSettings = false
    @State private var imageScale: CGFloat = 0.78
    @State private var imageOpacity: Double = 0
    @State private var imageRotation: Double = -4
    @State private var batchFinalCelebrationOpacity: Double = 0
    
    private var greyColor: Color {
        selectedColor.isdark ? Color.black : Color.white
    }
    
    var body: some View {
        if let render = renderedImage {
            VStack(alignment: .leading){
                HStack{
                    Spacer()
                    Text("SAVED!")
                        .monospaced()
                        .foregroundStyle(selectedColor)
                        .fontWeight(.bold)
                }
                Image(uiImage: render)
                    .resizable()
                    .scaledToFit()
                    .padding(.vertical, 13)
                    .scaleEffect(imageScale)
                    .rotationEffect(.degrees(imageRotation))
                Spacer().frame(height: 60)
            }
            .padding(40)
            .task(id: renderedImageGeneration) {
                imageScale = 0.78
                imageOpacity = 0
                imageRotation = -4
                
                try? await Task.sleep(nanoseconds: 300_000_000)
                triggerExportHaptic(style: .light)
                withAnimation(.spring(response: 0.42, dampingFraction: 0.48, blendDuration: 0.05)) {
                    imageScale = 1
                    confetti += 1
                    imageOpacity = 1
                    imageRotation = 0
                }
                
                try? await Task.sleep(nanoseconds: 3_150_000_000)
                
                withAnimation(.spring(response: 0.34, dampingFraction: 0.55, blendDuration: 0.05)) {
                    imageScale = 0.78
                    imageOpacity = 0
                    imageRotation = 4
                }
                
                try? await Task.sleep(nanoseconds: 450_000_000)
                withAnimation(.easeInOut(duration: 0.12)) {
                    renderedImage = nil
                }
                onRenderedImageDismissed()
            }
            .confettiCannon(trigger: $confetti, num: 69, rainHeight: 300, radius: 400.0, hapticFeedback: true)
            .opacity(imageOpacity)
            
        } else if isBatchExportAnimationActive {
            VStack(alignment: .leading){
                HStack {
                    Spacer()
                    
                    if batchRenderedImages.last?.isFinal == true {
                        Text("SAVED!")
                            .monospaced()
                            .foregroundStyle(selectedColor)
                            .fontWeight(.bold)
                            .opacity(batchFinalCelebrationOpacity)
                    }
                }
                
                ZStack {
                    ForEach(batchRenderedImages) { render in
                        BatchRenderedImageView(render: render) {
                            guard render.isFinal else { return }
                            withAnimation(.easeInOut(duration: 0.22)) {
                                batchFinalCelebrationOpacity = 1
                            }
                            confetti += 1
                        } onFadeOutStarted: {
                            guard render.isFinal else { return }
                            
                            withAnimation(.spring(response: 0.34, dampingFraction: 0.55, blendDuration: 0.05)) {
                                batchFinalCelebrationOpacity = 0
                            }
                        } onDismissed: {
                            onBatchRenderedImageDismissed(render.id)
                        }
                    }
                }
                .padding(.vertical, 13)
                
                Spacer().frame(height: 60)
            }
            .padding(40)
            .overlay {
                Color.clear
                    .confettiCannon(trigger: $confetti, num: 69, rainHeight: 300, radius: 400.0, hapticFeedback: true)
                    .opacity(batchFinalCelebrationOpacity)
                    .allowsHitTesting(false)
            }
            .onAppear {
                guard batchRenderedImages.last?.isFinal == true else { return }
                batchFinalCelebrationOpacity = 0
            }
            .onChange(of: batchRenderedImages.last?.id) { oldValue, newValue in
                guard newValue != oldValue, batchRenderedImages.last?.isFinal == true else { return }
                batchFinalCelebrationOpacity = 0
            }
            
        } else {
            ZStack{
                //selectedColor.inverted()
                (selectedColor.isdark ? Color.white : Color.black)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.3), value: selectedColor)
                
                VStack(alignment: .trailing) {
                    
                    Spacer()
                    Spacer()
                    
                    HStack{
                        Spacer()
                        PhotosPicker(selection: $selectedBatchItems, maxSelectionCount: 10, matching: .images) {
                            Label("BATCH", systemImage: "photo.on.rectangle.angled")
                                .fontWeight(.bold)
                                .tint(greyColor)
                        }
                    }
                    .padding(.bottom, 70)
                    
                    Spacer()
                    
                    HStack{
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Label("<- FRAME IT", systemImage: "photo")
                                .fontWeight(.bold)
                                .tint(greyColor)
                        }
                        Spacer()
                    }
                    
                    HStack{
                        Spacer()
                        Button {
                            showSettings = true
                        } label: {
                            Text("SETTINGS")
                                .fontWeight(.bold)
                                .tint(greyColor)
                            Image(systemName: "gear")
                                .tint(greyColor)
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                    .padding(.top, 14)
                
                    Spacer()
                    HStack{
                        Image(systemName: "chevron.left.forwardslash.chevron.right")
                            .tint(greyColor)
                            .font(.system(size: 16, weight: .bold))
                            .opacity(0.5)
                        Text("DORIAN B. 2026")
                            .fontWeight(.bold)
                            .tint(greyColor)
                            .opacity(0.5)
                        Spacer()
                    }
                    Spacer()
                    
//                    HStack{
//                        PhotosPicker(selection: $selectedItem, matching: .images) {
//                            Label("<- FRAME IT", systemImage: "photo")
//                                .fontWeight(.bold)
//                                .tint(greyColor)
//                        }
//                        
//                        RoundedRectangle(cornerRadius: 1.5, style: .continuous)
//                            .fill(.secondary.opacity(1))
//                            .frame(width: 2, height: 18)
//                            .padding(.horizontal, 3)
//                        
//                        PhotosPicker(selection: $selectedBatchItems, maxSelectionCount: 10, matching: .images) {
//                            Image(systemName: "photo.on.rectangle.angled")
//                                .tint(greyColor)
//                                .font(.system(size: 16, weight: .bold))
//                        }
//                        
//                        RoundedRectangle(cornerRadius: 1.5, style: .continuous)
//                            .fill(.secondary.opacity(1))
//                            .frame(width: 2, height: 18)
//                            .padding(.horizontal, 3)
//                        
//                        Button {
//                            showSettings = true
//                        } label: {
//                            Image(systemName: "gear")
//                                .tint(greyColor)
//                                .font(.system(size: 16, weight: .bold))
//                        }
//                    }
//                    .tint(.black)
//                    .monospaced()
//                    .preferredColorScheme(selectedColor.isdark ? .light : .dark)
                    
                }
                .padding(.horizontal, 80)
                .tint(.black)
                .monospaced()
                .preferredColorScheme(selectedColor.isdark ? .light : .dark)
                .ignoresSafeArea()

            }
            .sheet(isPresented: $showSettings) {
                NewAboutView(selectedColor: selectedColor)
                    .presentationDragIndicator(.visible)
            }
            /*.animation(.easeInOut(duration: 0.25), value: showSettings)*/
        }
    }
    
    private func triggerExportHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

private struct BatchRenderedImageView: View {
    let render: RenderedExportImage
    let onPopStarted: () -> Void
    let onFadeOutStarted: () -> Void
    let onDismissed: () -> Void
    
    @State private var imageScale: CGFloat = 0.82
    @State private var imageOpacity: Double = 0
    @State private var imageRotation: Double = -4
    
    var body: some View {
        Image(uiImage: render.image)
            .resizable()
            .scaledToFit()
            .scaleEffect(imageScale)
            .rotationEffect(.degrees(imageRotation))
            .opacity(imageOpacity)
            .task {
                if render.isFinal {
                    try? await Task.sleep(nanoseconds: 180_000_000)
                }
                
                onPopStarted()
                triggerExportHaptic(style: render.isFinal ? .medium : .light)
                
                withAnimation(.spring(
                    response: render.isFinal ? 0.42 : 0.28,
                    dampingFraction: render.isFinal ? 0.48 : 0.58,
                    blendDuration: 0.04
                )) {
                    imageScale = 1
                    imageOpacity = 1
                    imageRotation = 0
                }
                
                let holdDuration: UInt64 = render.isFinal ? 2_600_000_000 : 950_000_000
                try? await Task.sleep(nanoseconds: holdDuration)
                
                if render.isFinal {
                    onFadeOutStarted()
                }
                
                if render.isFinal {
                    withAnimation(.spring(response: 0.34, dampingFraction: 0.55, blendDuration: 0.05)) {
                        imageScale = 0.78
                        imageOpacity = 0
                        imageRotation = 4
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        imageScale = 0.9
                        imageOpacity = 0
                        imageRotation = 4
                    }
                }
                
                let fadeDuration: UInt64 = render.isFinal ? 450_000_000 : 220_000_000
                try? await Task.sleep(nanoseconds: fadeDuration)
                onDismissed()
            }
    }
    
    private func triggerExportHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}
