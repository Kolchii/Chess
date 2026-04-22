protocol SoundServiceProtocol: AnyObject {
    func gameStart()
    func gameEnd()
    func moveSelf()
    func moveOpponent()
    func capture()
    func castle()
    func check()
    func promote()
    func illegal()
}
