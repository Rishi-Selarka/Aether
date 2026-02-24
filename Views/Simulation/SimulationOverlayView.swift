import SwiftUI

struct SimulationOverlayView: View {
    let graph: ArchitectureGraph
    let engine: SimulationEngine
    let tierID: Int
    @Binding var config: SimulationConfig
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button("Done") { onDismiss() }
                        .font(Typography.bodyMedium)
                        .foregroundStyle(.white)
                        .padding()
                }

                Spacer()

                if tierID >= 2 {
                    simulationControls
                }

                metricsBar
            }
        }
    }

    private func binding<T>(_ keyPath: WritableKeyPath<SimulationConfig, T>) -> Binding<T> {
        Binding(
            get: { config[keyPath: keyPath] },
            set: { newValue in
                var c = config
                c[keyPath: keyPath] = newValue
                config = c
            }
        )
    }

    private var simulationControls: some View {
        VStack(spacing: LayoutConstants.spacingS) {
            Picker("Operation", selection: binding(\.operationType)) {
                ForEach(OperationType.allCases, id: \.self) { op in
                    Text(op.displayName).tag(op)
                }
            }
            .pickerStyle(.segmented)
            .colorScheme(.dark)

            HStack {
                Text("Latency: \(Int(config.networkLatency * 1000))ms")
                    .font(Typography.bodySmall)
                    .foregroundStyle(.white)
                Slider(value: binding(\.networkLatency), in: 0.1...3)
                    .tint(.white)
            }

            Toggle("Failure mode", isOn: binding(\.failureMode))
                .font(Typography.bodySmall)
                .foregroundStyle(.white)
                .toggleStyle(.switch)

            if tierID >= 3 {
                Toggle("Cache enabled", isOn: binding(\.cacheEnabled))
                    .font(Typography.bodySmall)
                    .foregroundStyle(.white)
                    .toggleStyle(.switch)
            }
        }
        .padding(LayoutConstants.spacingM)
        .background(Color.archsysSurface.opacity(0.9))
        .cornerRadius(LayoutConstants.cornerRadiusM)
        .padding(.horizontal)
    }

    private var metricsBar: some View {
        HStack(spacing: LayoutConstants.spacingL) {
            Text("Ops: \(engine.metrics.operationsCount)")
            Text("Latency: \(Int(engine.metrics.totalLatency * 1000))ms")
            if engine.metrics.cacheHits > 0 {
                Text("Cache: \(engine.metrics.cacheHits)")
                    .foregroundStyle(.green)
            }
            if engine.metrics.failures > 0 {
                Text("Fails: \(engine.metrics.failures)")
                    .foregroundStyle(.red)
            }
        }
        .font(Typography.bodySmall)
        .foregroundStyle(.white)
        .padding()
        .background(Color.archsysSurface.opacity(0.9))
    }
}
