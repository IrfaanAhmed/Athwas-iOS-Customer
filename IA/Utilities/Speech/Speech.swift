

//
//  Speech.swift
//  Siri
//
//  Created by Infoline LLC on 07/08/18.
//  Copyright © 2018 Infoline LLC. All rights reserved.
//

import UIKit
import Speech

@objc public protocol SearchViewDelegate {
    /// Returns the rating value when touch events end
    @objc optional func Searchtext(_ SearchText: String)
    @objc optional func OnCompletion()
}
@available(iOS 10.0, *)

class Speech: NSObject,SFSpeechRecognizerDelegate {
    open weak var delegate: SearchViewDelegate?
    public let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    public var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    public var recognitionTask: SFSpeechRecognitionTask?
    public let audioEngine = AVAudioEngine()
    
    func start(btn:UIButton)
    {
        if self.audioEngine.isRunning {
            
            self.audioEngine.stop()
            recognitionRequest?.endAudio()
            btn.setTitle("Start Recording", for: .normal)
            sceneDelegate.window?.viewWithTag(101)?.removeFromSuperview()
         } else {
            startRecording()
            btn.setTitle("Stop Recording", for: .normal)
            viewDefault()
            
        }
    }
    
    func viewDefault()
    {
        
        var pulseEffect : LFTPulseAnimation?
        let myView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - 200, width: UIScreen.main.bounds.size.width, height: 200))
        myView.backgroundColor = UIColor.lightGray
        myView.tag = 101
        sceneDelegate.window?.addSubview(myView)
        let microphoneButton = UIButton(frame: CGRect(x: (UIScreen.main.bounds.size.width/2) - 15, y: 85, width:30, height: 30))
        microphoneButton.setImage(#imageLiteral(resourceName: "audio"), for: .normal)
        myView.addSubview(microphoneButton)
        pulseEffect = LFTPulseAnimation(repeatCount: Float.infinity, radius:20, position:microphoneButton.center)
        pulseEffect?.radius = 100.0
        myView.layer.insertSublayer(pulseEffect!, below: microphoneButton.layer)
        
        let DoneButton = UIButton(frame: CGRect(x: (UIScreen.main.bounds.size.width/2) - 22, y: 125, width:45, height: 45))
        DoneButton.setTitle("Done", for: .normal)
        DoneButton.setTitleColor(UIColor.black, for: .normal)
        DoneButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        myView.addSubview(DoneButton)
             
    }
    
    func StopDefault()
    {
        if audioEngine.isRunning
        {
            self.audioEngine.stop()
            recognitionRequest?.endAudio()
            sceneDelegate.window?.viewWithTag(101)?.removeFromSuperview()
        }
        else
        {
             sceneDelegate.window?.viewWithTag(101)?.removeFromSuperview()
        }
        
    }
    @objc func buttonAction(sender: UIButton!)
    {
        if audioEngine.isRunning
        {
            self.audioEngine.stop()
            recognitionRequest?.endAudio()
            sceneDelegate.window?.viewWithTag(101)?.removeFromSuperview()
            self.delegate?.OnCompletion?()
        }
        else
        {
        sceneDelegate.window?.viewWithTag(101)?.removeFromSuperview()
        }
    }
    
    func setup()
    {
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            /*switch authStatus {
            case .authorized:
                
                print("User Access access to speech recognition")
            case .denied:
                
                print("User denied access to speech recognition")
                
            case .restricted:
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                print("Speech recognition not yet authorized")
            }*/
            
        }
    }
    func startRecording()  {
        
        viewDefault()
        var search : String = ""
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.record)), mode: .default)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
              print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3

        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        } //5
        
        recognitionRequest.shouldReportPartialResults = true  //6
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
            
            var isFinal = false  //8
            
            if result != nil
            {
                search = result!.bestTranscription.formattedString
                //print(result!.bestTranscription.formattedString )
                isFinal = (result?.isFinal)!
                self.delegate?.Searchtext!(search)
                
            }
            
            if error != nil || isFinal {  //10
                self.audioEngine.stop()
                self.audioEngine.inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
            
        })
        
        let recordingFormat = self.audioEngine.inputNode .outputFormat(forBus: 0)  //11
        self.audioEngine.inputNode.removeTap(onBus: 0)
        self.audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        self.audioEngine.prepare()  //12
        
        do {
            try self.audioEngine.start()
        } catch {
             print("audioEngine couldn't start because of an error.")
        }
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
