import AppKit
import SwiftUI

struct WelcomeSettingsView: View {
    @ObservedObject var loginItemController: LoginItemController
    @ObservedObject var settings: AppSettings

    private let coffeeURL = URL(string: "https://www.buymeacoffee.com/")!
    private let historySizes = [5, 10, 20]

    var body: some View {
        ZStack {
            vividBackground

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    hero

                    HStack(alignment: .top, spacing: 14) {
                        launchAtLoginCard
                        developerCard
                    }

                    settingsPanel

                    HStack(alignment: .top, spacing: 14) {
                        howToUseCard
                        privacyCard
                    }

                    coffeeButton
                }
                .padding(28)
            }
        }
        .frame(minWidth: 660, idealWidth: 720, minHeight: 600, idealHeight: 650)
    }

    private var vividBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.03, green: 0.10, blue: 0.38),
                    Color(red: 0.42, green: 0.10, blue: 0.82),
                    Color(red: 0.96, green: 0.12, blue: 0.58),
                    Color(red: 1.00, green: 0.62, blue: 0.10)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            LinearGradient(
                colors: [
                    .white.opacity(0.22),
                    .clear,
                    Color(red: 0.00, green: 0.95, blue: 1.00).opacity(0.18)
                ],
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            )

            Color.black.opacity(0.18)
        }
        .ignoresSafeArea()
    }

    private var hero: some View {
        HStack(alignment: .center, spacing: 22) {
            appIcon

            VStack(alignment: .leading, spacing: 10) {
                Text("ClipStack")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(.white)

                Text("Яскравий clipboard manager для macOS, який тримає твої останні тексти й картинки під рукою прямо в menu bar.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white.opacity(0.84))
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    FeaturePill(icon: "doc.text", text: "Text")
                    FeaturePill(icon: "photo", text: "Images")
                    FeaturePill(icon: "menubar.rectangle", text: "Menu bar")
                    FeaturePill(icon: "lock", text: "Local only")
                }
                .padding(.top, 2)
            }
        }
        .padding(22)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.22), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.20), radius: 22, y: 12)
    }

    private var appIcon: some View {
        Group {
            if let image = NSImage(named: "AppIcon") {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "doc.on.clipboard")
                    .font(.system(size: 54, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white)
            }
        }
        .frame(width: 112, height: 112)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(.white.opacity(0.28), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.22), radius: 16, y: 8)
    }

    private var launchAtLoginCard: some View {
        GlassCard {
            HStack(spacing: 14) {
                CardIcon(systemName: "power")

                VStack(alignment: .leading, spacing: 4) {
                    Text("Launch at Login")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("Автоматично запускай ClipStack після входу в macOS.")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.72))
                        .lineLimit(2)
                }

                Spacer()

                Toggle("", isOn: $loginItemController.launchesAtLogin)
                    .toggleStyle(.switch)
                    .labelsHidden()
            }

            if let message = loginItemController.errorMessage {
                Text(message)
                    .font(.system(size: 12))
                    .foregroundStyle(Color(red: 1.0, green: 0.78, blue: 0.80))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var developerCard: some View {
        GlassCard {
            HStack(alignment: .top, spacing: 14) {
                CardIcon(systemName: "hammer")

                VStack(alignment: .leading, spacing: 8) {
                    Text("Розробник")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)

                    TextField("Твоє ім'я", text: $settings.developerName)
                        .textFieldStyle(.roundedBorder)

                    Text("Made with SwiftUI, AppKit і трохи любові до чистого workflow.")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.72))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var settingsPanel: some View {
        GlassCard {
            Label("Опції Clipboard", systemImage: "slider.horizontal.3")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)

            VStack(spacing: 12) {
                ToggleRow(
                    icon: "textformat",
                    title: "Зберігати текст",
                    subtitle: "Копії з браузера, нотаток, редакторів і термінала.",
                    isOn: $settings.captureText
                )

                ToggleRow(
                    icon: "photo.on.rectangle",
                    title: "Зберігати зображення",
                    subtitle: "PNG, TIFF та стандартні image-дані з pasteboard.",
                    isOn: $settings.captureImages
                )

                ToggleRow(
                    icon: "speaker.wave.2",
                    title: "Звук при новому кліпі",
                    subtitle: "Легкий системний сигнал, коли ClipStack щось зловив.",
                    isOn: $settings.playSoundOnCapture
                )
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Розмір історії")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.92))

                Picker("", selection: $settings.maxHistoryItems) {
                    ForEach(historySizes, id: \.self) { size in
                        Text("\(size) clips").tag(size)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }
            .padding(.top, 2)
        }
    }

    private var howToUseCard: some View {
        GlassCard {
            Label("Як користуватись", systemImage: "sparkles")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)

            InfoLine(number: "1", text: "Скопіюй текст або картинку будь-де в macOS.")
            InfoLine(number: "2", text: "Натисни іконку ClipStack у menu bar.")
            InfoLine(number: "3", text: "Клікни потрібний кліп, щоб повернути його в clipboard.")
        }
    }

    private var privacyCard: some View {
        GlassCard {
            Label("Приватність", systemImage: "hand.raised")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)

            Text("ClipStack працює локально на твоєму Mac. Історія живе тільки в пам'яті застосунку й очищається після виходу.")
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.74))
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var coffeeButton: some View {
        Button {
            NSWorkspace.shared.open(coffeeURL)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 17, weight: .bold))
                Text("Buy me a coffee")
                    .font(.system(size: 16, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(.white)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 1.00, green: 0.24, blue: 0.64),
                        Color(red: 1.00, green: 0.48, blue: 0.12)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.white.opacity(0.24), lineWidth: 1)
            )
            .shadow(color: Color(red: 1.0, green: 0.24, blue: 0.64).opacity(0.34), radius: 18, y: 8)
        }
        .buttonStyle(.plain)
    }
}

private struct GlassCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
    }
}

private struct CardIcon: View {
    let systemName: String

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 38, height: 38)
            .background(.white.opacity(0.14))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct ToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            CardIcon(systemName: icon)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.70))
                    .lineLimit(2)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .toggleStyle(.switch)
                .labelsHidden()
        }
        .padding(12)
        .background(.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct InfoLine: View {
    let number: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(number)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(.white.opacity(0.16))
                .clipShape(Circle())

            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.76))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct FeaturePill: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
            Text(text)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.white.opacity(0.16))
        .clipShape(Capsule())
    }
}
