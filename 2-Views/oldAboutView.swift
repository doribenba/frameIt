////
////  aboutView.swift
////  borderControl
////
////  Created by Dorian Benbassat on 2026/7/13.
////
//
//import SwiftUI
//import StoreKit
//
//// MARK: - Settings View
//
//struct SettingsView: View {
//
//    @Environment(\.dismiss) private var dismiss
//
//    // accentColor passed in from the parent; falls back to .white in preview.
//    var accentColor: Color = .white
//    @AppStorage("minimalMode") private var minimalMode: Bool = false
//
//    var body: some View {
//        ZStack {
//            (accentColor.isdark ? Color.white : Color.black)
//                .ignoresSafeArea()
//
//            VStack(spacing: 0) {
//                // ── Top bar ───────────────────────────────────────────────
//                HStack {
//                    Button {
//                        dismiss()
//                    } label: {
//                        Image(systemName: "x.circle")
//                            .tint(accentColor)
//                            .font(.system(size: 16, weight: .bold))
//                    }
//                    Spacer()
//                }
//                .padding(.horizontal, 40)
//                .padding(.top, 16)
//                .padding(.bottom, 8)
//
//                ZStack(alignment: .top) {
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 0) {
//
//                        // ── Header ────────────────────────────────────────────
//                        headerSection
//
//                        sectionDivider
//
//                        // ── Preferences ───────────────────────────────────────
//                        sectionLabel("PREFERENCES")
//                        settingsCard {
//                            Toggle(isOn: $minimalMode) {
//                                VStack(alignment: .leading, spacing: 3) {
//                                    Text("MINIMAL MODE")
//                                        .font(.system(size: 13, weight: .bold, design: .monospaced))
//                                        .foregroundStyle(accentColor)
//                                    Text("Hides the time and date in the top bar.")
//                                        .font(.system(size: 11, weight: .regular, design: .monospaced))
//                                        .foregroundStyle(accentColor.opacity(0.45))
//                                }
//                            }
//                            .tint(Color.darkBlue)
//                        }
//
//                        sectionDivider
//
//                        // ── Support ───────────────────────────────────────────
//                        sectionLabel("SUPPORT")
//                        settingsCard {
//                            VStack(spacing: 0) {
//                                rowButton(icon: "envelope", label: "CONTACT DEVELOPER") {
//                                    openMail()
//                                }
//                                rowDivider
//                                rowButton(icon: "ant", label: "REPORT A BUG") {
//                                    openBugReport()
//                                }
//                                rowDivider
//                                rowButton(icon: "star", label: "RATE THE APP") {
//                                    openAppStoreRating()
//                                }
//                            }
//                        }
//
//                        sectionDivider
//
//                        // ── Legal ─────────────────────────────────────────────
//                        sectionLabel("LEGAL")
//                        settingsCard {
//                            VStack(alignment: .leading, spacing: 12) {
//                                privacyPolicySection
//                                rowDivider
//                                openSourceSection
//                            }
//                        }
//
//                        Spacer().frame(height: 40)
//                    }
//                    .padding(.horizontal, 40)
//                    .padding(.top, 16)
//                }
//
//                // Top fade — fades scrolled content under the x button
////                LinearGradient(
////                    stops: [
////                        .init(color: accentColor.isdark ? .white : .black, location: 0),
////                        .init(color: (accentColor.isdark ? Color.white : Color.black).opacity(0), location: 1)
////                    ],
////                    startPoint: .top,
////                    endPoint: .bottom
////                )
////                .frame(height: 28)
////                .allowsHitTesting(false)
//                } // ZStack
//            }
//        }
//        .preferredColorScheme(accentColor.isdark ? .light : .dark)
//    }
//
//    // MARK: - Header
//
//    private var headerSection: some View {
//        VStack(alignment: .leading, spacing: 6) {
//            Text("BORDER CONTROL")
//                .font(.system(size: 22, weight: .black, design: .monospaced))
//                .foregroundStyle(accentColor)
//            Text("Version \(appVersion)")
//                .font(.system(size: 11, weight: .regular, design: .monospaced))
//                .foregroundStyle(accentColor.opacity(0.4))
//            Spacer().frame(height: 8)
//            Text("A minimal photo framing tool.\nAdd borders, pick a color, export — that's it.")
//                .font(.system(size: 12, weight: .regular, design: .monospaced))
//                .foregroundStyle(accentColor.opacity(0.55))
//                .fixedSize(horizontal: false, vertical: true)
//        }
//        .padding(.bottom, 28)
//    }
//
//    // MARK: - Privacy Policy
//
//    private var privacyPolicySection: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Label("PRIVACY POLICY", systemImage: "lock.shield")
//                .font(.system(size: 12, weight: .bold, design: .monospaced))
//                .foregroundStyle(accentColor)
//
//            Text("""
//                This app does not collect, store, or transmit any personal data.
//
//                Everything happens entirely on your device. Your photos never leave your phone. No accounts, no analytics, no tracking — ever.
//                """)
//                .font(.system(size: 11, weight: .regular, design: .monospaced))
//                .foregroundStyle(accentColor.opacity(0.5))
//                .fixedSize(horizontal: false, vertical: true)
//        }
//    }
//
//    // MARK: - Open Source Acknowledgements
//
//    private var openSourceSection: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Label("OPEN SOURCE", systemImage: "curlybraces")
//                .font(.system(size: 12, weight: .bold, design: .monospaced))
//                .foregroundStyle(accentColor)
//
//            VStack(alignment: .leading, spacing: 4) {
//                Text("This app uses the following open-source library:")
//                    .font(.system(size: 11, weight: .regular, design: .monospaced))
//                    .foregroundStyle(accentColor.opacity(0.5))
//
//                HStack(alignment: .top, spacing: 6) {
//                    Text("▸")
//                        .font(.system(size: 11, weight: .bold, design: .monospaced))
//                        .foregroundStyle(accentColor.opacity(0.4))
//                    VStack(alignment: .leading, spacing: 2) {
//                        Text("ConfettiSwiftUI")
//                            .font(.system(size: 11, weight: .bold, design: .monospaced))
//                            .foregroundStyle(accentColor.opacity(0.65))
//                        Text("by Simon Bachmann — MIT License")
//                            .font(.system(size: 10, weight: .regular, design: .monospaced))
//                            .foregroundStyle(accentColor.opacity(0.35))
//                    }
//                }
//            }
//        }
//    }
//
//    // MARK: - Reusable Components
//
//    private var sectionDivider: some View {
//        Rectangle()
//            .fill(accentColor.opacity(0.08))
//            .frame(height: 1)
//            .padding(.vertical, 20)
//    }
//
//    private var rowDivider: some View {
//        Rectangle()
//            .fill(accentColor.opacity(0.1))
//            .frame(height: 1)
//    }
//
//    private func sectionLabel(_ title: String) -> some View {
//        Text(title)
//            .font(.system(size: 10, weight: .bold, design: .monospaced))
//            .foregroundStyle(accentColor.opacity(0.35))
//            .padding(.bottom, 10)
//    }
//
//    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
//        content()
//            .padding(.vertical, 14)
//            .padding(.horizontal, 16)
//            .background(accentColor.opacity(0.06))
//            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
//            .padding(.bottom, 20)
//    }
//
//    private func rowButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
//        Button(action: action) {
//            HStack(spacing: 12) {
//                Image(systemName: icon)
//                    .font(.system(size: 13, weight: .semibold))
//                    .foregroundStyle(accentColor.opacity(0.55))
//                    .frame(width: 18)
//                Text(label)
//                    .font(.system(size: 13, weight: .bold, design: .monospaced))
//                    .foregroundStyle(accentColor)
//                Spacer()
//                Image(systemName: "chevron.right")
//                    .font(.system(size: 10, weight: .semibold))
//                    .foregroundStyle(accentColor.opacity(0.25))
//            }
//            .padding(.vertical, 10)
//        }
//        .buttonStyle(.plain)
//    }
//
//    // MARK: - Actions
//
//    private func openMail() {
//        let email = "doribenbass@gmail.com"
//        let subject = "Asymmetrical — Feedback"
//        let encoded = "mailto:\(email)?subject=\(subject)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
//        if let url = URL(string: encoded) {
//            UIApplication.shared.open(url)
//        }
//    }
//
//    private func openBugReport() {
//        let email = "doribenbass@gmail.com"
//        let subject = "Asymmetrical — Bug Report"
//        let body = "Device: \(UIDevice.current.model)\niOS: \(UIDevice.current.systemVersion)\nApp Version: \(appVersion)\n\n— Describe the bug below —\n\n"
//        let encoded = "mailto:\(email)?subject=\(subject)&body=\(body)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
//        if let url = URL(string: encoded) {
//            UIApplication.shared.open(url)
//        }
//    }
//
//    private func openAppStoreRating() {
//        // Replace with your actual App Store ID once live
//        let appStoreID = "0000000000"
//        if let url = URL(string: "https://apps.apple.com/app/id\(appStoreID)?action=write-review") {
//            UIApplication.shared.open(url)
//        }
//    }
//
//    // MARK: - Helpers
//
//    private var appVersion: String {
//        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    SettingsView()
//}
