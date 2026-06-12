extends Node

signal jumpscare(enemy: Enemy, area: String)
signal phantom_jumpscare()


signal flashlight_off()
signal flashlight_on()
signal update_flashlight_state(flashlight_state)

signal pickup_lumber()

signal enemy_defended(enemy)
signal remove_sleep_assurance(delta,enemy)
