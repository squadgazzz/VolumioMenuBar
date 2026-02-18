import SwiftUI

struct EQSection: View {
    @Environment(AppState.self) private var appState
    @AppStorage("eqSectionExpanded") private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
            } label: {
                HStack {
                    Text("FusionDSP")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                Toggle("Effect Enabled", isOn: effectEnabledBinding)
                    .toggleStyle(.checkbox)
                    .font(.caption)

                if appState.fusionDSP.isActive {
                    if appState.fusionDSP.isLoading {
                        HStack(spacing: 6) {
                            ProgressView()
                                .controlSize(.small)
                            Text("Loading presets...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else if appState.fusionDSP.supportsPresets {
                        if appState.fusionDSP.presets.isEmpty {
                            Text("No presets available")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            presetPicker
                        }
                    } else {
                        Text("Presets not available for \(appState.fusionDSP.dspType)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Button {
                        appState.fusionDSP.openFusionDSPSettings()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "slider.horizontal.3")
                                .frame(width: 16, alignment: .center)
                            Text("Open FusionDSP Settings")
                        }
                        .font(.caption)
                    }
                    .buttonStyle(HoverButtonStyle())
                }
            }
        }
    }

    private var effectEnabledBinding: Binding<Bool> {
        Binding(
            get: { appState.fusionDSP.isEffectEnabled },
            set: { appState.fusionDSP.setEffectEnabled($0) }
        )
    }

    @ViewBuilder
    private var presetPicker: some View {
        @Bindable var fusionDSP = appState.fusionDSP
        let selectedValue = Binding<String>(
            get: { fusionDSP.currentPreset?.value ?? "" },
            set: { newValue in
                if let preset = fusionDSP.presets.first(where: { $0.value == newValue }) {
                    fusionDSP.switchPreset(preset)
                }
            }
        )

        Picker("Preset", selection: selectedValue) {
            ForEach(appState.fusionDSP.presets) { preset in
                Text(preset.label).tag(preset.value)
            }
        }
        .pickerStyle(.menu)
        .labelsHidden()
    }
}
