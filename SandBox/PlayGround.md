# 변수값증가시키기

'''
while !isBlocked || !isBlockedLeft || !isBlockedRight{
    if isOnGem{
        collectGem()
        gemCounter += 1
    }
    if isBlockedRight{
        moveForward()
    }
    else{
        turnRight()
        moveForward()
    }
}

