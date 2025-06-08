//
//  GlucosaWidget.swift
//  GlucosaWidget
//
//  Created by Rocco López on 07/06/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func getSnapshot(in context: Context, completion: @escaping (GlucoseEntry) -> ()) {
        let entry = GlucoseEntry()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<GlucoseEntry>) -> ()) {
        let timeline = Timeline(entries: [GlucoseEntry()], policy: .atEnd)
        completion(timeline)
    }
    
    func placeholder(in context: Context) -> GlucoseEntry {
        GlucoseEntry()
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct GlucoseEntry: TimelineEntry {
    let date: Date = .now
    
}

struct GlucosaWidgetEntryView: View {
    var entry: Provider.Entry
    
    // Datos hardcodeados para la gráfica
    let datosGrafica: [Double] = [95, 110, 125, 140, 135, 120, 115]
    let glucosaActual: Double = 115
    let estadoGlucosa: String = "Normal"
    let emoji: String = "✅"

    var body: some View {
        HStack(spacing: 10) {
            // Lado izquierdo - Valor actual
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(emoji)
                        .font(.title2)
                    VStack(alignment: .leading, spacing: 0) {
                        Text(estadoGlucosa)
                            .font(.headline)
                            .fontWeight(.semibold)
                        Text("Glucosa")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(Int(glucosaActual))")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                    
                    Text("mg/dL")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
  
            }
            
            Spacer()
            
            // Lado derecho - Gráfica
            VStack(alignment: .trailing, spacing: 4) {
                Text("Últimas 6h")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                // Gráfica simple con líneas
                GeometryReader { geometry in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let maxValue = datosGrafica.max() ?? 140
                    let minValue = datosGrafica.min() ?? 95
                    let range = maxValue - minValue
                    
                    ZStack {
                        // Líneas de referencia
                        Path { path in
                            let y1 = height * 0.25 // Línea superior
                            let y2 = height * 0.75 // Línea inferior
                            
                            path.move(to: CGPoint(x: 0, y: y1))
                            path.addLine(to: CGPoint(x: width, y: y1))
                            
                            path.move(to: CGPoint(x: 0, y: y2))
                            path.addLine(to: CGPoint(x: width, y: y2))
                        }
                        .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                        
                        // Línea principal de la gráfica
                        Path { path in
                            let stepX = width / CGFloat(datosGrafica.count - 1)
                            
                            for (index, value) in datosGrafica.enumerated() {
                                let x = CGFloat(index) * stepX
                                let normalizedValue = (value - minValue) / range
                                let y = height - (CGFloat(normalizedValue) * height)
                                
                                if index == 0 {
                                    path.move(to: CGPoint(x: x, y: y))
                                } else {
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                            }
                        }
                        .stroke(Color.green, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                        
                        // Puntos en la gráfica
                        ForEach(0..<datosGrafica.count, id: \.self) { index in
                            let value = datosGrafica[index]
                            let x = (CGFloat(index) * width) / CGFloat(datosGrafica.count - 1)
                            let normalizedValue = (value - minValue) / range
                            let y = height - (CGFloat(normalizedValue) * height)
                            
                            Circle()
                                .fill(index == datosGrafica.count - 1 ? Color.green : Color.green.opacity(0.6))
                                .frame(width: index == datosGrafica.count - 1 ? 6 : 4,
                                       height: index == datosGrafica.count - 1 ? 6 : 4)
                                .position(x: x, y: y)
                        }
                    }
                }
                .frame(height: 60)
                
                // Etiquetas de valores
                
            }
            .frame(width: 100)
        }
        .padding()
        .containerBackground(for: .widget) {
            ContainerRelativeShape()
                .fill(.white.opacity(1).gradient)
        }
    }
}

struct GlucosaWidget: Widget {
    let kind: String = "GlucosaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            GlucosaWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Glucosa")
        .description("Conoce tu estado de azúcar")
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemMedium) {
    GlucosaWidget()
} timeline: {
    GlucoseEntry()
}
