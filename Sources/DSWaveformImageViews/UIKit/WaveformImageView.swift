#if os(iOS) || swift(>=5.9) && os(visionOS)
import DSWaveformImage
import Foundation
import AVFoundation
import UIKit

public class WaveformImageView: UIImageView {
    private let waveformImageDrawer: WaveformImageDrawer

    public var completion: ((Bool)->())?
    public var configuration: Waveform.Configuration
    

    public var waveformAudioURL: URL?
    
    override public init(frame: CGRect) {
        configuration = Waveform.Configuration(size: frame.size)
        waveformImageDrawer = WaveformImageDrawer()
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        configuration = Waveform.Configuration()
        waveformImageDrawer = WaveformImageDrawer()
        super.init(coder: aDecoder)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        //updateWaveform()
    }

    /// Clears the audio data, emptying the waveform view.
    public func reset() {
        waveformAudioURL = nil
        image = nil
    }
}

private extension WaveformImageView {
    func updateWaveform() {
        guard let audioURL = waveformAudioURL else { return }
        
        Task {
            do {
                let image = try await waveformImageDrawer.waveformImage(
                    fromAudioAt: audioURL,
                    with: configuration.with(size: bounds.size),
                    qos: .userInteractive
                )

                await MainActor.run {
                    self.completion?(true)
                    //self.image = image
                }
            } catch {
                print("Error occurred during waveform image creation:")
                print(error)
                self.completion?(false)
            }
        }
    }
}
#endif
