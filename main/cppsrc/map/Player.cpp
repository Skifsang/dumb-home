#include "Player.h"

Player::Player(const QRectF & rect, Mover & mover, QObject * parent) :
    Player(rect, &mover, parent)
{
}

Player::Player(const QRectF & rect, QObject * parent) :
    Player(rect, nullptr, parent)
{
}

Player::Player(const QRectF & rect, Mover * mover, QObject * parent) :
    QObject(parent),
    DynamicMapObject(),
    rect(rect),
    mover(mover),
    movementDirection(Player::MovementDirection::UP),
    movementTimer()
{
    movementTimer.setSingleShot(false);
    movementTimer.setInterval(timerInterval);
    connect(&movementTimer, &QTimer::timeout,
            this, &Player::onMovementTimerTimeout);
}

void Player::setMover(Mover & mover)
{
    this->mover = &mover;
}

void Player::moveTo(const Player::MovementDirection direction)
{
    if (this->movementDirection == direction && movementTimer.isActive())
    {
        return;
    }

    this->movementDirection = direction;
    movementTimer.start(timerInterval);
}

void Player::stopMovement()
{
    movementTimer.stop();
}

const QRectF & Player::getRect() const
{
    return rect;
}

void Player::onMovementTimerTimeout()
{
    if (mover != nullptr)
    {
        const qreal distanse = (((qreal) timerInterval) * speed) / 1000;

        qreal resultPosition;

        switch (movementDirection)
        {
        case MovementDirection::UP:
            resultPosition = rect.y() + distanse;
            mover->move(*this, rect.x(), resultPosition);
            break;
        case MovementDirection::RIGHT:
            resultPosition = rect.x() + distanse;
            mover->move(*this, resultPosition, rect.y());
            break;
        case MovementDirection::DOWN:
            resultPosition = rect.y() - distanse;
            mover->move(*this, rect.x(), resultPosition);
            break;
        case MovementDirection::LEFT:
            resultPosition = rect.x() - distanse;
            mover->move(*this, resultPosition, rect.y());
            break;
        }
    }
}
