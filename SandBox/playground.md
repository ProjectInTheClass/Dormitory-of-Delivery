[ 변수 - 값 증가시키기 ]

var gemCounter = 0

while !isBlocked {

    moveForward()
    
    if isBlocked && isOnGem {
    
        turnRight()
        
        collectGem()
        
        gemCounter = gemCounter + 1
        
    }else if isOnGem {
    
        collectGem()
        
        gemCounter = gemCounter + 1
        
    }
    
}
