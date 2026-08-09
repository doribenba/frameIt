//
//  newAboutView.swift
//  borderControl
//
//  Created by Dorian Benbassat on 2026/7/14.
//

import SwiftUI

struct NewAboutView: View {

//    @Binding var showSettings: Bool
    @Environment(\.dismiss) private var dismiss
    @AppStorage("minimalMode") private var minimalMode: Bool = true
    @State private var privacyWordIndex: Int = 0
    private let privacyWords = ["TRANSMIT", "COLLECT", "STORE"]
    
    var selectedColor: Color = .white
    
    private var greyColor: Color {
        selectedColor.isdark ? Color.black : Color.white
    }
    
    private var orangeColor: Color {
        selectedColor.isdark ? .black : .newOrange
    }
    

    var body: some View {
        greyColor.inverted()
            .ignoresSafeArea()
            .overlay {
                VStack(alignment: .leading, spacing: 0) {

                    // ── x button ──────────────────────────────────────────
//                    Button { dismiss() } label: {
//                        Image(systemName: "x.circle")
//                            .font(.system(size: 16, weight: .bold))
//                            .foregroundStyle(selectedColor)
//                    }
//                    .padding(.bottom, 7)

                    // ── Block ─────────────────────────────────────────────
                    VStack(alignment: .leading, spacing: 7) {

                        // ASYMMETRICAL            V1.0
                        row {
                            
                            Text("THIS")
                            Spacer()
                            Text("APP")
                            Spacer()
                            Text("DOES")
                            Spacer()
                            Text("NOT")
                        }                     .foregroundStyle(greyColor.opacity(0.5))

                        
                        row{}
                        row{}
                        
                        RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                            .fill(.secondary.opacity(1))
                            .frame(width: 250, height: 2)
        
                        row{}
                        row{}
                        
                        row {
                            Text("ASYMMETRICAL")
                            Spacer()
                            Text("V1.0")
                        }.foregroundStyle(orangeColor)

                        // ADDING COLORFULL ASYMMETRICAL TO
                        row {
                            Text("ADDS")
                            Spacer()
                            Text("COLORFULL")
                            Spacer()
                            Text("BORDERS")
                            Spacer()
                            Text("TO")
                        }.foregroundStyle(orangeColor)

                        // YOUR                   IMAGES
                        row {
                            Text("I")
                            Spacer()
                            Text("M")
                            Spacer()
                            Text("A")
                            Spacer()
                            Text("G")
                            Spacer()
                            Text("E")
                            Spacer()
                            Text("S")
                        }.foregroundStyle(orangeColor)

                        // MINIMAL MODE:          [toggle]
                        row {
                            Text("MINIMAL MODE:")
                                .foregroundStyle(orangeColor)
                            Spacer()
                            Toggle("", isOn: $minimalMode)
                                .labelsHidden()
                                .tint(Color.newGreen)
                                .scaleEffect(CGSize(width: 0.85, height: 0.85), anchor: .trailing)
                                .frame(width: 51)
                                .padding(.horizontal, 7)
                            
                        }
                        .padding(.vertical, -5)

                        // CONTACT             DEVELOPER
                        Button { openMail() } label: {
                            row {
                                Text("CONTACT")
                                    .foregroundStyle(Color.darkBlue)
                                Spacer()
                                Text("D")
                                    .foregroundStyle(orangeColor)
                                Spacer()
                                Text("E")
                                    .foregroundStyle(orangeColor)
                                Spacer()
                                Text("V")
                                    .foregroundStyle(orangeColor)
                                Spacer()
                                Text("E")
                                    .foregroundStyle(orangeColor)
                                Spacer()
                                Text("L")
                                    .foregroundStyle(orangeColor)
                                Spacer()
                                Text("O")
                                    .foregroundStyle(orangeColor)
                                Spacer()
                                Text("P")
                                    .foregroundStyle(orangeColor)
                                Spacer()
                                Text("E")
                                    .foregroundStyle(orangeColor)
                                Spacer()
                                Text("R")
                                    .foregroundStyle(orangeColor)
                            }
                        }
                        .buttonStyle(.plain)

                        // REPORT                     BUG
                        Button { openBugReport() } label: {
                            row {
                                Text("REPORT")
                                    .foregroundStyle(Color.darkBlue)
                                Spacer()
                                Text("B")
                                    .foregroundStyle(orangeColor)
                                Spacer()
                                Text("U")
                                    .foregroundStyle(orangeColor)
                                Spacer()
                                Text("G")
                                    .foregroundStyle(orangeColor)
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(0)

                        // RATE          THE          APP
                        Button { openRating() } label: {
                            row {
                                Text("RATE")
                                    .foregroundStyle(Color.darkBlue)
                                Spacer()
                                Text("A")
                                    .foregroundStyle(orangeColor)
                                Spacer()
                                Text("P")
                                    .foregroundStyle(orangeColor)
                                Spacer()
                                Text("P")
                                    .foregroundStyle(orangeColor)
                                Spacer()
                                Text("L")
                                    .foregroundStyle(orangeColor)
                                Spacer()
                                Text("I")
                                    .foregroundStyle(orangeColor)
                                Spacer()
                                Text("C")
                                    .foregroundStyle(orangeColor)
                                Spacer()
                                Text("A")
                                    .foregroundStyle(orangeColor)
                                Spacer()
                                Text("T")
                                    .foregroundStyle(orangeColor)
                                Spacer()
                                Text("I")
                                    .foregroundStyle(orangeColor)
                                Spacer()
                                Text("O")
                                    .foregroundStyle(orangeColor)
                                Spacer()
                                Text("N")
                                    .foregroundStyle(orangeColor)
                            }
                        }
                        .buttonStyle(.plain)
                        
                        row{}
                        row{}
                        
                        RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                            .fill(.secondary.opacity(1))
                            .frame(width: 250, height: 2)
        
                        row{}
                        row{}

                        // PRIVACY POLICY:    THIS APP
                        
                        // DOES NOT COLLECT, STORE, OR
                        row {
                            Text(privacyWords[privacyWordIndex])
                                .id(privacyWordIndex)
                                .transition(.opacity)
                            Spacer()
                            Text("PERSONAL")
                            Spacer()
                            Text("DATA")
                        }
                        .foregroundStyle(greyColor.opacity(0.5))
                        .task {
                            while !Task.isCancelled {
                                try? await Task.sleep(for: .seconds(2))
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    privacyWordIndex = (privacyWordIndex + 1) % privacyWords.count
                                }
                            }
                        }

                    }
                    .preferredColorScheme(selectedColor.isdark ? .light : .dark)
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundStyle(greyColor)
                }
                .frame(width: 250, alignment: .leading)
            }
    }

    // MARK: - Row builders

    @ViewBuilder
    private func row<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        HStack(spacing: 0) {
            content()
        }
        .frame(width: 250)
    }

    @ViewBuilder
    private func rowText<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .frame(width: 300, alignment: .leading)
    }

    // MARK: - Actions

    private func openMail() {
        let address = "doribenbass@gmail.com"
        let subject = "Asymmetrical — Feedback"
        guard let encoded = "mailto:\(address)?subject=\(subject)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encoded) else { return }
        UIApplication.shared.open(url)
    }

    private func openBugReport() {
        let address = "doribenbass@gmail.com"
        let subject = "Asymmetrical — Bug Report"
        let body = "Device: \(UIDevice.current.model)\niOS: \(UIDevice.current.systemVersion)\n\n— Describe the bug —\n\n"
        guard let encoded = "mailto:\(address)?subject=\(subject)&body=\(body)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encoded) else { return }
        UIApplication.shared.open(url)
    }

    private func openRating() {
        let appID = "0000000000" // replace with real App Store ID
        guard let url = URL(string: "https://apps.apple.com/app/id\(appID)?action=write-review") else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Preview
//
#Preview {
    NewAboutView()
}
