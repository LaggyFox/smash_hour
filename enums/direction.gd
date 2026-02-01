extends Node

var UP: Vector2 = Vector2(0, -1)
var DOWN: Vector2 = Vector2(0, 1)
var LEFT: Vector2 = Vector2(-1, 0)
var RIGHT: Vector2 = Vector2(1, 0)
var UP_LEFT: Vector2 = Vector2(-1, -1).normalized()
var UP_RIGHT: Vector2 = Vector2(1, -1).normalized()
var DOWN_LEFT: Vector2 = Vector2(-1, 1).normalized()
var DOWN_RIGHT: Vector2 = Vector2(1, 1).normalized()

var UP_UP_LEFT: Vector2 = Vector2(-0.5, -1).normalized()
var UP_UP_RIGHT: Vector2 = Vector2(0.5, -1).normalized()
var RIGHT_UP_RIGHT: Vector2 = Vector2(1, -0.5).normalized()
var RIGHT_DOWN_RIGHT: Vector2 = Vector2(1, 0.5).normalized()
var DOWN_DOWN_LEFT: Vector2 = Vector2(-0.5, 1).normalized()
var DOWN_DOWN_RIGHT: Vector2 = Vector2(0.5, 1).normalized()
var LEFT_UP_LEFT: Vector2 = Vector2(-1, -0.5).normalized()
var LEFT_DOWN_LEFT: Vector2 = Vector2(-1, 0.5).normalized()

var directions_16: Array[Vector2] = [
    UP,
    UP_UP_LEFT,
    UP_LEFT,
    LEFT_UP_LEFT,
    LEFT,
    LEFT_DOWN_LEFT,
    DOWN_LEFT,
    DOWN_DOWN_LEFT,
    DOWN,
    DOWN_DOWN_RIGHT,
    DOWN_RIGHT,
    RIGHT_DOWN_RIGHT,
    RIGHT,
    RIGHT_UP_RIGHT,
    UP_RIGHT,
    UP_UP_RIGHT
]