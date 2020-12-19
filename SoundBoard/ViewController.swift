import UIKit;
import AVFoundation;

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet var tableView: UITableView!
    var grabaciones: [Grabacion] = [];
    var playAudio:AVAudioPlayer?;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self;
        tableView.delegate = self;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let appDel = (UIApplication.shared.delegate as! AppDelegate);
        let contexto = appDel.persistentContainer.viewContext;
        do{
            grabaciones = try contexto.fetch(Grabacion.fetchRequest());
            tableView.reloadData();
        }
        catch(let err){
            print(err);
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return grabaciones.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath);
        let grabacion = grabaciones[indexPath.row];
        var durationAudio: String;
        do{
            
            let duracion = try Int(AVAudioPlayer(data: grabacion.audio! as Data).duration);
            let minutes = duracion/60;
            let seconds = duracion - (minutes * 60);
            durationAudio = String(NSString(format: "%02d:%02d", minutes, seconds));
            cell.textLabel?.text = grabacion.nombre;
            cell.detailTextLabel?.text = "Duración: " + durationAudio;
            cell.detailTextLabel?.tintColor = UIColor.red;
        }
        catch(let err){ print(err); }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let record = grabaciones[indexPath.row];
        do{
            playAudio = try AVAudioPlayer(data: record.audio! as Data);
            playAudio?.play();
        
        }catch(let err){
            print(err);
        }
        tableView.deselectRow(at: indexPath, animated: true);
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let appDel = (UIApplication.shared.delegate as! AppDelegate);
        let contexto = appDel.persistentContainer.viewContext;
        if editingStyle == .delete {
            let record = grabaciones[indexPath.row];
            contexto.delete(record);
            appDel.saveContext();
            do{
                grabaciones = try contexto.fetch(Grabacion.fetchRequest());
                tableView.reloadData();
            }
            catch(let err){
                print(err);
            }
        }
    }
}

