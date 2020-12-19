import UIKit
import AVFoundation

class SoundViewController: UIViewController {

    @IBOutlet weak var btnGrabar: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var txtNombreAudio: UITextField!
    @IBOutlet weak var btnAgregar: UIButton!
    @IBOutlet weak var lblDuracion: UILabel!
    
    var grabarAudio:AVAudioRecorder?;
    var playAudio:AVAudioPlayer?;
    var audioURL:URL?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion();
        btnPlay.isEnabled = false;
        btnAgregar.isEnabled = false;
    }
    func configurarGrabacion(){
        do{
            //Creamos la sesión
            let session = AVAudioSession.sharedInstance();
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: []);
            try session.overrideOutputAudioPort(.speaker);
            try session.setActive(true);
            //Setting Storage root
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!;
            let pathComponents = [basePath, "audio.m4a"];
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!;
            //Get root in console
            print("*********************");
            print(audioURL!);
            print("*********************");
            
            //Options for recorder
            var settings:[String:AnyObject] = [:];
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?;
            settings[AVSampleRateKey] = 44100.0 as AnyObject?;
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?;
            
            //Create audio object
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings);
            grabarAudio!.prepareToRecord();
            
        }
        catch( let err as NSError) {
            print(err);
        }
        
    }
    
    @IBAction func grabarTapped(_ sender: Any) {
        
        if grabarAudio!.isRecording {
            //Stop Recording
            grabarAudio?.stop();
            //Change button grabar's text
            btnGrabar.setTitle("GRABAR", for: .normal);
            btnPlay.isEnabled = true;
            btnAgregar.isEnabled = true;
            
        }
        else{
            //Start recording
            grabarAudio?.record();
            //Chagen button grabar's text
            btnGrabar.setTitle("DETENER", for: .normal);
            btnPlay.isEnabled = false;

            // a method for update
            func updateTime(){
                 if grabarAudio!.isRecording{
                     let minutes = floor(grabarAudio!.currentTime/60)
                     let seconds = grabarAudio!.currentTime - (minutes * 60)
                     let timeInfo = String(format: "%0.0f.%0.0f", minutes, seconds)
                 }
             }
            var myTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: @selector(updateTime), userInfo: nil, repeats: true);
            
                /*let duracion = grabarAudio!.currentTime;
                let minutes = floor(duracion/60);
                let seconds = duracion - (minutes * 60);
                lblDuracion.text = String(format: "%0.0f.%0.0f", minutes,seconds) as String;*/
                // initWithFormat:@"%0.0f.%0.0f", minutes, seconds];
        }
    }
    
    @IBAction func playTapped(_ sender: Any) {
        do{
            try playAudio = AVAudioPlayer(contentsOf: audioURL!);
            playAudio!.play();
            print("Reproduciendo audio.");
    
        }catch(let err as NSError){
            print(err);
        }
    }
    
    @IBAction func agregarTapped(_ sender: Any) {
        let appDel = (UIApplication.shared.delegate as! AppDelegate);
        let contexto = appDel.persistentContainer.viewContext;
        
        let record = Grabacion(context: contexto);
        record.nombre = txtNombreAudio.text;
        record.audio = NSData(contentsOf: audioURL!)! as Data;
        appDel.saveContext();
        navigationController!.popViewController(animated: true);
    }
}
