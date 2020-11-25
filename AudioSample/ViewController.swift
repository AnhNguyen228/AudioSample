//
//  ViewController.swift
//  AudioSample
//
//  Created by Nguyen Anh on 11/25/20.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet weak var btnAudio: UIButton!
    
    let audio = AudioController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.checkPermission()
    }
    
    func checkPermission() {
        let audioSession = AVAudioSession.sharedInstance()
        switch audioSession.recordPermission {
        case .granted:
            print("granted")
            self.btnAudio.backgroundColor = .green
        case .undetermined:
            print("undetermined")
            audioSession.requestRecordPermission() { (granted) in
                DispatchQueue.main.async {
                    if granted {
                        print("mic request success")
                    } else {
                        print("mic request failed")
                    }
                    self.btnAudio.backgroundColor = granted ? .green : .gray
                }
            }
        case .denied:
            print("denied")
            DispatchQueue.main.async {
                self.showAlert(title: "Unable to access the Camera", message: "To enable access, go to Settings > Privacy > Camera and turn on Camera access for this app.")
            }
            
        default:
            break
        }
    }
    
    func showAlert(title:String, message:String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: { _ in
            self.btnAudio.backgroundColor = .gray
        })
        alert.addAction(okAction)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("alert setting", success)
                    })
                } else {
                    UIApplication.shared.openURL(settingsUrl)
                }
            }
        })
        alert.addAction(settingsAction)
        self.present(alert, animated: true)
        
    }
    
    @IBAction func onSelectAudio(_ sender: Any) {
        print("select audio")
        if audio.audioRecorder == nil {
            print("select audio start")
            audio.startRecording()
            self.btnAudio.setTitle("Stop", for: .normal)
        } else {
            print("select audio stop")
            audio.finishRecording(success: true)
            self.btnAudio.setTitle("Start", for: .normal)
        }
    }
    
    @IBAction func onSelectPlay(_ sender: UIButton) {
        if let audioPlay = audio.audioPlayer, audioPlay.isPlaying {
            audio.audioPlayer.stop()
            sender.setTitle("Play", for: .normal)
        } else {
            audio.preparePlayer()
            audio.audioPlayer.play()
            sender.setTitle("Stop", for: .normal)
        }
    }
    
}

