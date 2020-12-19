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
        let cell = UITableViewCell();
        let grabacion = grabaciones[indexPath.row];
        cell.textLabel?.text = grabacion.nombre;
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

