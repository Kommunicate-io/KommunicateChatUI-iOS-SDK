import AVFoundation
import Foundation

protocol KMVoicePlaybackManagerDelegate: AnyObject {
    func voicePlaybackManagerDidFinish(_ manager: KMVoicePlaybackManager)
    func voicePlaybackManager(_ manager: KMVoicePlaybackManager, didFail error: Error)
}

final class KMVoicePlaybackManager: NSObject {
    weak var delegate: KMVoicePlaybackManagerDelegate?

    private var audioPlayer: AVAudioPlayer?

    func play(audioData: Data, contentType: String?) throws {
        stop()

        let fileTypeHint: String?
        switch contentType?.lowercased() {
        case let value where value?.contains("mpeg") == true:
            fileTypeHint = AVFileType.mp3.rawValue
        case let value where value?.contains("wav") == true:
            fileTypeHint = AVFileType.wav.rawValue
        default:
            fileTypeHint = nil
        }

        let player = try AVAudioPlayer(data: audioData, fileTypeHint: fileTypeHint)
        player.delegate = self
        player.prepareToPlay()
        audioPlayer = player

        guard player.play() else {
            audioPlayer = nil
            throw NSError(
                domain: "io.kommunicate.voice-playback",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Unable to start voice response playback"]
            )
        }
    }

    func stop() {
        audioPlayer?.delegate = nil
        audioPlayer?.stop()
        audioPlayer = nil
    }
}

extension KMVoicePlaybackManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard player === audioPlayer else { return }
        audioPlayer = nil
        if flag {
            delegate?.voicePlaybackManagerDidFinish(self)
        } else {
            delegate?.voicePlaybackManager(
                self,
                didFail: NSError(
                    domain: "io.kommunicate.voice-playback",
                    code: 2,
                    userInfo: [NSLocalizedDescriptionKey: "Voice response playback did not finish"]
                )
            )
        }
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        guard player === audioPlayer else { return }
        audioPlayer = nil
        delegate?.voicePlaybackManager(
            self,
            didFail: error ?? NSError(
                domain: "io.kommunicate.voice-playback",
                code: 3,
                userInfo: [NSLocalizedDescriptionKey: "Unable to decode the voice response"]
            )
        )
    }
}
