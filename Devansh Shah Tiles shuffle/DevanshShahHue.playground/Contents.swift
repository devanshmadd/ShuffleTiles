//Prepared a cliché moving tiles game and forming hues with the help of playground.
//Inspired from an app which is nearly same and already there on app store : (https://itunes.apple.com/us/app/i-love-hue/id1081075274?mt=8) and other normal tiles swapping games.
//FORM THE HUES PATTERN AND SEE THE RESULT :P


import UIKit
import PlaygroundSupport


struct Position {
    let x : Int
    let y : Int
}

struct Tiles {
    let backgroundColor = UIColor(white: 1.0, alpha: 1.0)
    var tiles: [UIView] = []
    var movingTiles: [UIView] = []
    var properTiles: [UIView] = []
    init() {
        initTiles()
    }
    
    private mutating func initTiles() {
        for row in 0..<config.rows {
            for column in 0..<config.columns {
                let red: CGFloat = (230.0 - 45.0 * CGFloat(column) - CGFloat(row) * 3.0) / 255.0
                let green: CGFloat = (149.0 - CGFloat(column) * 9.0 + CGFloat(row) * 22.0) / 255.0
                let blue: CGFloat = (149.0 + CGFloat(column) * 10.0 - CGFloat(row) * 3.0) / 255.0
                addTile(withRed: red, green: green, blue: blue)
            }
        }
    }
    
    private mutating func addTile(withRed red: CGFloat, green: CGFloat, blue: CGFloat) {
        let view = UIView()
        let copyView = UIView()
        view.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        copyView.backgroundColor = view.backgroundColor
        tiles.append(view)
        properTiles.append(copyView)
    }
}

struct BoardConfig {
    let tileWitdh = 60
    let tileHeight = 60
    let rows: Int
    let columns: Int
    let tileCount: Int
    let boardSize: CGSize
    let tileSize: CGSize
    
    init(withRowsCount rows: Int, columnsCount columns: Int) {
        self.rows = rows
        self.columns = columns
        self.tileCount = rows * columns
        self.boardSize = CGSize(width: rows * tileWitdh, height: columns * tileHeight)
        self.tileSize = CGSize(width: tileWitdh, height: tileHeight)
    }
}

private let config = BoardConfig(withRowsCount: 5, columnsCount: 5)
private var tiles = Tiles()


class Board {
    let boardView : UIView
    private var shuffledTiles: [UIView] = []
    private var buildDone: ((Bool) -> ())?
    
    init() {
        boardView = UIView(frame: .zero)
        boardView.backgroundColor = tiles.backgroundColor
        boardView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func buildBoard(forView view: UIView, withCompletion completion: ((Bool) -> Void)?) {
        buildDone = completion
        initialBuild()
        initializeShuffeling()
        addTo(view: view)
    }
    
    private func initialBuild() {
        for i in 0..<config.rows {
            for j in 0..<config.columns {
                let view = tiles.properTiles[config.columns * i + j]
                view.frame = CGRect(origin: pointAt(x: j, y: i), size: config.tileSize)
                view.tag = config.columns * i + j
                view.alpha = 1.0
                boardView.addSubview(view)
            }
        }
    }
    
    private func initializeShuffeling() {
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.removeTile), userInfo: nil, repeats: false);
        
    }
    
    @objc private func removeTile() {
        if tiles.properTiles == [] {
            return
        }
        if tiles.properTiles.count == 17 {
            shuffleBuild()
            addTile()
        }
        let tile = tiles.properTiles.removeFirst()
        UIView.animate(withDuration: 0.1, animations: {
            tile.alpha = 0.0
            Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.removeTile), userInfo: nil, repeats: false);
        })
    }
    
    @objc func addTile() {
        if shuffledTiles == [] {
            buildDone?(true)
            return
        }
        let tile = shuffledTiles.removeFirst()
        UIView.animate(withDuration: 0.25, animations: {
            tile.alpha = 1.0
            Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.addTile), userInfo: nil, repeats: false);
        })
        
    }
    
    private func shuffleBuild() {
        shuffledTiles = shuffleTiles(fromIndex: 5, toIndex: 20)
        for i in 0..<config.tileCount {
            if i >= 5 && i < 20 {
                continue
            }
            addLabelToTile(atindex: i)
            shuffledTiles.insert(tiles.tiles[i], at: i)
        }
        
        for i in 0..<config.rows {
            for j in 0..<config.columns {
                let view = shuffledTiles[config.columns * i + j]
                view.frame = CGRect(origin: pointAt(x: j, y: i), size: config.tileSize)
                view.tag = config.columns * i + j
                view.alpha = 0.0
                boardView.addSubview(view)
            }
        }
    }
    
    private func shuffleTiles(fromIndex startIndex: Int, toIndex endIndex: Int) -> [UIView] {
        var tilesToShuffle: [UIView] = []
        for i in 0..<config.tileCount {
            if i >= startIndex && i < endIndex {
                tilesToShuffle.append(tiles.tiles[i])
            }
        }
           tilesToShuffle.shuffle()
        tiles.movingTiles = tilesToShuffle
        return tilesToShuffle
    }
    
    private func addLabelToTile(atindex index: Int) {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: config.tileWitdh, height: config.tileHeight))
        label.center = CGPoint(x: Double(config.tileWitdh)/2.0, y: Double(config.tileHeight)/2.0)
        label.textAlignment = .center
        label.text = "***"
        label.font = UIFont.systemFont(ofSize: 10.0)
        tiles.tiles[index].addSubview(label)
    }
    
    private func addTo(view : UIView){
        view.addSubview(self.boardView)
        boardView.widthAnchor.constraint(equalToConstant: config.boardSize.width).isActive = true
        boardView.heightAnchor.constraint(equalTo: boardView.widthAnchor).isActive = true
        boardView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        boardView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func pointAt(position: Position) -> CGPoint {
        return pointAt(x: position.x, y: position.y)
    }
    
    private func pointAt(x:Int, y:Int) -> CGPoint {
        let width = config.tileSize.width
        let height = config.tileSize.height
        return CGPoint(x: width * CGFloat(x), y: height * CGFloat(y))
    }
}


