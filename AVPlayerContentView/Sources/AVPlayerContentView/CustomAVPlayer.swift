import AVFoundation

// AVPlayerを使ったメディア再生の解説用
public class CustomAVPlayer {
    private var player: AVPlayer = AVPlayer()
    private var playerItems: [AVPlayerItem] = []
    private var timeObserverToken: Any?
    private var itemDidPlayToEndObserver: NSObjectProtocol?
    private var synchronizedLayer: AVSynchronizedLayer?

    // プレイヤーのインスタンスを取得するためのプロパティ
    public var avPlayer: AVPlayer {
        return player
    }

    // ボリュームを取得および設定するためのプロパティ
    public var volume: Float {
        get { player.volume }
        set { player.volume = newValue }
    }

    // 再生中かどうかを示すブールプロパティ
    public var isPlaying: Bool {
        return player.rate != 0
    }

    // 一時停止中かどうかを示すブールプロパティ
    public var isPaused: Bool {
        return player.rate == 0 && player.currentTime() != CMTime.zero
    }

    // 現在の再生時間を取得するためのプロパティ
    public var currentTime: CMTime {
        return player.currentTime()
    }

    // 再生速度を取得および設定するためのプロパティ
    public var rate: Float {
        get { player.rate }
        set { player.rate = newValue }
    }

    // コンストラクタ。URLのリストからプレイヤーアイテムを生成
    public init(urls: [URL]) {
        self.playerItems = urls.map { AVPlayerItem(url: $0) }
        setupEndPlaybackObserver()
        setupSynchronizedLayer()
    }

    // ディストラクタ。オブザーバーをクリーンアップ
    deinit {
        cleanUp()
    }

    // 再生終了のオブザーバーを設定
    private func setupEndPlaybackObserver() {
        itemDidPlayToEndObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: .main) { [weak self] _ in
                self?.loadNextItem()
            }
    }

    // クリーンアップ。オブザーバーを削除
    private func cleanUp() {
        if let observer = timeObserverToken {
            player.removeTimeObserver(observer)
            timeObserverToken = nil
        }
        if let observer = itemDidPlayToEndObserver {
            NotificationCenter.default.removeObserver(observer)
            itemDidPlayToEndObserver = nil
        }
    }

    // 次のアイテムをロードして再生
    private func loadNextItem() {
        if !playerItems.isEmpty {
            let nextItem = playerItems.removeFirst()
            player.replaceCurrentItem(with: nextItem)
            player.play()
        } else {
            stop()
        }
    }

    // 再生を開始
    public func play() {
        if player.currentItem == nil && !playerItems.isEmpty {
            loadNextItem()
        } else {
            player.play()
        }
    }

    // 再生を一時停止
    public func pause() {
        player.pause()
    }

    // 再生を停止し、再生位置をリセット
    public func stop() {
        player.pause()
        player.seek(to: CMTime.zero)
        player.replaceCurrentItem(with: nil)
        playerItems.removeAll()
    }

    // 指定した時間にシーク
    public func seek(to time: CMTime) {
        player.seek(to: time)
    }

    // 定期的な時間オブザーバーを追加
    public func addPeriodicTimeObserver(interval: CMTime, queue: DispatchQueue?, using block: @escaping (CMTime) -> Void) {
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: queue, using: block)
    }

    // 指定した秒数だけ前進
    public func skipForward(by seconds: Double) {
        let currentTime = player.currentTime()
        let newTime = CMTimeAdd(currentTime, CMTimeMakeWithSeconds(seconds, preferredTimescale: currentTime.timescale))
        player.seek(to: newTime)
    }

    // 指定した秒数だけ後退
    public func skipBackward(by seconds: Double) {
        let currentTime = player.currentTime()
        let newTime = CMTimeSubtract(currentTime, CMTimeMakeWithSeconds(seconds, preferredTimescale: currentTime.timescale))
        player.seek(to: newTime)
    }

    // 新しいURLを再生リストに追加
    public func add(url: URL) {
        let newItem = AVPlayerItem(url: url)
        playerItems.append(newItem)
    }

    // 現在の再生時間を秒単位で取得
    public func currentPlaybackTime() -> TimeInterval {
        return player.currentTime().seconds
    }

    // 再生リストを取得するメソッド
    public func getPlaylist() -> [URL] {
        return playerItems.compactMap { ($0.asset as? AVURLAsset)?.url }
    }

    // 特定の位置にスキップするメソッド
    public func skipToItem(at index: Int) {
        guard index >= 0 && index < playerItems.count else { return }
        let selectedItem = playerItems.remove(at: index)
        playerItems.insert(selectedItem, at: 0)
        loadNextItem()
    }

    // 再生リストをシャッフルするメソッド
    public func shufflePlaylist() {
        playerItems.shuffle()
    }

    // 再生中のアイテムの情報を取得するメソッド
    public func currentItemInfo() -> URL? {
        return (player.currentItem?.asset as? AVURLAsset)?.url
    }

    // AVSynchronizedLayerの設定
    private func setupSynchronizedLayer() {
        if let currentItem = player.currentItem {
            synchronizedLayer = AVSynchronizedLayer(playerItem: currentItem)
        }
    }

    // AVSynchronizedLayerを使用してカスタムアニメーションを追加するメソッド
    public func addSynchronizedAnimationLayer(_ layer: CALayer) {
        guard let synchronizedLayer = synchronizedLayer else { return }
        synchronizedLayer.addSublayer(layer)
    }
}
