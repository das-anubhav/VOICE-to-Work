
import UIKit
import CoreData
import Lottie
import AVFoundation
import Speech

class EntryViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet var titleField: UITextField!
    @IBOutlet var noteField: UITextView!
    @IBOutlet weak var segmentCt: UISegmentedControl!
    @IBOutlet weak var startStopBtn: UIButton!
    public var completion: ((String, String) -> Void)?
    
    
    var people = [Person]()
    
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US")) //1
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    var lang: String = "en-US"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleField.becomeFirstResponder()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSave))
        
        
        
        
        let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()

        do {
            let people = try PersistanceService.context.fetch(fetchRequest)
            self.people = people
//            self.table.reloadData()
        } catch {}
        
        
        
        
        self.titleField.delegate = self
        self.noteField.delegate = self
        
        
        startStopBtn.isEnabled = false  //2
        speechRecognizer?.delegate = self as? SFSpeechRecognizerDelegate  //3
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: lang))
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            
            var isButtonEnabled = false
            
            switch authStatus {  //5
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            @unknown default:
                fatalError("Error")
            }
            
            OperationQueue.main.addOperation() {
                self.startStopBtn.isEnabled = isButtonEnabled
            }
        }
        
        
        
    }
    
    @objc func didTapSave() {
        if let text = titleField.text, !text.isEmpty, !noteField.text.isEmpty {
            completion?(text, noteField.text)
        
            
            
            
        }
    }
    
    
//    func lottieAnimation() {
//
//        let animationview = AnimationView(name: "20673-record-pink")
//        animationview.frame = CGRect(x: 140, y: 780, width: 120, height: 120)
////        animationview.center = self.view.bottomAnchor
//        animationview.contentMode = .scaleAspectFit
//        view.addSubview(animationview)
//        animationview.play()
//        animationview.loopMode = .loop
//    }
    
    
    @IBAction func segmentAct(_ sender: UISegmentedControl) {
        
        switch segmentCt.selectedSegmentIndex {
               case 0:
                   lang = "en-US"
                   break;
               case 1:
                   lang = "hi-IN"
                   break;
               case 2:
                   lang = "es-ES"
                   break;
               case 3:
                   lang = "ja-JP"
                   break;
               case 4:
                   lang = "fr-FR"
                   break;
               default:
                   lang = "en-US"
                   break;
               }
               
               speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: lang))
        
    }
    @IBAction func startStopAct(_ sender: UIButton) {
        
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: lang))
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            startStopBtn.isEnabled = false
            startStopBtn.setTitle("Start Recording", for: .normal)
        } else {
            startRecording()
            startStopBtn.setTitle("Stop Recording", for: .normal)
        }
        
    }
    
    
    func startRecording() {
            
            if recognitionTask != nil {
                recognitionTask?.cancel()
                recognitionTask = nil
            }
            
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(AVAudioSession.Category.record)
                try audioSession.setMode(AVAudioSession.Mode.measurement)
                try audioSession.setActive(true)
            } catch {
                print("audioSession properties weren't set because of an error.")
            }
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            
            let inputNode = audioEngine.inputNode
            
            guard let recognitionRequest = recognitionRequest else {
                fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
            }
            
            recognitionRequest.shouldReportPartialResults = true
            
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
                
                var isFinal = false
                
                if result != nil {
                    
                    
                    
//                    self.titleField.text = result?.bestTranscription.formattedString
//                    isFinal = (result?.isFinal)!
//                    
                    self.noteField.text = result?.bestTranscription.formattedString
                    isFinal = (result?.isFinal)!
                }
                
                if error != nil || isFinal {
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                    
                    self.startStopBtn.isEnabled = true
                }
            })
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
                self.recognitionRequest?.append(buffer)
            }
            
            audioEngine.prepare()
            
            do {
                try audioEngine.start()
            } catch {
                print("audioEngine couldn't start because of an error.")
            }
            
    //        textView.text = "Say something, I'm listening!"
            
        }
    
    
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            startStopBtn.isEnabled = true
        } else {
            startStopBtn.isEnabled = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleField.resignFirstResponder()
        noteField.resignFirstResponder()
        return true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
//        noteField.resignFirstResponder()
        titleField.endEditing(true)
        noteField.endEditing(true)
    }
}