class GameViewController : UIViewController {
    let board = Board()
    var point = CGPoint()
    var frame = CGRect()
    
    override func viewDidLoad() {
        if let view = self.view {
            view.backgroundColor = UIColor(white: 1.0, alpha: 1)
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        board.buildBoard(forView: view) { (success) in
            if success {
                self.addGestureRecognizer()
            }
        }
    }
    
    
    @IBAction func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let selectedView = gestureRecognizer.view else {
            return
        }
        
        if gestureRecognizer.state == .began {
            frame = selectedView.frame
            board.boardView.bringSubviewToFront(selectedView)
        }
        
        if gestureRecognizer.state == .changed {
            setTranslation(withGestureRecognizer: gestureRecognizer)
        }
        
        if gestureRecognizer.state == .ended {
            let point = selectedView.center
            for tile in tiles.movingTiles {
                if tile.frame.contains(point) && tile != selectedView {
                    changeTilesPosition(withPointedTile: tile, andTouchedTile: selectedView)
                    break
                } else {
                    selectedView.frame = frame
                }
            }
            
            tiles.movingTiles.sort{$0.tag < $1.tag}
            if isBoardCorrect() {
                Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.fadeOut), userInfo: nil, repeats: false);
            }
        }
    }
    
    @objc private func addGestureRecognizer() {
        for i in tiles.movingTiles {
            let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            i.addGestureRecognizer(gestureRecognizer)
        }
    }
    
    private func changeTilesPosition(withPointedTile pointedTile: UIView, andTouchedTile touchedTile: UIView) {
        guard let touchedIndex = tiles.movingTiles.firstIndex(of: touchedTile),
            let pointedIndex = tiles.movingTiles.firstIndex(of: pointedTile) else {
                return
        }
        tiles.movingTiles[touchedIndex].center = pointedTile.center
        
        let tag = tiles.movingTiles[touchedIndex].tag
        tiles.movingTiles[touchedIndex].tag = pointedTile.tag
        tiles.movingTiles[pointedIndex].tag = tag
        
        moveTile(withIndex: pointedIndex)
    }
    
    private func isBoardCorrect() -> Bool {
        for (index, tile) in tiles.movingTiles.enumerated() {
            if tile != tiles.tiles[index + 5]{
                return false
            }
        }
        return true
    }
    
    private func setTranslation(withGestureRecognizer gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: self.view)
        guard let selectedView = gestureRecognizer.view else {
            return
        }
        selectedView.center = CGPoint(x: selectedView.center.x + translation.x, y: selectedView.center.y + translation.y)
        gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
    }
    
    private func moveTile(withIndex index: Int) {
        UIView.animate(withDuration: 0.30, delay: 0.01, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            tiles.movingTiles[index].frame = self.frame
        })
    }
    
    @objc private func fadeOut() {
        if tiles.tiles == [] {
            onEndGame()
            return
        }
        let tile = tiles.tiles.removeFirst()
        UIView.animate(withDuration: 0.25, animations: {
            tile.alpha = 0.0
            Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.fadeOut), userInfo: nil, repeats: false);
        })
    }
    
    private func onEndGame() {
        let ticketImageView = createTicketImageView()
        self.view.addSubview(ticketImageView)
        
        UIView.animate(withDuration: 2.0, animations: {
            ticketImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            ticketImageView.alpha = 1.0
        }, completion:{ (_ ) in
            self.addTicketText(forView: ticketImageView)
        })
    }
    
    private func addTicketText(forView view: UIView) {
        let label = createTicketLabel()
        label.frame = CGRect(x: 30, y: 160, width: view.frame.width, height: view.frame.height)
        view.addSubview(label)
        
        UIView.animate(withDuration: 1.0, delay: 0.1, options: UIView.AnimationOptions.curveEaseOut, animations: {
            label.alpha = 1.0
        })
    }
    
    private func createTicketImageView() -> UIImageView {
        let ticketImage = UIImage(named: "WWDC_Ticket.jpg")
        let imageView = UIImageView(image: ticketImage)
        imageView.frame = CGRect(x: 30, y: 30, width: view.frame.width - 60, height: view.frame.height - 60)
        imageView.contentMode = .scaleAspectFit
        imageView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        imageView.alpha = 0.0
        imageView.layer.cornerRadius = 10.0
        return imageView
    }
    
    private func createTicketLabel() -> UILabel {
        let label = UILabel()
        label.text = "Devansh Shah \nScholarship Submission"
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight(rawValue: 0.4))
        label.alpha = 0.0
        return label
    }
}

extension Array {
    mutating func shuffle() {
        for element in (0..<self.count).reversed() {
            let random = Int(arc4random_uniform(UInt32(element + 1)))
            (self[element], self[random]) = (self[random], self[element])
        }
    }
}

let controller = GameViewController()
PlaygroundPage.current.liveView = controller
