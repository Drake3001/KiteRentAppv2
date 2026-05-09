// QRScannerView.swift
import SwiftUI
import AVFoundation
import AudioToolbox

struct QRScannerView: UIViewControllerRepresentable {
     var onFound: (String) -> Void
    var onCancel: (() -> Void)? = nil

    func makeUIViewController(context: Context) -> ScannerViewController {
        let vc = ScannerViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.completion = { code in
            onFound(code)
        }
        vc.onCancel = {
            onCancel?()
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
}


final class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var completion: ((String) -> Void)?
    var onCancel: (() -> Void)?

    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var isSessionConfigured = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        self.edgesForExtendedLayout = .all
        self.extendedLayoutIncludesOpaqueBars = true

        configureNavigation()
        checkCameraAuthorizationAndSetup()
    }

    private func configureNavigation() {
        let close = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
        close.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        close.tintColor = .white

        close.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        close.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(close)

        NSLayoutConstraint.activate([
            close.topAnchor.constraint(equalTo: view.topAnchor, constant: 52),
            close.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18)
        ])
    }


    @objc private func closeTapped() {
        stopSession()
        onCancel?()
//        dismiss(animated: true)
    }

    private func checkCameraAuthorizationAndSetup() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupSessionIfNeeded()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.setupSessionIfNeeded()
                    } else {
                        self?.showCameraDeniedAlert()
                    }
                }
            }
        default:
            showCameraDeniedAlert()
        }
    }

    private func showCameraDeniedAlert() {
        let alert = UIAlertController(title: "Brak dostępu do kamery",
                                      message: "Włącz dostęp do kamery w Ustawieniach, aby skanować QR.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.onCancel?()
            self.dismiss(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Ustawienia", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        present(alert, animated: true)
    }

    private func setupSessionIfNeeded() {
        guard !isSessionConfigured else {
            startSession()
            return
        }

        guard let videoDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            return
        }

        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }

        let metadataOutput = AVCaptureMetadataOutput()
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            metadataOutput.metadataObjectTypes = [.qr]
        }

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(preview, at: 0)
        self.previewLayer = preview

        isSessionConfigured = true
        startSession()
    }

    private func startSession() {
        if !session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.session.startRunning()
            }
        }
    }

    private func stopSession() {
        if session.isRunning {
            session.stopRunning()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let meta = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let string = meta.stringValue else { return }

        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

        stopSession()

        DispatchQueue.main.async { [weak self] in
            self?.completion?(string)
//            self?.dismiss(animated: true)
        }
    }

    deinit {
        stopSession()
    }
}
