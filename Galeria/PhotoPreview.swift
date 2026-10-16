import SwiftUI
import Photos
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins

@MainActor
final class PreviewLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var improved: UIImage?
    @Published var progress: Double = 0
    @Published var loading = false
    @Published var message: String?
    private var requestID: PHImageRequestID = PHInvalidImageRequestID
    private var generation = UUID()

    func load(_ asset: PHAsset) {
        cancel()
        let token = UUID()
        generation = token
        loading = true
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        options.progressHandler = { [weak self] value, _, _, _ in
            Task { @MainActor in
                guard let self, self.generation == token else { return }
                self.progress = value
            }
        }
        requestID = PHImageManager.default().requestImage(
            for: asset, targetSize: CGSize(width: 1600, height: 1600),
            contentMode: .aspectFit, options: options
        ) { [weak self] image, info in
            let degraded = info?[PHImageResultIsDegradedKey] as? Bool ?? false
            let cancelled = info?[PHImageCancelledKey] as? Bool ?? false
            let error = info?[PHImageErrorKey] as? Error
            Task { @MainActor in
                guard let self, self.generation == token, !degraded else { return }
                self.loading = false
                if cancelled { self.message = "Descarga cancelada." }
                else if let error { self.message = error.localizedDescription }
                else if let image { self.image = image; self.progress = 1 }
                else { self.message = "No se pudo obtener la imagen. Comprueba la conexión con iCloud." }
            }
        }
    }

    func cancel() {
        generation = UUID()
        if requestID != PHInvalidImageRequestID {
            PHImageManager.default().cancelImageRequest(requestID)
        }
        requestID = PHInvalidImageRequestID
        loading = false
    }

    private func normalizedJPEG(quality: CGFloat) -> Data? {
        guard let image else { return nil }
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        return renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: image.size)) }
            .jpegData(compressionQuality: quality)
    }

    func analyze() async {
        guard let data = normalizedJPEG(quality: 0.9) else { return }
        // JPEG encoding normalizes the displayed preview's orientation.
        message = "Analizando la vista previa en el dispositivo…"
        message = await Task.detached(priority: .utility) {
            do {
                let request = VNDetectFaceRectanglesRequest()
                try VNImageRequestHandler(data: data).perform([request])
                let count = request.results?.count ?? 0
                return "Vision detectó \(count) rostro(s) en la vista previa. Esto no identifica personas ni guarda un índice facial."
            } catch { return "Error de Vision: \(error.localizedDescription)" }
        }.value
    }

    func improve() async {
        guard let data = normalizedJPEG(quality: 0.95) else { return }
        let result: Data? = await Task.detached(priority: .utility) {
            guard let input = CIImage(data: data) else { return nil }
            let denoise = CIFilter.noiseReduction()
            denoise.inputImage = input
            denoise.noiseLevel = 0.02
            denoise.sharpness = 0.3
            guard let output = denoise.outputImage else { return nil }
            return CIContext().jpegRepresentation(of: output, colorSpace: CGColorSpaceCreateDeviceRGB())
        }.value
        if let result, let rendered = UIImage(data: result) {
            improved = rendered
            message = "Vista previa con reducción de ruido y nitidez suave. No se ha guardado ni modificado la foto. No es aún la mejora adaptativa por lotes."
        } else { message = "No se pudo generar la vista previa." }
    }
}

struct PhotoPreview: View {
    let asset: PHAsset
    @ObservedObject var library: PhotoLibrary
    @StateObject private var loader = PreviewLoader()
    @State private var showImproved = false
    @State private var confirmFavorite = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    Text("La carga puede descargar una vista previa desde iCloud.")
                        .font(.footnote).foregroundStyle(.secondary)
                    if loader.loading {
                        ProgressView(value: loader.progress)
                        Button("Cancelar descarga") { loader.cancel() }
                    }
                    if let image = showImproved ? loader.improved : loader.image {
                        Image(uiImage: image).resizable().scaledToFit()
                            .accessibilityLabel("Vista previa de la fotografía")
                    }
                    Text("\(asset.pixelWidth) × \(asset.pixelHeight)")
                    if let date = asset.creationDate { Text(date, style: .date) }
                    if asset.mediaSubtypes.contains(.photoLive) {
                        Text("Live Photo: esta prueba muestra solo una imagen y no guarda cambios.")
                            .font(.footnote)
                    }
                    Button("Detectar rostros localmente") { Task { await loader.analyze() } }
                        .disabled(loader.image == nil)
                    Button("Probar reducción de ruido y nitidez") {
                        Task { await loader.improve(); showImproved = loader.improved != nil }
                    }.disabled(loader.image == nil)
                    if loader.improved != nil { Toggle("Mostrar mejora de prueba", isOn: $showImproved) }
                    Button("Cambiar estado de favorito en Fotos", systemImage: "heart") { confirmFavorite = true }
                        .disabled(library.busy)
                    if let message = loader.message { Text(message).font(.callout) }
                    if let message = library.message { Text(message).font(.callout) }
                }.padding()
            }
            .navigationTitle("Prueba de fotografía")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { Button("Cerrar") { dismiss() } }
            .task { loader.load(asset) }
            .onDisappear { loader.cancel() }
            .confirmationDialog("¿Cambiar el favorito real de esta foto?", isPresented: $confirmFavorite, titleVisibility: .visible) {
                Button("Cambiar favorito") { Task { await library.toggleFavorite(asset) } }
            } message: { Text("Este cambio se sincroniza con Fotos y con iCloud. Puedes revertirlo pulsando de nuevo.") }
        }
    }
}
