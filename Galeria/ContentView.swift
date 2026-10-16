import SwiftUI
import Photos

struct ContentView: View {
    @StateObject private var library = PhotoLibrary()
    @State private var selected: PHAsset?
    @State private var showPreview = false
    @State private var confirmAlbum = false

    private var hasAccess: Bool { library.status == .authorized || library.status == .limited }

    var body: some View {
        TabView {
            NavigationStack {
                List {
                    Section("Prueba técnica · no borra fotos") {
                        Text("Acceso: \(authorizationLabel)")
                        if !hasAccess {
                            Button("Permitir acceso a Fotos") { Task { await library.requestAccess() } }
                            Text("Si lo has denegado, puedes cambiar el permiso en Ajustes → Apps → Galería → Fotos.")
                                .font(.footnote)
                        } else {
                            Text("\(library.total) elementos accesibles · \(library.favorites) favoritos")
                            Text("Se muestran como máximo los 60 elementos más recientes. Esta pantalla de diagnóstico aún no es la cuadrícula definitiva.")
                                .font(.footnote)
                        }
                        if library.status == .limited {
                            Text("Acceso limitado: los recuentos y álbumes no representan toda tu fototeca.")
                        }
                    }
                    ForEach(library.assets, id: \.localIdentifier) { asset in
                        Button {
                            selected = asset
                            showPreview = true
                        } label: {
                            HStack {
                                Image(systemName: asset.mediaType == .video ? "video" : "photo")
                                VStack(alignment: .leading) {
                                    if let date = asset.creationDate { Text(date, style: .date) }
                                    Text("\(asset.pixelWidth) × \(asset.pixelHeight)").font(.caption)
                                }
                                Spacer()
                                if asset.isFavorite { Image(systemName: "heart.fill").accessibilityLabel("Favorita") }
                            }
                        }
                        .disabled(asset.mediaType != .image)
                    }
                }
                .navigationTitle("Fotos")
                .toolbar { Button("Actualizar", systemImage: "arrow.clockwise") { library.refresh() } }
                .sheet(isPresented: $showPreview) {
                    if let selected { PhotoPreview(asset: selected, library: library) }
                }
            }.tabItem { Label("Fotos", systemImage: "photo.on.rectangle") }

            NavigationStack {
                List {
                    Section("Favoritos de Apple") { Label("\(library.favorites) elementos accesibles", systemImage: "heart.fill") }
                    Section("Álbumes y carpetas accesibles") {
                        ForEach(library.albums) { album in
                            HStack {
                                Label(album.title, systemImage: album.count == nil ? "folder" : "rectangle.stack")
                                    .padding(.leading, CGFloat(album.depth) * 14)
                                Spacer()
                                if let count = album.count { Text("\(count)").foregroundStyle(.secondary) }
                            }
                        }
                        if library.albums.isEmpty { Text("No se han encontrado colecciones accesibles.") }
                    }
                    Section("Comprobar escritura") {
                        Button("Crear álbum vacío de prueba") { confirmAlbum = true }
                            .disabled(!hasAccess || library.busy)
                        if let message = library.message { Text(message) }
                    }
                }
                .navigationTitle("Álbumes")
                .confirmationDialog("¿Crear un álbum real en Fotos?", isPresented: $confirmAlbum, titleVisibility: .visible) {
                    Button("Crear álbum vacío") { Task { await library.createTestAlbum() } }
                } message: { Text("Se llamará «Galería · Prueba técnica». No añadirá ni eliminará fotografías.") }
            }.tabItem { Label("Álbumes", systemImage: "rectangle.stack") }

            NavigationStack {
                List {
                    Section("Validación inicial") {
                        Text("Esta versión comprueba instalación, PhotoKit, Vision y Core Image.")
                        Text("Las fotos y el análisis permanecen en el dispositivo. iCloud puede descargar contenido mediante los servicios de Apple.")
                    }
                    Section("Pendiente de las siguientes fases") {
                        Text("Sin álbum · organización mensual · gestos · comparador · duplicados · edición adaptativa · personas")
                        Text("Todavía no hay funciones de borrado, guardado de ediciones ni reconocimiento de identidades.")
                    }
                }.navigationTitle("Organizar")
            }.tabItem { Label("Organizar", systemImage: "slider.horizontal.3") }
        }
    }

    private var authorizationLabel: String {
        switch library.status {
        case .authorized: return "completo"
        case .limited: return "limitado"
        case .denied: return "denegado"
        case .restricted: return "restringido por el sistema"
        case .notDetermined: return "sin solicitar"
        @unknown default: return "desconocido"
        }
    }
}
