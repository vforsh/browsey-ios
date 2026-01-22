import SwiftUI
import AVFoundation

struct QRScannerView: View {
    @Environment(\.dismiss) private var dismiss

    let onScan: (Server) -> Void

    @State private var cameraPermission: AVAuthorizationStatus = .notDetermined
    @State private var scannedServer: Server?
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ZStack {
                switch cameraPermission {
                case .authorized:
                    QRScannerRepresentable { code in
                        handleScannedCode(code)
                    }
                    .ignoresSafeArea()

                    VStack {
                        Spacer()

                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white, lineWidth: 3)
                            .frame(width: 250, height: 250)
                            .background(.clear)

                        Spacer()

                        Text("Point camera at a Browsey QR code")
                            .font(.callout)
                            .foregroundStyle(.white)
                            .padding()
                            .background(.black.opacity(0.6), in: RoundedRectangle(cornerRadius: 8))
                            .padding(.bottom, 50)
                    }

                case .denied, .restricted:
                    ContentUnavailableView {
                        Label("Camera Access Required", systemImage: "camera.fill")
                    } description: {
                        Text("Please enable camera access in Settings to scan QR codes.")
                    } actions: {
                        Button("Open Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }

                case .notDetermined:
                    ProgressView("Requesting camera access...")

                @unknown default:
                    EmptyView()
                }
            }
            .navigationTitle("Scan QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Invalid QR Code", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .task {
                await requestCameraPermission()
            }
        }
    }

    private func requestCameraPermission() async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        if status == .notDetermined {
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            await MainActor.run {
                cameraPermission = granted ? .authorized : .denied
            }
        } else {
            await MainActor.run {
                cameraPermission = status
            }
        }
    }

    private func handleScannedCode(_ code: String) {
        guard scannedServer == nil else { return }

        guard let url = URL(string: code),
              let host = url.host else {
            errorMessage = "The QR code doesn't contain a valid server URL."
            showError = true
            return
        }

        let port = url.port ?? 8080
        let server = Server(host: host, port: port)

        scannedServer = server
        onScan(server)
    }
}

struct QRScannerRepresentable: UIViewControllerRepresentable {
    let onCodeScanned: (String) -> Void

    func makeUIViewController(context: Context) -> QRScannerViewController {
        let controller = QRScannerViewController()
        controller.onCodeScanned = onCodeScanned
        return controller
    }

    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {}
}

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onCodeScanned: ((String) -> Void)?

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        let session = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              session.canAddInput(videoInput) else {
            return
        }

        session.addInput(videoInput)

        let metadataOutput = AVCaptureMetadataOutput()
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            metadataOutput.metadataObjectTypes = [.qr]
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        self.captureSession = session
        self.previewLayer = previewLayer

        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession?.stopRunning()
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              metadataObject.type == .qr,
              let stringValue = metadataObject.stringValue else {
            return
        }

        captureSession?.stopRunning()
        onCodeScanned?(stringValue)
    }
}

#Preview {
    QRScannerView { _ in }
}
